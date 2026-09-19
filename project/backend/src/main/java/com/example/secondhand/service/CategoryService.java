package com.example.secondhand.service;

import com.example.secondhand.entity.Category;
import com.example.secondhand.entity.Goods;
import com.example.secondhand.entity.User;
import com.example.secondhand.repository.CategoryRepository;
import com.example.secondhand.repository.GoodsRepository;
import com.example.secondhand.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private GoodsRepository goodsRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CreditService creditService;

    @EventListener(ApplicationReadyEvent.class)
    public void initData() {
        if (categoryRepository.count() != 4) {
            goodsRepository.deleteAll();
            categoryRepository.deleteAll();
        }
        ensureCategory("digital", "数码", "数", 1);
        ensureCategory("appliance", "家电", "电", 2);
        ensureCategory("home", "家居", "居", 3);
        ensureCategory("other", "其他", "其", 4);

        if (goodsRepository.count() > 0) {
            return;
        }
        Long digitalId = categoryRepository.findByCode("digital").map(Category::getId).orElse(null);
        Long applianceId = categoryRepository.findByCode("appliance").map(Category::getId).orElse(null);
        Long homeId = categoryRepository.findByCode("home").map(Category::getId).orElse(null);
        Long otherId = categoryRepository.findByCode("other").map(Category::getId).orElse(null);

        saveGoods("iPhone 15 128G", 3999.0, "phone2", "九成新", "国行正品，无磕碰划痕", digitalId);
        saveGoods("小米笔记本 Pro 14", 3299.0, "computer", "九五新", "办公轻薄本，电池健康", digitalId);
        saveGoods("iPad Air 5 64G", 2499.0, "pad", "九成新", "屏幕无划痕，配件齐全", digitalId);
        saveGoods("AirPods Pro 2", 899.0, "hairphone", "八成新", "降噪正常，续航良好", digitalId);

        saveGoods("小米电视 55寸", 1299.0, "tv", "九成新", "4K高清，自提优先", applianceId);
        saveGoods("米家空调 1.5匹", 1599.0, "airconditaion", "九成新", "制冷制热正常", applianceId);
        saveGoods("米家冰箱 530L", 2299.0, "icebox", "九五新", "大容量对开门", applianceId);
        saveGoods("洗衣机 10kg", 899.0, "washingmachine", "八成新", "洗烘一体", applianceId);

        saveGoods("智能门锁", 499.0, "lock", "九成新", "指纹密码刷卡", homeId);
        saveGoods("双肩运动包", 99.0, "bag", "九成新", "容量大，防水", homeId);
        saveGoods("电动牙刷", 59.0, "brushteeth", "全新", "未拆封", homeId);

        saveGoods("高等数学教材", 15.0, "phone1", "八成新", "少量笔记", otherId);
        saveGoods("纯棉T恤 M码", 39.0, "phone3", "全新", "未穿洗", otherId);
        saveGoods("婴儿推车", 299.0, "phone5", "八成新", "功能正常", otherId);
    }

    private void ensureCategory(String code, String name, String icon, Integer sort) {
        if (categoryRepository.findByCode(code).isEmpty()) {
            categoryRepository.save(new Category(null, code, name, icon, sort));
        }
    }

    private void saveGoods(String name, Double price, String image, String quality, String description, Long categoryId) {
        Goods goods = new Goods();
        goods.setName(name);
        goods.setPrice(price);
        goods.setImage(image);
        goods.setQuality(quality);
        goods.setDescription(description);
        goods.setCategoryId(categoryId);
        goods.setEnabled(true);
        goodsRepository.save(goods);
    }

    public List<Category> listCategories() {
        return categoryRepository.findAllByOrderBySortAsc();
    }

    public List<Goods> listGoods(Long categoryId) {
        List<Goods> list = categoryId == null
                ? goodsRepository.findByEnabledTrueOrderByIdAsc()
                : goodsRepository.findByEnabledTrueAndCategoryIdOrderByIdAsc(categoryId);
        for (Goods goods : list) {
            fillSeller(goods);
        }
        return list;
    }

    public Goods getGoods(Long id) {
        Goods goods = goodsRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("商品不存在"));
        fillSeller(goods);
        return goods;
    }

    /** 发布商品，记录卖家以便做信誉约束 */
    public Goods publishGoods(Goods goods, Long userId) {
        goods.setId(null);
        goods.setEnabled(true);
        goods.setUserId(userId);
        return goodsRepository.save(goods);
    }

    /** 填充卖家信誉信息，供前端展示「低信誉卖家」标识 */
    private void fillSeller(Goods goods) {
        if (goods == null || goods.getUserId() == null) {
            return;
        }
        User seller = userRepository.findById(goods.getUserId()).orElse(null);
        if (seller == null) {
            return;
        }
        int score = creditService.scoreOf(seller);
        goods.setSellerName(seller.getNickname() == null ? seller.getUsername() : seller.getNickname());
        goods.setSellerCredit(score);
        goods.setLowCredit(score < CreditService.LOW_THRESHOLD);
    }
}
