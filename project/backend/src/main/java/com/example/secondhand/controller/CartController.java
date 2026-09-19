package com.example.secondhand.controller;

import com.example.secondhand.entity.User;
import com.example.secondhand.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/cart")
public class CartController {

    @Autowired
    private CartService cartService;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
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
            map.put("code", 200);
            map.put("message", "已加入购物车");
            map.put("data", cartService.addToCart(user.getId(), Long.valueOf(String.valueOf(raw))));
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
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", cartService.listCart(user.getId()));
        return map;
    }

    @PostMapping("/update")
    public Map<String, Object> update(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Long id = Long.valueOf(String.valueOf(body.get("id")));
            Integer count = body.get("count") == null ? null : Integer.valueOf(String.valueOf(body.get("count")));
            Boolean selected = body.get("selected") == null ? null : Boolean.valueOf(String.valueOf(body.get("selected")));
            cartService.updateCart(user.getId(), id, count, selected);
            map.put("code", 200);
            map.put("message", "更新成功");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/delete")
    public Map<String, Object> delete(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Long id = Long.valueOf(String.valueOf(body.get("id")));
            cartService.deleteCart(user.getId(), id);
            map.put("code", 200);
            map.put("message", "已删除");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/clear")
    public Map<String, Object> clear() {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        cartService.clearCart(user.getId());
        map.put("code", 200);
        map.put("message", "已清空");
        return map;
    }
}
