package com.example.broadcastgroupware.security;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.UserMapper;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Set;

@Component
public class CustomLoginSuccessHandler implements AuthenticationSuccessHandler {

    @Autowired
    private UserMapper userMapper;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication)
            throws IOException, ServletException {

        HttpSession session = request.getSession();

        // 로그인한 사용자 ID
        String username = authentication.getName();

        // DB에서 사용자 전체 정보 가져오기
        User user = userMapper.findByUsername(username);

        UserSessionDto sessionUser = new UserSessionDto();
        sessionUser.setUserId(user.getUserId());
        sessionUser.setUsername(user.getUsername());
        sessionUser.setRole(user.getRole());
        sessionUser.setFullName(user.getFullName());
        sessionUser.setUserSn1(user.getUserSn1());
        sessionUser.setUserSn2(user.getUserSn2());
        sessionUser.setUserPhone(user.getUserPhone());
        sessionUser.setUserEmail(user.getUserEmail());
        sessionUser.setUserRank(user.getUserRank());
        sessionUser.setUserJoinDate(user.getUserJoinDate());
        sessionUser.setUserResignDate(user.getUserResignDate());
        
        // 세션에 저장
        session.setAttribute("loginUser", sessionUser);

        // 권한에 따라 리디렉션
        Set<String> roles = AuthorityUtils.authorityListToSet(authentication.getAuthorities());
        if (roles.contains("ROLE_admin") || roles.contains("ROLE_user")) {
            response.sendRedirect("/home");
        } else {
            response.sendRedirect("/access-denied");
        }
    }
}
