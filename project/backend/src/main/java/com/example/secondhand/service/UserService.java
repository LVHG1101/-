package com.example.secondhand.service;

import com.example.secondhand.entity.User;
import com.example.secondhand.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;


    @Autowired
    private BCryptPasswordEncoder bCryptPasswordEncoder ;



    // 注册用户
    public User register(User user) {
        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        return userRepository.save(user);
    }

    // 登录用户
    public UserDetails login(String usernameOrPhone, String password) {

        UserDetails user = null;
        user = this.loadUserByUsername(usernameOrPhone);

        if (!bCryptPasswordEncoder.matches(password, user.getPassword())) {
            throw new UsernameNotFoundException("密码错误");
        }
        return user;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User u = null;
        u = userRepository.findByUsername(username).orElse(null);
        if (u == null) {
            throw new UsernameNotFoundException("用户不存在");
        }
        u.setRole(u.getRole().startsWith("ROLE_") ? u.getRole() : "ROLE_" + u.getRole());
        return u;
    }
}
