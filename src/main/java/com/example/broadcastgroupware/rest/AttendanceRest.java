package com.example.broadcastgroupware.rest;

import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.AttendanceService;

import jakarta.servlet.http.HttpSession;

@RestController
public class AttendanceRest {
	private AttendanceService attendanceService;
	public AttendanceRest(AttendanceService attendanceService) {
		this.attendanceService = attendanceService;
	}
	
	// 출근 기록
	@PostMapping("/insertAttendanceIn")
	public void insertAttendanceIn(@RequestBody Attendance attendance, HttpSession session) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		attendance.setUserId(user.getUserId());
		attendanceService.insertAttendanceIn(attendance);
	}
	
	// 퇴근 기록
	@PatchMapping("/updateAttendanceOut")
	public void updateAttendanceOut(@RequestBody Attendance attendance, HttpSession session) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		attendance.setUserId(user.getUserId());
		attendanceService.updateAttendanceOut(attendance);
	}
	
	// 외근 기록
	@PatchMapping("/updateAttendanceOutside")
	public void updateAttendanceOutside(@RequestBody Attendance attendance, HttpSession session) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		attendance.setUserId(user.getUserId());
		attendanceService.updateAttendanceOutside(attendance);
	}

	// 외근복귀 기록
	@PatchMapping("/updateAttendanceInside")
	public void updateAttendanceInside(@RequestBody Attendance attendance, HttpSession session) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		attendance.setUserId(user.getUserId());
		attendanceService.updateAttendanceInside(attendance);
	}
}
