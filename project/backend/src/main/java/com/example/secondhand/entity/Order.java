package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_order")
@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    private String orderNo;

    private Double totalPrice;

    private String status = "PENDING_PAY"; // PENDING_PAY/PENDING_RECEIVE/COMPLETED/CANCELLED

    private String payMethod;

    private String createTime;

    private String payTime;
}
