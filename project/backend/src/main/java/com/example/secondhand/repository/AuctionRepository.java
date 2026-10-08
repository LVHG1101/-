package com.example.secondhand.repository;

import com.example.secondhand.entity.AuctionGoods;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuctionRepository extends JpaRepository<AuctionGoods, Long> {
    List<AuctionGoods> findByStatusOrderByIdAsc(String status);
    List<AuctionGoods> findAllByOrderByIdAsc();
    List<AuctionGoods> findByUserIdOrderByIdDesc(Long userId);
}
