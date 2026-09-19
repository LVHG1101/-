package com.example.secondhand.controller;

import com.example.secondhand.entity.Order;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

    @PostMapping("/create")
    public Map<String, Object> create(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Object raw = body.get("cartItemIds");
            if (raw == null) {
                map.put("code", 400);
                map.put("message", "cartItemIds 不能为空");
                return map;
            }
            List<Long> ids = new ArrayList<>();
            for (Object o : (List<?>) raw) {
                ids.add(Long.valueOf(String.valueOf(o)));
            }
            Order order = orderService.createOrder(user.getId(), ids);
            map.put("code", 200);
            map.put("message", "下单成功");
            map.put("data", order);
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/pay")
    public Map<String, Object> pay(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Long orderId = Long.valueOf(String.valueOf(body.get("orderId")));
            String payMethod = String.valueOf(body.get("payMethod"));
            orderService.payOrder(user.getId(), orderId, payMethod);
            map.put("code", 200);
            map.put("message", "支付成功");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @GetMapping("/list")
    public Map<String, Object> list() {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        List<Map<String, Object>> result = new ArrayList<>();
        for (Order o : orderService.listOrders(user.getId())) {
            Map<String, Object> m = new HashMap<>();
            m.put("id", o.getId());
            m.put("orderNo", o.getOrderNo());
            m.put("totalPrice", o.getTotalPrice());
            m.put("status", o.getStatus());
            m.put("payMethod", o.getPayMethod());
            m.put("createTime", o.getCreateTime());
            m.put("items", orderService.listItems(o.getId()));
            result.add(m);
        }
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", result);
        return map;
    }

    @PostMapping("/confirm")
    public Map<String, Object> confirm(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        Object orderId = body.get("orderId");
        if (orderId == null) {
            map.put("code", 400);
            map.put("message", "orderId 不能为空");
            return map;
        }
        try {
            orderService.confirmReceive(user.getId(), Long.valueOf(String.valueOf(orderId)));
            map.put("code", 200);
            map.put("message", "已确认收货");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/cancel")
    public Map<String, Object> cancel(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        Object orderId = body.get("orderId");
        if (orderId == null) {
            map.put("code", 400);
            map.put("message", "orderId 不能为空");
            return map;
        }
        try {
            orderService.cancelOrder(user.getId(), Long.valueOf(String.valueOf(orderId)));
            map.put("code", 200);
            map.put("message", "订单已取消");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }
}
