package com.example.broadcastgroupware.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.CalendarService;

import jakarta.servlet.http.HttpSession;

@Controller
public class CalendarController {
	private CalendarService calendarService;
	public CalendarController(CalendarService calendarService) {
		this.calendarService = calendarService;
	}
	
	// 캘린더 조회
	@GetMapping("/calendar")
	public String calendar(Model model, HttpSession session) {
		/*
		  UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		  Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
		  UserSessionDto user = (UserSessionDto)authentication.getPrincipal();
		  
		 */
		int userId = 53;
		
		model.addAttribute("events",calendarService.selectUserCalendar(userId)); // int userId
		return "calendar";
	}
}
