package com.example.broadcastgroupware.rest;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Calendar;
import com.example.broadcastgroupware.service.CalendarService;

import jakarta.servlet.http.HttpSession;

@RestController
public class CalendarRest {
	private CalendarService calendarService;
	public CalendarRest(CalendarService calendarService) {
		this.calendarService = calendarService;
	}
	
	// 일정 등록
	@PostMapping("/insertCalendar")
	public void insertCalendar(@RequestBody Calendar calendar) {
		calendarService.insertCalendar(calendar);
	}

	// 일정 수정
	@PatchMapping("/updateCalendar")
	public void updateCalendar(@RequestBody Calendar calendar, HttpSession session) {
		System.out.println("Calendar: " + calendar);
		
		calendarService.updateCalendar(calendar);
	}
	
	// 일정 삭제
	@DeleteMapping("/deleteCalendar")
	public void deleteCalendar(@RequestBody Calendar calendar) {
		calendarService.deleteCalendar(calendar);
	}
}
