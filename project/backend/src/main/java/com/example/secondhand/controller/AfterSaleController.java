package com.example.secondhand.controller;

import com.example.secondhand.entity.User;
import com.example.secondhand.service.AfterSaleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/after-sale")
public class AfterSaleController {

    @Autowired
    private AfterSaleService afterSaleService;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

    /** 用户对某个订单发起售后申请 */
    @PostMapping("/apply")
    public Map<String, Object> apply(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        Object rawId = body.get("orderId");
        if (rawId == null) {
            map.put("code", 400);
            map.put("message", "orderId 不能为空");
            return map;
        }
        Object reason = body.get("reason");
        try {
            map.put("code", 200);
            map.put("message", "售后申请已提交，等待平台处理");
            map.put("data", afterSaleService.apply(user, Long.valueOf(String.valueOf(rawId)),
                    reason == null ? null : String.valueOf(reason)));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    /** 我的售后申请记录 */
    @GetMapping("/my")
    public Map<String, Object> my() {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", afterSaleService.listMine(user.getId()));
        return map;
    }
}
