package com.example.secondhand.repository;

import com.example.secondhand.entity.AfterSale;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AfterSaleRepository extends JpaRepository<AfterSale, Long> {
    List<AfterSale> findByUserIdOrderByIdDesc(Long userId);

    List<AfterSale> findAllByOrderByIdDesc();

    List<AfterSale> findByStatusOrderByIdDesc(String status);

    Optional<AfterSale> findByOrderIdAndStatus(Long orderId, String status);
}
