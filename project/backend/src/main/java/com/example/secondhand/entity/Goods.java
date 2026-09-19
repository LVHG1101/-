package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_goods")
@Entity
public class Goods {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private Double price;

    private String image;

    private String quality;

    @Column(length = 500)
    private String description;

    private Long categoryId;

    private Boolean enabled = true;

    private Long userId; // 卖家 id

    // ---- 以下字段不入库，仅在返回给前端时填充卖家信誉信息 ----

    @Transient
    private String sellerName;

    @Transient
    private Integer sellerCredit;

    @Transient
    private Boolean lowCredit;
}
