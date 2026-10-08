package com.example.secondhand.service;

import com.example.secondhand.entity.ExchangeApply;
import com.example.secondhand.entity.ExchangeGoods;
import com.example.secondhand.entity.User;
import com.example.secondhand.repository.ExchangeApplyRepository;
import com.example.secondhand.repository.ExchangeRepository;
import com.example.secondhand.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
public class ExchangeService {

    @Autowired
    private ExchangeRepository exchangeRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ExchangeApplyRepository exchangeApplyRepository;

    public List<ExchangeGoods> listOngoing() {
        return exchangeRepository.findByStatusOrderByIdDesc("ONGOING");
    }

    public ExchangeGoods publish(ExchangeGoods e, Long userId) {
        e.setId(null);
        e.setStatus("ONGOING");
        e.setUserId(userId);
        if (e.getOwner() == null || e.getOwner().isBlank()) {
            User user = userRepository.findById(userId).orElse(null);
            if (user != null) {
                e.setOwner(user.getNickname() == null ? user.getUsername() : user.getNickname());
            }
        }
        return exchangeRepository.save(e);
    }

    /** 申请换物 */
    public ExchangeApply apply(Long exchangeId, Long userId, String message) {
        ExchangeGoods e = exchangeRepository.findById(exchangeId)
                .orElseThrow(() -> new IllegalArgumentException("换物信息不存在"));
        if (e.getUserId() != null && e.getUserId().equals(userId)) {
            throw new IllegalArgumentException("不能申请自己的换物");
        }
        ExchangeApply apply = new ExchangeApply();
        apply.setExchangeId(exchangeId);
        apply.setUserId(userId);
        apply.setMessage(message);
        apply.setStatus("PENDING");
        apply.setCreateTime(Instant.now().toString());
        return exchangeApplyRepository.save(apply);
    }

    /** 我发布的换物 */
    public List<ExchangeGoods> myPublished(Long userId) {
        return exchangeRepository.findByUserIdOrderByIdDesc(userId);
    }

    /** 我申请的换物 */
    public List<ExchangeApply> myApplies(Long userId) {
        return exchangeApplyRepository.findByUserIdOrderByIdDesc(userId);
    }
}
