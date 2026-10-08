package com.example.secondhand.repository;

import com.example.secondhand.entity.ExchangeGoods;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExchangeRepository extends JpaRepository<ExchangeGoods, Long> {
    List<ExchangeGoods> findByStatusOrderByIdDesc(String status);
    List<ExchangeGoods> findByUserIdOrderByIdDesc(Long userId);
}
