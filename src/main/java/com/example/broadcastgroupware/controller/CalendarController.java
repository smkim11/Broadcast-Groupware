package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.CalendarService;

import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class CalendarController {
	private CalendarService calendarService;
	public CalendarController(CalendarService calendarService) {
		this.calendarService = calendarService;
	}
	
	// 캘린더 조회
	@GetMapping("/calendar")
	public String calendar(Model model, HttpSession session) throws Exception {
		// 세션에서 로그인한 userId와 role을 가져온다 
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		log.info("user: ",user);
		int userId= user.getUserId();
		String userRole = user.getRole();
		model.addAttribute("loginUserId",userId);
		model.addAttribute("role",userRole);
		// 공휴일 조회
		model.addAttribute("events",calendarService.selectHoliday());
		return "calendar";
	}
}
