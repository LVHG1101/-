package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_exchange_goods")
@Entity
public class ExchangeGoods {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name; // 换出物品

    private String wantName; // 想换物品

    private String image;

    private String owner; // 发布者昵称

    private String location; // 位置

    private String status = "ONGOING"; // ONGOING/ENDED

    private Long userId; // 发布者 id
}
