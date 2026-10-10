package com.example.secondhand.controller;

import com.example.secondhand.entity.User;
import com.example.secondhand.service.CarbonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/carbon")
public class CarbonController {

    @Autowired
    private CarbonService carbonService;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

    /** 我的碳积分余额与流水 */
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
        map.put("balance", carbonService.balance(user));
        map.put("records", carbonService.records(user.getId()));
        return map;
    }
}
