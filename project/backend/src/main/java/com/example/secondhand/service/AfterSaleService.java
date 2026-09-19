package com.example.secondhand.service;

import com.example.secondhand.entity.AfterSale;
import com.example.secondhand.entity.Order;
import com.example.secondhand.entity.User;
import com.example.secondhand.repository.AfterSaleRepository;
import com.example.secondhand.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class AfterSaleService {

    @Autowired
    private AfterSaleRepository afterSaleRepository;

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderService orderService;

    @Autowired
    private CreditService creditService;

    /** 用户对已支付订单发起售后申请 */
    @Transactional
    public AfterSale apply(User user, Long orderId, String reason) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));
        if (!order.getUserId().equals(user.getId())) {
            throw new IllegalArgumentException("无权操作该订单");
        }
        if ("PENDING_PAY".equals(order.getStatus())) {
            throw new IllegalArgumentException("未支付的订单不能申请售后");
        }
        if ("CANCELLED".equals(order.getStatus())) {
            throw new IllegalArgumentException("已取消的订单不能申请售后");
        }
        if ("AFTER_SALE".equals(order.getStatus())) {
            throw new IllegalArgumentException("该订单已在售后处理中");
        }
        if ("REFUNDED".equals(order.getStatus())) {
            throw new IllegalArgumentException("该订单已退款");
        }

        AfterSale afterSale = new AfterSale();
        afterSale.setOrderId(order.getId());
        afterSale.setOrderNo(order.getOrderNo());
        afterSale.setTotalPrice(order.getTotalPrice());
        afterSale.setUserId(user.getId());
        afterSale.setUsername(user.getUsername());
        afterSale.setReason(reason == null || reason.isBlank() ? "用户申请退换/售后" : reason);
        afterSale.setStatus("PENDING");
        afterSale.setPreviousStatus(order.getStatus());
        afterSale.setApplyTime(Instant.now().toString());
        AfterSale saved = afterSaleRepository.save(afterSale);

        order.setStatus("AFTER_SALE");
        orderRepository.save(order);
        return saved;
    }

    public List<AfterSale> listMine(Long userId) {
        return afterSaleRepository.findByUserIdOrderByIdDesc(userId);
    }

    /** 管理端：查全部，可按 status 过滤 */
    public List<AfterSale> listAll(String status) {
        if (status == null || status.isBlank() || "ALL".equals(status)) {
            return afterSaleRepository.findAllByOrderByIdDesc();
        }
        return afterSaleRepository.findByStatusOrderByIdDesc(status);
    }

    /** 管理端：同意或驳回 */
    @Transactional
    public void handle(Long afterSaleId, boolean approve, String remark) {
        AfterSale afterSale = afterSaleRepository.findById(afterSaleId)
                .orElseThrow(() -> new IllegalArgumentException("售后申请不存在"));
        if (!"PENDING".equals(afterSale.getStatus())) {
            throw new IllegalArgumentException("该申请已处理过");
        }

        afterSale.setStatus(approve ? "APPROVED" : "REJECTED");
        afterSale.setAdminRemark(remark == null ? "" : remark);
        afterSale.setHandleTime(Instant.now().toString());
        afterSaleRepository.save(afterSale);

        Order order = orderRepository.findById(afterSale.getOrderId()).orElse(null);
        if (order != null) {
            if (approve) {
                order.setStatus("REFUNDED");
            } else {
                String back = afterSale.getPreviousStatus();
                order.setStatus(back == null || back.isBlank() ? "PENDING_RECEIVE" : back);
            }
            orderRepository.save(order);
        }

        // 信誉分联动：同意退款视为卖家货不对板，驳回视为申请人恶意申请
        if (approve) {
            for (Long sellerId : orderService.sellerIdsOf(afterSale.getOrderId())) {
                creditService.change(sellerId, -CreditService.DEDUCT_AFTER_SALE_APPROVED,
                        "商品与描述不符，售后成立", CreditService.SOURCE_SYSTEM, "");
            }
        } else {
            creditService.change(afterSale.getUserId(), -CreditService.DEDUCT_AFTER_SALE_REJECTED,
                    "售后申请被判定为不成立", CreditService.SOURCE_SYSTEM, "");
        }
    }

    public long countPending() {
        return afterSaleRepository.findByStatusOrderByIdDesc("PENDING").size();
    }
}
