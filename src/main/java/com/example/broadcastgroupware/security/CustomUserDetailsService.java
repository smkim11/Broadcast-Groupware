package com.example.broadcastgroupware.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.mapper.UserMapper;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // (1) 사번이 숫자 형태인지 검증
        final int empNo;
        try {
            empNo = Integer.parseInt(username.trim());
        } catch (Exception e) {
            log.info("잘못된 사원번호 형식: {}", username);
            throw new UsernameNotFoundException("사원번호 형식이 올바르지 않습니다.");
        }

        // (2) 사용자 조회
        var user = userMapper.findByUsername(username); // ← 실제 조회 메서드명에 맞게
        if (user == null) {
            log.info("사용자 조회 실패: username={}", username);
            // **여기서 꼭 UsernameNotFoundException** 을 던져야 함 (중요)
            throw new UsernameNotFoundException("존재하지 않는 사용자입니다.");
        }

        // (3) 권한 가공 (null/빈값 대비 + ROLE_ 접두어 보장)
        String role = (user.getRole() == null || user.getRole().isBlank())
                ? "ROLE_user"
                : (user.getRole().startsWith("ROLE_") ? user.getRole() : "ROLE_" + user.getRole());

        // (4) PasswordEncoder와 저장된 비밀번호 포맷 일치 (NoOp면 평문, Bcrypt면 해시)
        return org.springframework.security.core.userdetails.User
                .withUsername(String.valueOf(username))
                .password(user.getPassword())
                .authorities(role)
                .accountLocked(false)
                .disabled(false)
                .build();
    }
}
