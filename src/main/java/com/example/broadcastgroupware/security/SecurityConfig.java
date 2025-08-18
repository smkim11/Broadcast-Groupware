package com.example.broadcastgroupware.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .anyRequest().authenticated()  // 모든 요청 인증 필요
            )
            .formLogin(form -> form
                .loginPage("/login")          // 커스텀 로그인 페이지 URL
                .permitAll()
            )
            .logout(logout -> logout.permitAll());

        return http.build();
    }

    // 인증 관리자 빈 등록 (필요시)
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    // 테스트용 비밀번호 인코더 (암호화 안 함) — 실제 서비스에서는 BCryptPasswordEncoder 등 사용 권장
    @Bean
    public PasswordEncoder passwordEncoder() {
        return NoOpPasswordEncoder.getInstance();
    }
}