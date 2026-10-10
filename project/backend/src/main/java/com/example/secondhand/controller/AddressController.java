package com.example.secondhand.controller;

import com.example.secondhand.entity.Address;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.AddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/address")
public class AddressController {

    @Autowired
    private AddressService addressService;

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
        map.put("data", addressService.list(user.getId()));
        return map;
    }

    @PostMapping("/save")
    public Map<String, Object> save(@RequestBody Address body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            map.put("code", 200);
            map.put("message", "保存成功");
            map.put("data", addressService.save(user.getId(), body));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/default")
    public Map<String, Object> setDefault(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Object raw = body.get("addressId");
            if (raw == null) {
                map.put("code", 400);
                map.put("message", "addressId 不能为空");
                return map;
            }
            addressService.setDefault(user.getId(), Long.valueOf(String.valueOf(raw)));
            map.put("code", 200);
            map.put("message", "已设为默认");
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
            Object raw = body.get("addressId");
            if (raw == null) {
                map.put("code", 400);
                map.put("message", "addressId 不能为空");
                return map;
            }
            addressService.delete(user.getId(), Long.valueOf(String.valueOf(raw)));
            map.put("code", 200);
            map.put("message", "删除成功");
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }
}
