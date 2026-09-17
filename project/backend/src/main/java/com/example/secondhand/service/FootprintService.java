package com.example.secondhand.service;

import com.example.secondhand.entity.Footprint;
import com.example.secondhand.repository.FootprintRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class FootprintService {

    private static final int MAX_FOOTPRINTS = 50;

    @Autowired
    private FootprintRepository footprintRepository;

    public List<Footprint> list(Long userId) {
        return footprintRepository.findByUserIdOrderByIdDesc(userId);
    }

    /** 记录一次浏览：同一商品只保留最新一条，总数超过上限则丢弃最旧的 */
    @Transactional
    public void record(Long userId, Footprint incoming) {
        footprintRepository.deleteByUserIdAndGoodsId(userId, incoming.getGoodsId());

        Footprint footprint = new Footprint();
        footprint.setUserId(userId);
        footprint.setGoodsId(incoming.getGoodsId());
        footprint.setName(incoming.getName());
        footprint.setPrice(incoming.getPrice());
        footprint.setImage(incoming.getImage());
        footprint.setVisitTime(incoming.getVisitTime() == null ? Instant.now().toString() : incoming.getVisitTime());
        footprintRepository.save(footprint);

        List<Footprint> all = footprintRepository.findByUserIdOrderByIdDesc(userId);
        if (all.size() > MAX_FOOTPRINTS) {
            footprintRepository.deleteAll(all.subList(MAX_FOOTPRINTS, all.size()));
        }
    }

    @Transactional
    public void remove(Long userId, Long goodsId) {
        footprintRepository.deleteByUserIdAndGoodsId(userId, goodsId);
    }

    @Transactional
    public void clear(Long userId) {
        footprintRepository.deleteByUserId(userId);
    }
}
