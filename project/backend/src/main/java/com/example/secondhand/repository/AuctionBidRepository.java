package com.example.secondhand.repository;

import com.example.secondhand.entity.AuctionBid;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AuctionBidRepository extends JpaRepository<AuctionBid, Long> {
    List<AuctionBid> findByUserIdOrderByIdDesc(Long userId);
    List<AuctionBid> findByAuctionIdOrderByPriceDesc(Long auctionId);
}
