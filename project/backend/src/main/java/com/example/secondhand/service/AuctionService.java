package com.example.secondhand.service;

import com.example.secondhand.entity.AuctionBid;
import com.example.secondhand.entity.AuctionGoods;
import com.example.secondhand.repository.AuctionBidRepository;
import com.example.secondhand.repository.AuctionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class AuctionService {

    @Autowired
    private AuctionRepository auctionRepository;

    @Autowired
    private AuctionBidRepository auctionBidRepository;

    public List<AuctionGoods> listOngoing() {
        long now = System.currentTimeMillis();
        for (AuctionGoods a : auctionRepository.findByStatusOrderByIdAsc("ONGOING")) {
            if (a.getEndTime() != null && a.getEndTime() < now) {
                a.setStatus("ENDED");
                auctionRepository.save(a);
            }
        }
        return auctionRepository.findByStatusOrderByIdAsc("ONGOING");
    }

    public AuctionGoods publish(AuctionGoods a, Long userId) {
        if (a.getName() == null || a.getName().isBlank()) {
            throw new IllegalArgumentException("拍卖品名称不能为空");
        }
        if (a.getStartPrice() == null || a.getStartPrice() <= 0) {
            throw new IllegalArgumentException("起拍价必须大于 0");
        }
        a.setId(null);
        a.setBidCount(0);
        a.setCurrentPrice(a.getStartPrice());
        a.setStatus("ONGOING");
        a.setUserId(userId);
        return auctionRepository.save(a);
    }

    @Transactional
    public AuctionGoods bid(Long auctionId, Long userId, Double price) {
        AuctionGoods a = auctionRepository.findById(auctionId)
                .orElseThrow(() -> new IllegalArgumentException("拍卖品不存在"));
        if (!"ONGOING".equals(a.getStatus())) {
            throw new IllegalArgumentException("拍卖已结束");
        }
        if (a.getEndTime() != null && a.getEndTime() < System.currentTimeMillis()) {
            a.setStatus("ENDED");
            auctionRepository.save(a);
            throw new IllegalArgumentException("拍卖已结束");
        }
        if (price == null || price <= a.getCurrentPrice()) {
            throw new IllegalArgumentException("出价必须高于当前价");
        }
        a.setCurrentPrice(price);
        a.setBidCount(a.getBidCount() + 1);
        auctionRepository.save(a);

        AuctionBid bid = new AuctionBid();
        bid.setAuctionId(auctionId);
        bid.setUserId(userId);
        bid.setPrice(price);
        bid.setCreateTime(Instant.now().toString());
        auctionBidRepository.save(bid);
        return a;
    }

    public List<AuctionGoods> myAuctions(Long userId) {
        return auctionRepository.findByUserIdOrderByIdDesc(userId);
    }

    public List<AuctionBid> myBids(Long userId) {
        return auctionBidRepository.findByUserIdOrderByIdDesc(userId);
    }
}
