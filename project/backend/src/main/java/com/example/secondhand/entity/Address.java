package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_address")
@Entity
public class Address {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    private String name; // 收货人姓名

    private String phone; // 手机号

    private String province; // 省

    private String city; // 市

    private String district; // 区

    private String detail; // 详细地址

    private Boolean isDefault = false; // 是否默认地址
}
