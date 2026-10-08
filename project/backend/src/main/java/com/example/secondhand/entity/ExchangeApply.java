package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_exchange_apply")
@Entity
public class ExchangeApply {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long exchangeId;

    @Column(nullable = false)
    private Long userId; // 申请者

    private String message;

    private String createTime;

    private String status = "PENDING"; // PENDING/ACCEPTED/REJECTED
}
