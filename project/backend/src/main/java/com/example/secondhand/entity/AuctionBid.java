package com.example.secondhand.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "t_auction_bid")
@Entity
public class AuctionBid {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long auctionId;

    @Column(nullable = false)
    private Long userId;

    private Double price;

    private String createTime;
}
