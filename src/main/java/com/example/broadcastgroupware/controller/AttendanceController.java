package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.AttendanceListDto;
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
			System.out.println(attendance);
		}
		System.out.println(attendanceService.selectAttendanceList(user.getUserId()));
		model.addAttribute("weekWorkHours",attendanceService.selectWeekWorkHours(user.getUserId()));
		model.addAttribute("totalWorkDay",attendanceService.selectTotalWorkDay(user.getUserId()));
		model.addAttribute("attendanceList",attendanceService.selectAttendanceList(user.getUserId()));
		model.addAttribute("loginUser",user.getUserId());
	    return "user/attendance";  
	}
	
	// 팀,부서,전체 근태
	@GetMapping("/attendanceList")
	public String attendanceList(Model model, HttpSession session) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		AttendanceListDto ald = new AttendanceListDto();
		ald.setUserId(user.getUserId());
		ald.setRole(user.getRole());
		ald.setUserRank(user.getUserRank());
		
		model.addAttribute("list",attendanceService.selectAttendanceListByRank(ald));
		return "user/attendanceList";
	}
}
