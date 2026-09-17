package com.example.secondhand.filter;

import com.example.secondhand.util.JwtTokenUtil;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.InvalidClaimException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@AllArgsConstructor
public class TokenFilter extends OncePerRequestFilter {

    private final JwtTokenUtil jwtTokenUtil;
    private final Logger log = LoggerFactory.getLogger(TokenFilter.class);
    private final UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            String token = authorization.substring(7);

            String username = null;
            try {
                username = jwtTokenUtil.extractUsername(token);
            } catch (ExpiredJwtException e) {
                log.error("JWT 令牌已过期：{}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "令牌已过期");
                return;
            } catch (MalformedJwtException e) {
                log.error("JWT 格式错误：{}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "令牌格式错误");
                return;
            } catch (UnsupportedJwtException e) {
                log.error("JWT 令牌不支持：{}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "不支持的令牌类型");
                return;
            } catch (InvalidClaimException e) {
                log.error("JWT 载荷无效：{}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "令牌信息无效");
                return;
            } catch (IllegalArgumentException e) {
                log.error("JWT 令牌为空或载荷为空：{}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "令牌为空或无效");
                return;
            } catch (SignatureException e) {
                log.error("JWT 签名无效：{}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "令牌签名无效");
                return;
            }
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                if (jwtTokenUtil.validateToken(token, userDetails)) {
                    if (!userDetails.isEnabled()) {
                        log.warn("用户 {} 已被禁用", username);
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "账号已被禁用");
                        return;
                    }
                    if (!userDetails.isAccountNonLocked()) {
                        log.warn("用户 {} 已被锁定", username);
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "账号已被锁定");
                        return;
                    }
                    if (!userDetails.isAccountNonExpired()) {
                        log.warn("用户 {} 账号已过期", username);
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "账号已过期");
                        return;
                    }
                    if (!userDetails.isCredentialsNonExpired()) {
                        log.warn("用户 {} 密码已过期", username);
                        response.sendError(HttpServletResponse.SC_FORBIDDEN, "密码已过期，请修改密码");
                        return;
                    }
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        }
        filterChain.doFilter(request, response);
    }
}
