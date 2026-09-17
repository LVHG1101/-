package com.example.secondhand.controller;

import com.example.secondhand.entity.ServiceOrder;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.ServiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/service")
public class ServiceController {

    @Autowired
    private ServiceService serviceService;

    /** TokenFilter 鉴权通过后会把 User 实体放进 SecurityContext */
    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

    /** 服务项目列表 */
    @GetMapping("/list")
    public Map<String, Object> list() {
        Map<String, Object> map = new HashMap<>();
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", serviceService.listServices());
        return map;
    }

    /** 服务详情 */
    @GetMapping("/detail")
    public Map<String, Object> detail(@RequestParam Long id) {
        Map<String, Object> map = new HashMap<>();
        try {
            map.put("code", 200);
            map.put("message", "查询成功");
            map.put("data", serviceService.getService(id));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    /** 提交服务预约 */
    @PostMapping("/order")
    public Map<String, Object> createOrder(@RequestBody ServiceOrder body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            ServiceOrder order = serviceService.createOrder(user.getId(), body);
            map.put("code", 200);
            map.put("message", "预约成功");
            map.put("data", order);
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    /** 我的服务预约 */
    @GetMapping("/orders")
    public Map<String, Object> myOrders() {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        List<ServiceOrder> list = serviceService.myOrders(user.getId());
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", list);
        return map;
    }

    /** 取消预约 */
    @PostMapping("/cancel")
    public Map<String, Object> cancel(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        Object raw = body.get("orderId");
        if (raw == null) {
            map.put("code", 400);
            map.put("message", "orderId 不能为空");
            return map;
        }
        try {
            serviceService.cancelOrder(user.getId(), Long.valueOf(String.valueOf(raw)));
            map.put("code", 200);
            map.put("message", "已取消预约");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }
}
