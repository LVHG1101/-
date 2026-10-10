package com.example.secondhand.service;

import com.example.secondhand.entity.Favorite;
import com.example.secondhand.entity.Goods;
import com.example.secondhand.repository.FavoriteRepository;
import com.example.secondhand.repository.GoodsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
public class FavoriteService {

    @Autowired
    private FavoriteRepository favoriteRepository;

    @Autowired
    private GoodsRepository goodsRepository;

    public List<Favorite> list(Long userId) {
        return favoriteRepository.findByUserIdOrderByIdDesc(userId);
    }

    @Transactional
    public Favorite add(Long userId, Long goodsId) {
        if (goodsId == null) {
            throw new IllegalArgumentException("goodsId 不能为空");
        }
        if (favoriteRepository.findByUserIdAndGoodsId(userId, goodsId).isPresent()) {
            throw new IllegalArgumentException("已收藏过该商品");
        }
        Goods goods = goodsRepository.findById(goodsId)
                .orElseThrow(() -> new IllegalArgumentException("商品不存在"));
        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setGoodsId(goodsId);
        favorite.setName(goods.getName());
        favorite.setPrice(goods.getPrice());
        favorite.setImage(goods.getImage());
        favorite.setCreateTime(Instant.now().toString());
        return favoriteRepository.save(favorite);
    }

    @Transactional
    public void remove(Long userId, Long goodsId) {
        favoriteRepository.deleteByUserIdAndGoodsId(userId, goodsId);
    }
}
