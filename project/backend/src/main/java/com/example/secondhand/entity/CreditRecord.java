package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

/** 信誉分变动流水 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_credit_record")
@Entity
public class CreditRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    private String username;

    private Integer delta; // 变动值，正为加分，负为扣分

    private Integer scoreBefore;

    private Integer scoreAfter;

    private String reason; // 变动原因

    private String source; // SYSTEM 系统自动 / ADMIN 管理员手动

    private String operator; // 操作人（管理员账号），系统规则留空

    private String createTime;
}
