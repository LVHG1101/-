package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_service_order")
@Entity
public class ServiceOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId; // 下单用户

    @Column(nullable = false)
    private Long serviceId; // 服务 id

    private String serviceCode; // 服务编码
    private String serviceName; // 服务名称
    private String serviceIcon; // 服务图标

    private String contactName; // 联系人
    private String contactPhone; // 联系方式
    private String address; // 上门地址
    private String appointmentTime; // 预约时间（yyyy-MM-dd HH:mm）

    @Column(length = 500)
    private String remark; // 备注

    private String status = "PENDING"; // PENDING/CONFIRMED/COMPLETED/CANCELLED

    private String createTime; // 下单时间（ISO 字符串）
}
