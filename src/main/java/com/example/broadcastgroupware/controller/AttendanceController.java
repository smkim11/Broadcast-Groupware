package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AttendanceController {
	@GetMapping("/test")
	public String test() {
	    return "test";  // /WEB-INF/views/auth-login.jsp를 찾음
	}
}
