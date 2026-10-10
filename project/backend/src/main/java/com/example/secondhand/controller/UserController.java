package com.example.secondhand.controller;

import com.example.secondhand.entity.User;
import com.example.secondhand.repository.UserRepository;
import com.example.secondhand.service.CreditService;
import com.example.secondhand.service.UserService;
import com.example.secondhand.util.JwtTokenUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
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

    @Autowired
    private CreditService creditService;

    @Autowired
    private UserRepository userRepository;

    private User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof User) {
            return (User) authentication.getPrincipal();
        }
        return null;
    }

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
                // loadUserByUsername 会把角色补成 ROLE_xxx，这里去掉前缀返回给前端
                String role = ((User) userDetails).getRole();
                if (role != null && role.startsWith("ROLE_")) {
                    role = role.substring(5);
                }
                map.put("role", role == null ? "user" : role);
                int score = creditService.scoreOf((User) userDetails);
                map.put("creditScore", score);
                map.put("creditLevel", CreditService.levelOf(score));
            }
        } catch (Exception e) {
            map.put("message", e.getMessage());
            map.put("code", 400);
        }
        return map;
    }

    /** 我的信誉分与变动明细 */
    @GetMapping("/credit")
    public Map<String, Object> myCredit() {
        Map<String, Object> map = new HashMap<>();
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof User)) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        User user = (User) authentication.getPrincipal();
        int score = creditService.scoreOf(user);
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("score", score);
        map.put("level", CreditService.levelOf(score));
        map.put("lowCredit", score < CreditService.LOW_THRESHOLD);
        map.put("threshold", CreditService.LOW_THRESHOLD);
        map.put("records", creditService.records(user.getId()));
        return map;
    }

    /** 当前用户个人资料 */
    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", profileOf(user));
        return map;
    }

    /** 提交实名认证 */
    @PostMapping("/realname")
    public Map<String, Object> realName(@RequestBody Map<String, String> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        String realName = body.getOrDefault("realName", "").trim();
        String idCard = body.getOrDefault("idCard", "").trim();
        if (realName.isEmpty() || idCard.isEmpty()) {
            map.put("code", 400);
            map.put("message", "姓名和身份证号不能为空");
            return map;
        }
        user.setRealName(realName);
        user.setIdCard(idCard);
        user.setVerified(true);
        userRepository.save(user);
        map.put("code", 200);
        map.put("message", "实名认证成功");
        map.put("data", profileOf(user));
        return map;
    }

    private Map<String, Object> profileOf(User user) {
        Map<String, Object> p = new HashMap<>();
        p.put("username", user.getUsername());
        p.put("nickname", user.getNickname());
        String role = user.getRole();
        if (role != null && role.startsWith("ROLE_")) {
            role = role.substring(5);
        }
        p.put("role", role == null ? "user" : role);
        p.put("creditScore", creditService.scoreOf(user));
        p.put("creditLevel", CreditService.levelOf(creditService.scoreOf(user)));
        p.put("verified", Boolean.TRUE.equals(user.getVerified()));
        p.put("realName", maskIdCardName(user.getRealName()));
        p.put("idCard", maskIdCard(user.getIdCard()));
        return p;
    }

    private String maskIdCardName(String name) {
        if (name == null || name.isEmpty()) return "";
        if (name.length() <= 1) return name;
        return name.substring(0, 1) + "**";
    }

    private String maskIdCard(String idCard) {
        if (idCard == null || idCard.length() < 8) return idCard == null ? "" : idCard;
        return idCard.substring(0, 4) + "**********" + idCard.substring(idCard.length() - 4);
    }
}
