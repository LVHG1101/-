package com.example.secondhand.repository;

import com.example.secondhand.entity.ExchangeApply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExchangeApplyRepository extends JpaRepository<ExchangeApply, Long> {
    List<ExchangeApply> findByUserIdOrderByIdDesc(Long userId);
    List<ExchangeApply> findByExchangeIdOrderByIdDesc(Long exchangeId);
}
