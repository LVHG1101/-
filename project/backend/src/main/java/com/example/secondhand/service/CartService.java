package com.example.secondhand.service;

import com.example.secondhand.entity.CartItem;
import com.example.secondhand.entity.Goods;
import com.example.secondhand.repository.CartItemRepository;
import com.example.secondhand.repository.GoodsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CartService {

    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private GoodsRepository goodsRepository;

    @Transactional
    public CartItem addToCart(Long userId, Long goodsId) {
        Goods goods = goodsRepository.findById(goodsId)
                .orElseThrow(() -> new IllegalArgumentException("商品不存在"));
        CartItem existing = cartItemRepository.findByUserIdAndGoodsId(userId, goodsId).orElse(null);
        if (existing != null) {
            existing.setCount(existing.getCount() + 1);
            return cartItemRepository.save(existing);
        }
        CartItem item = new CartItem();
        item.setUserId(userId);
        item.setGoodsId(goodsId);
        item.setName(goods.getName());
        item.setPrice(goods.getPrice());
        item.setImage(goods.getImage());
        item.setCount(1);
        item.setSelected(true);
        return cartItemRepository.save(item);
    }

    public List<CartItem> listCart(Long userId) {
        return cartItemRepository.findByUserIdOrderByIdDesc(userId);
    }

    @Transactional
    public void updateCart(Long userId, Long id, Integer count, Boolean selected) {
        CartItem item = cartItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("购物车项不存在"));
        if (!item.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作");
        }
        if (count != null) {
            item.setCount(Math.max(1, count));
        }
        if (selected != null) {
            item.setSelected(selected);
        }
        cartItemRepository.save(item);
    }

    @Transactional
    public void deleteCart(Long userId, Long id) {
        CartItem item = cartItemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("购物车项不存在"));
        if (!item.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权操作");
        }
        cartItemRepository.delete(item);
    }

    @Transactional
    public void clearCart(Long userId) {
        cartItemRepository.findByUserIdOrderByIdDesc(userId).forEach(cartItemRepository::delete);
    }
}
