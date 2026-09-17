package com.example.secondhand.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import lombok.Data;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;

import java.util.*;


@Data
@Component
public class JwtTokenUtil {
    // 密钥
    @Value("${jwt.secret}")
    private String secret ;
    // 过期时间
    @Value("${jwt.expire}")
    private long expire ;



    // 生成密钥HmacSHA256
    public SecretKey generateSecretKey() {
        byte[] keyBytes = Base64.getDecoder().decode(this.secret);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    // 生成 token
    public String generateToken(UserDetails userDetails) {
        String token = null;
        // 生成 claims （主体）
        Map<String, Object> claims = new HashMap<String, Object>();
        List<String> roles = userDetails.getAuthorities().stream()
                .map(authority -> authority.getAuthority()).toList();

        claims.put("roles",roles);

        long expireOffset = expire==0? 2L*365*24*60*60 * 1000L : expire;

        token = Jwts.builder()
                .setClaims(claims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expireOffset))
                .signWith(this.generateSecretKey(), SignatureAlgorithm.HS256)
                .compact();

        return token;
    }

    // 从 token 中提取 claims. Claims 是一个 Map<String, Object>
    public Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(this.generateSecretKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    // 从 token 中提取用户名
    public String extractUsername(String token) {
        return extractAllClaims(token).getSubject();
    }

    // 从 token 中提取角色
    public List<String> extractRoles(String token) {
        return extractAllClaims(token).get("roles", List.class);
    }

    // 从 token 中提取过期时间
    public Date extractExpiration(String token) {
        return extractAllClaims(token).getExpiration();
    }

    // 从 token 中提取签发时间
    public Date extractIssuedAt(String token) {
        return extractAllClaims(token).getIssuedAt();
    }

    // 校验 token 是否过期
    public boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    // 校验 token 是否有效.(验证Token没有过期，且用户名匹配)
    public boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        final boolean tokenExpired = isTokenExpired(token);
        return username.equals(userDetails.getUsername()) && !tokenExpired;
    }


}
