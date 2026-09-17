package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_service_item")
@Entity
public class ServiceItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String code; // 服务编码：recycle/authenticate/repair/clean/rent/errand

    @Column(nullable = false)
    private String name; // 服务名称

    private String icon; // 图标（emoji）

    @Column(length = 500)
    private String description; // 服务说明

    private Double price; // 参考价/起价（元）

    private Boolean enabled = true; // 是否上架
}
