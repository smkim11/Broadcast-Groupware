package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

	@GetMapping("/home")
	public String home() {
	    return "home";  // /WEB-INF/views/home.jsp를 찾음
	}
}
