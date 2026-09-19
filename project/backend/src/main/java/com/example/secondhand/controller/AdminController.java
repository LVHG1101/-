package com.example.secondhand.controller;

import com.example.secondhand.entity.Order;
import com.example.secondhand.entity.ServiceItem;
import com.example.secondhand.entity.User;
import com.example.secondhand.repository.UserRepository;
import com.example.secondhand.service.AfterSaleService;
import com.example.secondhand.service.CreditService;
import com.example.secondhand.service.OrderService;
import com.example.secondhand.service.ServiceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理端接口。整个 /admin/** 已在 SecurityConfiguration 中限定为 admin 角色。
 */
@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AfterSaleService afterSaleService;

    @Autowired
    private ServiceService serviceService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private CreditService creditService;

    @Autowired
    private UserRepository userRepository;

    /** 当前操作的管理员账号，用于信誉分变动流水的 operator 字段 */
    private String currentAdminName() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof User) {
            return ((User) auth.getPrincipal()).getUsername();
        }
        return "";
    }

    private Map<String, Object> ok(String message, Object data) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", 200);
        map.put("message", message);
        if (data != null) {
            map.put("data", data);
        }
        return map;
    }

    private Map<String, Object> fail(String message) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", 400);
        map.put("message", message);
        return map;
    }

    // ---------------- 售后管理 ----------------

    @GetMapping("/after-sales")
    public Map<String, Object> afterSales(@RequestParam(required = false) String status) {
        return ok("查询成功", afterSaleService.listAll(status));
    }

    @PostMapping("/after-sale/handle")
    public Map<String, Object> handleAfterSale(@RequestBody Map<String, Object> body) {
        Object id = body.get("id");
        if (id == null) {
            return fail("id 不能为空");
        }
        Object approve = body.get("approve");
        boolean pass = approve == null || Boolean.parseBoolean(String.valueOf(approve));
        Object remark = body.get("remark");
        try {
            afterSaleService.handle(Long.valueOf(String.valueOf(id)), pass,
                    remark == null ? "" : String.valueOf(remark));
            return ok(pass ? "已同意售后" : "已驳回售后", null);
        } catch (Exception e) {
            return fail(e.getMessage());
        }
    }

    // ---------------- 服务项管理 ----------------

    @GetMapping("/services")
    public Map<String, Object> services() {
        return ok("查询成功", serviceService.listAllServices());
    }

    @PostMapping("/service/save")
    public Map<String, Object> saveService(@RequestBody ServiceItem body) {
        try {
            return ok("保存成功", serviceService.saveService(body));
        } catch (Exception e) {
            return fail(e.getMessage());
        }
    }

    @PostMapping("/service/toggle")
    public Map<String, Object> toggleService(@RequestBody Map<String, Object> body) {
        Object id = body.get("id");
        if (id == null) {
            return fail("id 不能为空");
        }
        try {
            ServiceItem item = serviceService.toggleService(Long.valueOf(String.valueOf(id)));
            return ok(Boolean.TRUE.equals(item.getEnabled()) ? "已上架" : "已下架", item);
        } catch (Exception e) {
            return fail(e.getMessage());
        }
    }

    @PostMapping("/service/delete")
    public Map<String, Object> deleteService(@RequestBody Map<String, Object> body) {
        Object id = body.get("id");
        if (id == null) {
            return fail("id 不能为空");
        }
        try {
            serviceService.deleteService(Long.valueOf(String.valueOf(id)));
            return ok("已删除", null);
        } catch (Exception e) {
            return fail(e.getMessage());
        }
    }

    // ---------------- 预约单管理 ----------------

    @GetMapping("/service-orders")
    public Map<String, Object> serviceOrders(@RequestParam(required = false) String status) {
        return ok("查询成功", serviceService.listAllOrders(status));
    }

    @PostMapping("/service-order/status")
    public Map<String, Object> updateServiceOrderStatus(@RequestBody Map<String, Object> body) {
        Object id = body.get("id");
        Object status = body.get("status");
        if (id == null || status == null) {
            return fail("id 与 status 不能为空");
        }
        try {
            serviceService.updateOrderStatus(Long.valueOf(String.valueOf(id)), String.valueOf(status));
            return ok("已更新", null);
        } catch (Exception e) {
            return fail(e.getMessage());
        }
    }

    // ---------------- 订单总览 ----------------

    @GetMapping("/orders")
    public Map<String, Object> orders() {
        List<Order> list = orderService.listAllOrders();
        return ok("查询成功", list);
    }

    // ---------------- 用户信誉管理 ----------------

    /** 用户列表（含信誉分）。注意不要把 User 实体直接返回，会泄露密码哈希 */
    @GetMapping("/users")
    public Map<String, Object> users() {
        List<Map<String, Object>> result = new ArrayList<>();
        for (User u : userRepository.findAll()) {
            int score = creditService.scoreOf(u);
            Map<String, Object> m = new HashMap<>();
            m.put("id", u.getId());
            m.put("username", u.getUsername());
            m.put("nickname", u.getNickname());
            m.put("role", u.getRole() != null && u.getRole().startsWith("ROLE_")
                    ? u.getRole().substring(5) : u.getRole());
            m.put("creditScore", score);
            m.put("creditLevel", CreditService.levelOf(score));
            m.put("lowCredit", score < CreditService.LOW_THRESHOLD);
            result.add(m);
        }
        return ok("查询成功", result);
    }

    /** 管理员手动设定某用户的信誉分 */
    @PostMapping("/credit/set")
    public Map<String, Object> setCredit(@RequestBody Map<String, Object> body) {
        Object userId = body.get("userId");
        Object score = body.get("score");
        if (userId == null || score == null) {
            return fail("userId 与 score 不能为空");
        }
        Object reason = body.get("reason");
        try {
            creditService.setScore(Long.valueOf(String.valueOf(userId)),
                    Integer.parseInt(String.valueOf(score)),
                    reason == null ? null : String.valueOf(reason),
                    currentAdminName());
            return ok("信誉分已更新", null);
        } catch (Exception e) {
            return fail(e.getMessage());
        }
    }

    /** 信誉分变动流水（全部用户） */
    @GetMapping("/credit-records")
    public Map<String, Object> creditRecords() {
        return ok("查询成功", creditService.allRecords());
    }
}
