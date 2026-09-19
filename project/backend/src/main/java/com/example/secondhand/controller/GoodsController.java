package com.example.secondhand.controller;

import com.example.secondhand.entity.Goods;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/goods")
public class GoodsController {

    @Autowired
    private CategoryService categoryService;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

    @GetMapping("/list")
    public Map<String, Object> list(@RequestParam(required = false) Long categoryId) {
        Map<String, Object> map = new HashMap<>();
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", categoryService.listGoods(categoryId));
        return map;
    }

    @GetMapping("/detail")
    public Map<String, Object> detail(@RequestParam Long id) {
        Map<String, Object> map = new HashMap<>();
        try {
            map.put("code", 200);
            map.put("message", "查询成功");
            map.put("data", categoryService.getGoods(id));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/publish")
    public Map<String, Object> publish(@RequestBody Goods body) {
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
                map.put("message", "商品名称不能为空");
                return map;
            }
            if (body.getPrice() == null) {
                map.put("code", 400);
                map.put("message", "价格不能为空");
                return map;
            }
            Goods goods = categoryService.publishGoods(body);
            map.put("code", 200);
            map.put("message", "发布成功");
            map.put("data", goods);
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }
}
