package com.example.secondhand.repository;

import com.example.secondhand.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findAllByOrderBySortAsc();
    java.util.Optional<Category> findByCode(String code);
}
