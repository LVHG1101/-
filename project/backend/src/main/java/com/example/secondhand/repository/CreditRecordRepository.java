package com.example.secondhand.repository;

import com.example.secondhand.entity.CreditRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CreditRecordRepository extends JpaRepository<CreditRecord, Long> {
    List<CreditRecord> findByUserIdOrderByIdDesc(Long userId);

    List<CreditRecord> findAllByOrderByIdDesc();
}
