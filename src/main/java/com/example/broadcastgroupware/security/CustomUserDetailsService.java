package com.example.broadcastgroupware.security;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
    	System.out.println(">>> 사용자 조회 시도: " + username);
        User user = userMapper.findByUsername(username);
        System.out.println(">>> 사용자 조회 완료: " + user);
        System.out.println(">>> 권한: ROLE_" + user.getRole());
        if (user == null) {
            throw new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + username);
        }

        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(), // User도메인에 password추가하기
                Collections.singleton(new SimpleGrantedAuthority("ROLE_" + user.getRole()))
        );
    }
    
}
