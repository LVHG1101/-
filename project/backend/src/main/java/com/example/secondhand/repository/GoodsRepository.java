package com.example.secondhand.repository;

import com.example.secondhand.entity.Goods;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GoodsRepository extends JpaRepository<Goods, Long> {
    List<Goods> findByEnabledTrueAndCategoryIdOrderByIdAsc(Long categoryId);
    List<Goods> findByEnabledTrueOrderByIdAsc();
}
