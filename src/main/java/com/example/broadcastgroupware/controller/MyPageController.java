package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.MyPageService;

import jakarta.servlet.http.HttpSession;

@Controller
public class MyPageController {
	private MyPageService myPageService;
	public MyPageController(MyPageService myPageService) {
		this.myPageService=myPageService;
	}
	
	@GetMapping("/myPage")
	public String myPage(Model model, HttpSession session) {
	    UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
	    if (loginUser == null) {
	        return "redirect:/login"; // 로그인 안 했으면 로그인 페이지로
	    }
	    
	    model.addAttribute("myInfo",myPageService.userInfo(loginUser.getUserId()));
	    return "user/myPage";
	}
}
