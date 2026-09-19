package com.example.secondhand.service;

import com.example.secondhand.entity.CreditRecord;
import com.example.secondhand.entity.User;
import com.example.secondhand.repository.CreditRecordRepository;
import com.example.secondhand.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

/**
 * 信誉分：0~100，默认 100。低于 LOW_THRESHOLD 视为低信誉，禁止发布新商品。
 * 变动来源分两类：SYSTEM（业务规则自动触发）与 ADMIN（管理员手动调整）。
 */
@Service
public class CreditService {

    public static final int DEFAULT_SCORE = 100;
    public static final int MIN_SCORE = 0;
    public static final int MAX_SCORE = 100;
    /** 低于这个分数算低信誉 */
    public static final int LOW_THRESHOLD = 60;

    /** 售后成立（管理员同意退款）→ 卖家货不对板，扣分 */
    public static final int DEDUCT_AFTER_SALE_APPROVED = 10;
    /** 售后被驳回 → 申请人恶意申请，扣分 */
    public static final int DEDUCT_AFTER_SALE_REJECTED = 5;
    /** 订单正常完成 → 买卖双方加分 */
    public static final int BONUS_ORDER_COMPLETED = 2;

    public static final String SOURCE_SYSTEM = "SYSTEM";
    public static final String SOURCE_ADMIN = "ADMIN";

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CreditRecordRepository creditRecordRepository;

    /** 老数据没有该字段时为 null，统一按默认分处理 */
    public int scoreOf(User user) {
        if (user == null || user.getCreditScore() == null) {
            return DEFAULT_SCORE;
        }
        return user.getCreditScore();
    }

    public boolean isLowCredit(User user) {
        return scoreOf(user) < LOW_THRESHOLD;
    }

    public static String levelOf(int score) {
        if (score >= 90) return "优秀";
        if (score >= 75) return "良好";
        if (score >= LOW_THRESHOLD) return "一般";
        return "较差";
    }

    /** 按增量调整，分数被夹在 0~100 之间；没有实际变化时不记流水 */
    @Transactional
    public void change(Long userId, int delta, String reason, String source, String operator) {
        if (userId == null || delta == 0) {
            return;
        }
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return;
        }
        int before = scoreOf(user);
        int after = clamp(before + delta);
        if (after == before) {
            return;
        }
        user.setCreditScore(after);
        userRepository.save(user);
        saveRecord(user, after - before, before, after, reason, source, operator);
    }

    /** 管理员直接设定分数 */
    @Transactional
    public void setScore(Long userId, int target, String reason, String operator) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("用户不存在"));
        int before = scoreOf(user);
        int after = clamp(target);
        user.setCreditScore(after);
        userRepository.save(user);
        if (after != before) {
            saveRecord(user, after - before, before, after,
                    reason == null || reason.isBlank() ? "管理员手动调整" : reason,
                    SOURCE_ADMIN, operator);
        }
    }

    public List<CreditRecord> records(Long userId) {
        return creditRecordRepository.findByUserIdOrderByIdDesc(userId);
    }

    public List<CreditRecord> allRecords() {
        return creditRecordRepository.findAllByOrderByIdDesc();
    }

    private int clamp(int value) {
        return Math.max(MIN_SCORE, Math.min(MAX_SCORE, value));
    }

    private void saveRecord(User user, int delta, int before, int after,
                            String reason, String source, String operator) {
        CreditRecord record = new CreditRecord();
        record.setUserId(user.getId());
        record.setUsername(user.getUsername());
        record.setDelta(delta);
        record.setScoreBefore(before);
        record.setScoreAfter(after);
        record.setReason(reason);
        record.setSource(source);
        record.setOperator(operator == null ? "" : operator);
        record.setCreateTime(Instant.now().toString());
        creditRecordRepository.save(record);
    }
}
