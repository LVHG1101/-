package com.example.secondhand.repository;

import com.example.secondhand.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    List<Favorite> findByUserIdOrderByIdDesc(Long userId);
    Optional<Favorite> findByUserIdAndGoodsId(Long userId, Long goodsId);
    void deleteByUserIdAndGoodsId(Long userId, Long goodsId);
}
