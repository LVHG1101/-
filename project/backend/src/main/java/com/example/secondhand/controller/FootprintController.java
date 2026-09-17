package com.example.secondhand.controller;

import com.example.secondhand.entity.Footprint;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.FootprintService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/footprint")
public class FootprintController {

    @Autowired
    private FootprintService footprintService;

    /** TokenFilter 鉴权通过后会把 User 实体放进 SecurityContext */
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
        List<Footprint> list = footprintService.list(user.getId());
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", list);
        return map;
    }

    @PostMapping("/add")
    public Map<String, Object> add(@RequestBody Footprint footprint) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        if (footprint.getGoodsId() == null) {
            map.put("code", 400);
            map.put("message", "goodsId 不能为空");
            return map;
        }
        try {
            footprintService.record(user.getId(), footprint);
            map.put("code", 200);
            map.put("message", "记录成功");
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
        Object raw = body.get("goodsId");
        if (raw == null) {
            map.put("code", 400);
            map.put("message", "goodsId 不能为空");
            return map;
        }
        try {
            footprintService.remove(user.getId(), Long.valueOf(String.valueOf(raw)));
            map.put("code", 200);
            map.put("message", "删除成功");
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
        footprintService.clear(user.getId());
        map.put("code", 200);
        map.put("message", "已清空");
        return map;
    }
}
