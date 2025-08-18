package com.example.broadcastgroupware.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;

public class CustomLoginSuccessHandler implements AuthenticationSuccessHandler {

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication)
            throws IOException, ServletException {

        // 사용자의 권한을 가져옴
        Set<String> roles = AuthorityUtils.authorityListToSet(authentication.getAuthorities());

        // 권한에 따라 리디렉션
        if (roles.contains("ROLE_admin")) {
            response.sendRedirect("/home");
        } else if (roles.contains("ROLE_user")) {
            response.sendRedirect("/home");
        } else {
            response.sendRedirect("/access-denied");
        }
    }
}
