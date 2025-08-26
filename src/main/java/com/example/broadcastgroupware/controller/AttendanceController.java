package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.AttendanceService;

import jakarta.servlet.http.HttpSession;

@Controller
public class AttendanceController {
	private AttendanceService attendanceService;
	public AttendanceController(AttendanceService attendanceService) {
		this.attendanceService = attendanceService;
	}
	
	// 본인 근태
	@GetMapping("/attendance")
	public String attendance(Model model, HttpSession session) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		Attendance attendance = attendanceService.selectUserAttendance(user.getUserId());
		if(attendance != null) {
			model.addAttribute("attendance",attendance);
		}
		
		System.out.println(attendance);
		model.addAttribute("loginUser",user.getUserId());
	    return "user/attendance";  
	}
}
