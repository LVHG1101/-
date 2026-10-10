package com.example.secondhand.repository;

import com.example.secondhand.entity.CarbonPoint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CarbonPointRepository extends JpaRepository<CarbonPoint, Long> {
    List<CarbonPoint> findByUserIdOrderByIdDesc(Long userId);
}
