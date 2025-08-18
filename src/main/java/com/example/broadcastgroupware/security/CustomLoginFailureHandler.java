package com.example.broadcastgroupware.security;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.logging.Logger;

public class CustomLoginFailureHandler implements AuthenticationFailureHandler {

    private static final Logger logger = Logger.getLogger(CustomLoginFailureHandler.class.getName());

    @Override
    public void onAuthenticationFailure(HttpServletRequest request,
                                        HttpServletResponse response,
                                        AuthenticationException exception) throws IOException {

        logger.warning("로그인 실패: " + exception.getMessage());
        response.sendRedirect("/login?error");  // 로그인 실패 시 다시 로그인 페이지로
    }
}
