package com.example.secondhand.controller;

import com.example.secondhand.entity.ExchangeGoods;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.ExchangeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/exchange")
public class ExchangeController {

    @Autowired
    private ExchangeService exchangeService;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

    @GetMapping("/list")
    public Map<String, Object> list() {
        Map<String, Object> map = new HashMap<>();
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", exchangeService.listOngoing());
        return map;
    }

    @PostMapping("/publish")
    public Map<String, Object> publish(@RequestBody ExchangeGoods body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            if (body.getName() == null || body.getName().isBlank()) {
                map.put("code", 400);
                map.put("message", "换出物品不能为空");
                return map;
            }
            if (body.getWantName() == null || body.getWantName().isBlank()) {
                map.put("code", 400);
                map.put("message", "想换物品不能为空");
                return map;
            }
            map.put("code", 200);
            map.put("message", "发布成功");
            map.put("data", exchangeService.publish(body, user.getId()));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/apply")
    public Map<String, Object> apply(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Object exchangeId = body.get("exchangeId");
            if (exchangeId == null) {
                map.put("code", 400);
                map.put("message", "exchangeId 不能为空");
                return map;
            }
            String message = body.get("message") == null ? "" : String.valueOf(body.get("message"));
            map.put("code", 200);
            map.put("message", "申请成功");
            map.put("data", exchangeService.apply(
                    Long.valueOf(String.valueOf(exchangeId)), user.getId(), message));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @GetMapping("/mine")
    public Map<String, Object> mine() {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        Map<String, Object> data = new HashMap<>();
        data.put("published", exchangeService.myPublished(user.getId()));
        data.put("applies", exchangeService.myApplies(user.getId()));
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", data);
        return map;
    }
}
