package com.example.broadcastgroupware.rest;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.AttendanceListDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.AttendanceService;

import jakarta.servlet.http.HttpSession;

@RestController
public class AttendanceRest {
	private AttendanceService attendanceService;
	public AttendanceRest(AttendanceService attendanceService) {
		this.attendanceService = attendanceService;
	}
	
	@GetMapping("/selectAttendanceList")
	public Map<String,Object> selectAttendanceList(HttpSession session,
			@RequestParam(required = false) Integer year, @RequestParam(required = false) Integer month) {
		UserSessionDto user = (UserSessionDto)session.getAttribute("loginUser");
		LocalDate now = LocalDate.now();
		int todayYear = now.getYear();
		int todayMonth = now.getMonthValue();
		
		AttendanceListDto ald = new AttendanceListDto();
		ald.setUserId(user.getUserId());
		ald.setRole(user.getRole());
		ald.setUserRank(user.getUserRank());
		if(year != null && month != null) {
			ald.setYear(year);
			ald.setMonth(month);
		}else {
			ald.setYear(todayYear);
			ald.setMonth(todayMonth);
		}
		Map<String,Object> map = new HashMap<>();
		map.put("ald",ald);
		map.put("list",attendanceService.selectAttendanceListByRank(ald));
		
		return map;
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
