package com.example.secondhand.repository;

import com.example.secondhand.entity.User;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> , JpaSpecificationExecutor<User> {
    Optional<User> findByUsername(String username);
    List<User> findByNickname(String nickname);



}