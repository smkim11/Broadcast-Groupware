package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.service.CalendarService;

@Controller
public class CalendarController {
	private CalendarService calendarService;
	public CalendarController(CalendarService calendarService) {
		this.calendarService = calendarService;
	}
	
	// 캘린더 조회
	@GetMapping("/calendar")
	public String calendar(Model model) {
		model.addAttribute("events",calendarService.selectUserCalendar()); // int userId
		return "calendar";
	}
}
