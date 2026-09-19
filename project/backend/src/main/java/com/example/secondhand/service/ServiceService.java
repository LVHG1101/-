package com.example.secondhand.service;

import com.example.secondhand.entity.ServiceItem;
import com.example.secondhand.entity.ServiceOrder;
import com.example.secondhand.repository.ServiceItemRepository;
import com.example.secondhand.repository.ServiceOrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class ServiceService {

    @Autowired
    private ServiceItemRepository serviceItemRepository;

    @Autowired
    private ServiceOrderRepository serviceOrderRepository;

    /** 应用启动完成后，按 code 补齐缺失的 6 类二手相关服务 */
    @EventListener(ApplicationReadyEvent.class)
    public void initDefaultServices() {
        ensureService("recycle", "上门回收", "收", "闲置物品上门回收，旧手机、旧家电、旧书刊均可，估价后当面结算", 0.0);
        ensureService("authenticate", "专业鉴定", "鉴", "数码、腕表、奢侈品真伪与成色鉴定，出具鉴定报告", 9.9);
        ensureService("repair", "维修保养", "修", "手机、电脑、家电等常见故障维修，支持上门或到店", 29.0);
        ensureService("clean", "清洗护理", "洗", "家电清洗、衣物洗护、箱包护理等深度清洁服务", 19.9);
        ensureService("rent", "物品租赁", "租", "相机、乐器、工具、数码等按天租赁，免押金可担保", 9.9);
        ensureService("errand", "同城跑腿", "跑", "同城取送、代买代排、搬货跑腿等即时服务", 5.0);
    }

    private void ensureService(String code, String name, String icon, String description, Double price) {
        if (serviceItemRepository.findByCode(code).isEmpty()) {
            serviceItemRepository.save(new ServiceItem(null, code, name, icon, description, price, true));
        }
    }

    public List<ServiceItem> listServices() {
        return serviceItemRepository.findByEnabledTrueOrderByIdAsc();
    }

    public ServiceItem getService(Long id) {
        return serviceItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("服务不存在"));
    }

    @Transactional
    public ServiceOrder createOrder(Long userId, ServiceOrder incoming) {
        if (incoming.getServiceId() == null) {
            throw new IllegalArgumentException("serviceId 不能为空");
        }
        ServiceItem item = getService(incoming.getServiceId());
        if (incoming.getAppointmentTime() == null || incoming.getAppointmentTime().isBlank()) {
            throw new IllegalArgumentException("预约时间不能为空");
        }
        if (incoming.getContactName() == null || incoming.getContactName().isBlank()) {
            throw new IllegalArgumentException("联系人不能为空");
        }
        if (incoming.getContactPhone() == null || incoming.getContactPhone().isBlank()) {
            throw new IllegalArgumentException("联系方式不能为空");
        }

        ServiceOrder order = new ServiceOrder();
        order.setUserId(userId);
        order.setServiceId(item.getId());
        order.setServiceCode(item.getCode());
        order.setServiceName(item.getName());
        order.setServiceIcon(item.getIcon());
        order.setContactName(incoming.getContactName());
        order.setContactPhone(incoming.getContactPhone());
        order.setAddress(incoming.getAddress());
        order.setAppointmentTime(incoming.getAppointmentTime());
        order.setRemark(incoming.getRemark());
        order.setStatus("PENDING");
        order.setCreateTime(Instant.now().toString());
        return serviceOrderRepository.save(order);
    }

    public List<ServiceOrder> myOrders(Long userId) {
        return serviceOrderRepository.findByUserIdOrderByIdDesc(userId);
    }

    @Transactional
    public void cancelOrder(Long userId, Long orderId) {
        ServiceOrder order = serviceOrderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("预约不存在"));
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作该预约");
        }
        if ("CANCELLED".equals(order.getStatus()) || "COMPLETED".equals(order.getStatus())) {
            throw new IllegalArgumentException("当前状态不可取消");
        }
        order.setStatus("CANCELLED");
        serviceOrderRepository.save(order);
    }

    // ==================== 以下为管理端方法 ====================

    /** 管理端：查全部服务（含已下架） */
    public List<ServiceItem> listAllServices() {
        return serviceItemRepository.findAll();
    }

    /** 管理端：新增或更新服务项，id 为空表示新增 */
    @Transactional
    public ServiceItem saveService(ServiceItem incoming) {
        if (incoming.getName() == null || incoming.getName().isBlank()) {
            throw new IllegalArgumentException("服务名称不能为空");
        }
        ServiceItem target;
        if (incoming.getId() == null) {
            target = new ServiceItem();
            if (incoming.getCode() == null || incoming.getCode().isBlank()) {
                target.setCode("svc" + System.currentTimeMillis());
            } else {
                target.setCode(incoming.getCode());
            }
        } else {
            target = getService(incoming.getId());
        }
        target.setName(incoming.getName());
        target.setIcon(incoming.getIcon() == null ? "" : incoming.getIcon());
        target.setDescription(incoming.getDescription() == null ? "" : incoming.getDescription());
        target.setPrice(incoming.getPrice() == null ? 0.0 : incoming.getPrice());
        if (incoming.getEnabled() != null) {
            target.setEnabled(incoming.getEnabled());
        }
        if (target.getEnabled() == null) {
            target.setEnabled(true);
        }
        return serviceItemRepository.save(target);
    }

    /** 管理端：上下架切换 */
    @Transactional
    public ServiceItem toggleService(Long id) {
        ServiceItem item = getService(id);
        item.setEnabled(!Boolean.TRUE.equals(item.getEnabled()));
        return serviceItemRepository.save(item);
    }

    /** 管理端：删除服务项 */
    @Transactional
    public void deleteService(Long id) {
        serviceItemRepository.delete(getService(id));
    }

    /** 管理端：查全部预约单，可按状态过滤 */
    public List<ServiceOrder> listAllOrders(String status) {
        if (status == null || status.isBlank() || "ALL".equals(status)) {
            return serviceOrderRepository.findAllByOrderByIdDesc();
        }
        return serviceOrderRepository.findByStatusOrderByIdDesc(status);
    }

    /** 管理端：修改预约单状态（确认 / 完成 / 取消） */
    @Transactional
    public void updateOrderStatus(Long orderId, String status) {
        ServiceOrder order = serviceOrderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("预约不存在"));
        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException("状态不能为空");
        }
        order.setStatus(status);
        serviceOrderRepository.save(order);
    }
}
