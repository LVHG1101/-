package com.example.secondhand.controller;

import com.example.secondhand.entity.User;
import com.example.secondhand.service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/favorite")
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

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
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", favoriteService.list(user.getId()));
        return map;
    }

    @PostMapping("/add")
    public Map<String, Object> add(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Object raw = body.get("goodsId");
            if (raw == null) {
                map.put("code", 400);
                map.put("message", "goodsId 不能为空");
                return map;
            }
            favoriteService.add(user.getId(), Long.valueOf(String.valueOf(raw)));
            map.put("code", 200);
            map.put("message", "收藏成功");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/remove")
    public Map<String, Object> remove(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Object raw = body.get("goodsId");
            if (raw == null) {
                map.put("code", 400);
                map.put("message", "goodsId 不能为空");
                return map;
            }
            favoriteService.remove(user.getId(), Long.valueOf(String.valueOf(raw)));
            map.put("code", 200);
            map.put("message", "已取消收藏");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }
}
