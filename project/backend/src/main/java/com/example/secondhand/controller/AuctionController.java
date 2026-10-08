package com.example.secondhand.controller;

import com.example.secondhand.entity.AuctionGoods;
import com.example.secondhand.entity.User;
import com.example.secondhand.service.AuctionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auction")
public class AuctionController {

    @Autowired
    private AuctionService auctionService;

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
        map.put("data", auctionService.listOngoing());
        return map;
    }

    @PostMapping("/publish")
    public Map<String, Object> publish(@RequestBody AuctionGoods body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            map.put("code", 200);
            map.put("message", "发布成功");
            map.put("data", auctionService.publish(body, user.getId()));
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", e.getMessage());
        }
        return map;
    }

    @PostMapping("/bid")
    public Map<String, Object> bid(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        User user = currentUser();
        if (user == null) {
            map.put("code", 401);
            map.put("message", "未登录");
            return map;
        }
        try {
            Object auctionId = body.get("auctionId");
            Object price = body.get("price");
            if (auctionId == null || price == null) {
                map.put("code", 400);
                map.put("message", "auctionId 和 price 不能为空");
                return map;
            }
            map.put("code", 200);
            map.put("message", "出价成功");
            map.put("data", auctionService.bid(
                    Long.valueOf(String.valueOf(auctionId)),
                    user.getId(),
                    Double.valueOf(String.valueOf(price))));
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
        data.put("auctions", auctionService.myAuctions(user.getId()));
        data.put("bids", auctionService.myBids(user.getId()));
        map.put("code", 200);
        map.put("message", "查询成功");
        map.put("data", data);
        return map;
    }
}
