package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_carbon_point")
@Entity
public class CarbonPoint {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    private String username;

    private Integer delta; // 变动值，正为获得，负为消费

    private String reason; // 变动原因

    private String createTime;
}
