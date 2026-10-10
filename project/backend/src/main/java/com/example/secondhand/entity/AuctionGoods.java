package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_auction_goods")
@Entity
public class AuctionGoods {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String image;

    @Column(length = 500)
    private String description; // 拍卖品描述/形容

    private Double startPrice;

    private Double currentPrice;

    private Integer bidCount = 0;

    private Long endTime; // 结束时间戳（毫秒）

    private String status = "ONGOING"; // ONGOING/ENDED

    private Long userId; // 发布者 id
}
