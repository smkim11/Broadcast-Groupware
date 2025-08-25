package com.example.broadcastgroupware.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;

@Controller
public class MyPageController {

	@GetMapping("/myPage")
	public String myPage(HttpSession session) {
	    UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
	    if (loginUser == null) {
	        return "redirect:/login"; // 로그인 안 했으면 로그인 페이지로
	    }

	    String role = loginUser.getRole(); // ex: "admin" or "user"

	    if ("admin".equals(role)) {
	        return "admin/myPage";  // WEB-INF/views/admin/myPage.jsp 호출
	    } else if ("user".equals(role)) {
	        return "user/myPage";   // WEB-INF/views/user/myPage.jsp 호출
	    } else {
	        return "accessDenied";  // 권한 없으면 접근 거부 페이지 등
	    }
	}
}
