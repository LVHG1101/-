package com.example.secondhand.controller;

import com.example.secondhand.entity.User;
import com.example.secondhand.service.UserService;
import com.example.secondhand.util.JwtTokenUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @PostMapping("/register")
    public Map<String, Object> register(@RequestBody User user) {
        Map<String, Object> map = new HashMap<>();
        try {
            UserDetails userDetails = userService.register(user);
            map.put("message", "注册成功");
            map.put("code", 200);
        } catch (Exception e) {
            map.put("message", e.getMessage());
            map.put("code", 400);
        }
        return map;
    }

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody Map<String, String> loginData) {
        Map<String, Object> map = new HashMap<>();
        try {
            String username = loginData.get("username");
            String password = loginData.get("password");
            UserDetails userDetails = userService.login(username, password);
            String token = jwtTokenUtil.generateToken(userDetails);
            map.put("message", "登录成功");
            map.put("code", 200);
            map.put("token", token);
            map.put("username", userDetails.getUsername());
            if (userDetails instanceof User) {
                map.put("nickname", ((User) userDetails).getNickname());
            }
        } catch (Exception e) {
            map.put("message", e.getMessage());
            map.put("code", 400);
        }
        return map;
    }
}
