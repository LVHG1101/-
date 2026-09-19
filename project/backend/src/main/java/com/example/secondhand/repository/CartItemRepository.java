package com.example.secondhand.repository;

import com.example.secondhand.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    List<CartItem> findByUserIdOrderByIdDesc(Long userId);
    java.util.Optional<CartItem> findByUserIdAndGoodsId(Long userId, Long goodsId);
}
