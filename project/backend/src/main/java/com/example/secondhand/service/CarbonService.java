package com.example.secondhand.service;

import com.example.secondhand.entity.CarbonPoint;
import com.example.secondhand.entity.User;
import com.example.secondhand.repository.CarbonPointRepository;
import com.example.secondhand.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class CarbonService {

    @Autowired
    private CarbonPointRepository carbonPointRepository;

    @Autowired
    private UserRepository userRepository;

    public int balance(User user) {
        if (user == null || user.getCarbonPoints() == null) {
            return 0;
        }
        return user.getCarbonPoints();
    }

    public List<CarbonPoint> records(Long userId) {
        return carbonPointRepository.findByUserIdOrderByIdDesc(userId);
    }

    /** 增加碳积分（正数为获得，负数为消费），同时记录流水 */
    @Transactional
    public void add(Long userId, int delta, String reason) {
        if (userId == null || delta == 0) {
            return;
        }
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return;
        }
        int before = balance(user);
        int after = Math.max(0, before + delta);
        user.setCarbonPoints(after);
        userRepository.save(user);

        CarbonPoint point = new CarbonPoint();
        point.setUserId(userId);
        point.setUsername(user.getUsername());
        point.setDelta(after - before);
        point.setReason(reason == null || reason.isBlank() ? "碳积分变动" : reason);
        point.setCreateTime(Instant.now().toString());
        carbonPointRepository.save(point);
    }
}
