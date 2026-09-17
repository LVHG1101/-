package com.example.secondhand.repository;

import com.example.secondhand.entity.Footprint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FootprintRepository extends JpaRepository<Footprint, Long> {
    // id 倒序即最近浏览在前
    List<Footprint> findByUserIdOrderByIdDesc(Long userId);

    Optional<Footprint> findByUserIdAndGoodsId(Long userId, Long goodsId);

    void deleteByUserIdAndGoodsId(Long userId, Long goodsId);

    void deleteByUserId(Long userId);
}
