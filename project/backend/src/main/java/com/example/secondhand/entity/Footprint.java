package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_footprint")
@Entity
public class Footprint {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId; // 归属用户

    @Column(nullable = false)
    private Long goodsId; // 商品 id

    private String name; // 商品名称
    private Double price; // 商品价格
    private String image; // 商品图片文件名
    private String visitTime; // 浏览时间（ISO 字符串）
}
