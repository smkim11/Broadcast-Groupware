package com.example.broadcastgroupware.rest;

import java.util.HashMap;
import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Calendar;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.CalendarService;

import jakarta.servlet.http.HttpSession;

@RestController
public class CalendarRest {
	private CalendarService calendarService;
	public CalendarRest(CalendarService calendarService) {
		this.calendarService = calendarService;
	}
	
	// Id에 맞는 개인일정 조회
	@GetMapping("/selectPersonalCalendar")
	public List<HashMap<String,Object>> selectPersonalCalendar(@RequestParam int userId){
		return calendarService.selectPersonalCalendar(userId);
	}
	
	// Id에 맞는 팀일정 조회
	@GetMapping("/selectTeamCalendar")
	public List<HashMap<String,Object>> selectTeamCalendar(@RequestParam int userId){
		return calendarService.selectTeamCalendar(userId);
	}
	
	// 전체일정 조회
	@GetMapping("/selectTotalCalendar")
	public List<HashMap<String,Object>> selectTotalCalendar(@RequestParam int userId){
		return calendarService.selectTotalCalendar(userId);
	}
	
	// 일정 등록
	@PostMapping("/insertCalendar")
	public void insertCalendar(@RequestBody Calendar calendar, HttpSession session) {
		// 로그인한 직원의 userId입력
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		calendar.setUserId(user.getUserId());
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
	/*
	@GetMapping("/holidays")
    public String holidays(@RequestParam String year) {
        return calendarService.getHolidays(year);
    }
    */
}
