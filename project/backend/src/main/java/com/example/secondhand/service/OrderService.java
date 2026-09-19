package com.example.secondhand.service;

import com.example.secondhand.entity.CartItem;
import com.example.secondhand.entity.Goods;
import com.example.secondhand.entity.Order;
import com.example.secondhand.entity.OrderItem;
import com.example.secondhand.repository.CartItemRepository;
import com.example.secondhand.repository.GoodsRepository;
import com.example.secondhand.repository.OrderItemRepository;
import com.example.secondhand.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private OrderItemRepository orderItemRepository;

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private GoodsRepository goodsRepository;

    @Autowired
    private CreditService creditService;

    @Transactional
    public Order createOrder(Long userId, List<Long> cartItemIds) {
        List<CartItem> items = cartItemRepository.findAllById(cartItemIds);
        items = items.stream().filter(i -> i.getUserId().equals(userId)).toList();
        if (items.isEmpty()) {
            throw new IllegalArgumentException("请先选择要结算的商品");
        }
        double total = items.stream().mapToDouble(i -> i.getPrice() * i.getCount()).sum();

        Order order = new Order();
        order.setUserId(userId);
        order.setOrderNo("ORD" + System.currentTimeMillis());
        order.setTotalPrice(total);
        order.setStatus("PENDING_PAY");
        order.setCreateTime(Instant.now().toString());
        order = orderRepository.save(order);

        for (CartItem ci : items) {
            OrderItem oi = new OrderItem();
            oi.setOrderId(order.getId());
            oi.setGoodsId(ci.getGoodsId());
            oi.setName(ci.getName());
            oi.setPrice(ci.getPrice());
            oi.setImage(ci.getImage());
            oi.setCount(ci.getCount());
            orderItemRepository.save(oi);
        }

        cartItemRepository.deleteAll(items);
        return order;
    }

    @Transactional
    public void payOrder(Long userId, Long orderId, String payMethod) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作");
        }
        if (!"PENDING_PAY".equals(order.getStatus())) {
            throw new IllegalArgumentException("订单状态不可支付");
        }
        order.setStatus("PENDING_RECEIVE");
        order.setPayMethod(payMethod);
        order.setPayTime(Instant.now().toString());
        orderRepository.save(order);
    }

    public List<Order> listOrders(Long userId) {
        return orderRepository.findByUserIdOrderByIdDesc(userId);
    }

    public List<OrderItem> listItems(Long orderId) {
        return orderItemRepository.findByOrderId(orderId);
    }

    /** 确认收货：待收货 -> 已完成，并给买卖双方加信誉分 */
    @Transactional
    public void confirmReceive(Long userId, Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作");
        }
        if (!"PENDING_RECEIVE".equals(order.getStatus())) {
            throw new IllegalArgumentException("当前状态不可确认收货");
        }
        order.setStatus("COMPLETED");
        orderRepository.save(order);

        creditService.change(userId, CreditService.BONUS_ORDER_COMPLETED,
                "订单交易完成", CreditService.SOURCE_SYSTEM, "");
        for (Long sellerId : sellerIdsOf(orderId)) {
            if (!sellerId.equals(userId)) {
                creditService.change(sellerId, CreditService.BONUS_ORDER_COMPLETED,
                        "订单交易完成", CreditService.SOURCE_SYSTEM, "");
            }
        }
    }

    /** 订单里涉及的卖家（去重）。商品没有卖家字段时返回空列表 */
    public List<Long> sellerIdsOf(Long orderId) {
        List<Long> ids = new ArrayList<>();
        for (OrderItem item : orderItemRepository.findByOrderId(orderId)) {
            Goods goods = goodsRepository.findById(item.getGoodsId()).orElse(null);
            if (goods != null && goods.getUserId() != null && !ids.contains(goods.getUserId())) {
                ids.add(goods.getUserId());
            }
        }
        return ids;
    }

    /** 取消订单：仅待付款可取消 */
    @Transactional
    public void cancelOrder(Long userId, Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作");
        }
        if (!"PENDING_PAY".equals(order.getStatus())) {
            throw new IllegalArgumentException("只有待付款的订单可以取消");
        }
        order.setStatus("CANCELLED");
        orderRepository.save(order);
    }

    /** 管理端：全部订单 */
    public List<Order> listAllOrders() {
        return orderRepository.findAllByOrderByIdDesc();
    }
}
