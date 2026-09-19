package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_after_sale")
@Entity
public class AfterSale {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long orderId; // 关联订单 id

    private String orderNo; // 订单号（冗余，方便展示）

    private Double totalPrice; // 订单金额（冗余，方便展示）

    @Column(nullable = false)
    private Long userId; // 申请用户

    private String username; // 申请人账号（冗余，方便管理端展示）

    private String reason; // 申请原因

    private String status = "PENDING"; // PENDING 待处理 / APPROVED 已同意 / REJECTED 已驳回

    private String previousStatus; // 申请前的订单状态，驳回后还原用

    private String applyTime; // 申请时间（ISO 字符串）

    private String handleTime; // 处理时间

    private String adminRemark; // 管理员处理备注
}
