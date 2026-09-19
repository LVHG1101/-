package com.example.secondhand.config;

import com.example.secondhand.entity.User;
import com.example.secondhand.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 首次启动时创建内置管理员账号，方便演示与答辩。
 * 账号已存在时不会重复创建，也不会覆盖已改过的密码。
 */
@Component
public class AdminInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(AdminInitializer.class);

    private static final String ADMIN_USERNAME = "admin";
    private static final String ADMIN_PASSWORD = "admin123";

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (userRepository.findByUsername(ADMIN_USERNAME).isPresent()) {
            return;
        }
        User admin = new User();
        admin.setUsername(ADMIN_USERNAME);
        admin.setNickname("系统管理员");
        admin.setPassword(passwordEncoder.encode(ADMIN_PASSWORD));
        admin.setRole("admin");
        userRepository.save(admin);
        log.info("已创建内置管理员账号：{} / {}（角色 admin）", ADMIN_USERNAME, ADMIN_PASSWORD);
    }
}
