package com.example.broadcastgroupware.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.mapper.AttendanceMapper;

@Service
@Transactional
public class AttendanceService {
	private AttendanceMapper attendanceMapper;
	public AttendanceService(AttendanceMapper attendanceMapper) {
		this.attendanceMapper = attendanceMapper;
	}
	
	// 오늘날짜로 본인 근태기록 조회
	public Attendance selectUserAttendance(int userId) {
		return attendanceMapper.selectUserAttendance(userId);
	}
	
	// 출근 기록
	public void insertAttendanceIn(Attendance attendance) {
		attendanceMapper.insertAttendanceIn(attendance);
	}
	
	// 퇴근 기록
	public void updateAttendanceOut(Attendance attendance) {
		attendanceMapper.updateAttendanceOut(attendance);
	}
	
	// 외근 기록
	public void updateAttendanceOutside(Attendance attendance) {
		// 출근을 안찍고 외근을 찍으면 출근에도 외근과 동일한 시간 저장
		if(attendanceMapper.selectUserAttendance(attendance.getUserId()) == null) {
			attendanceMapper.insertAttendanceIn(attendance);
		}
		attendanceMapper.updateAttendanceOutside(attendance);
	}
	
	// 외근복귀 기록
	public void updateAttendanceInside(Attendance attendance) {
		attendanceMapper.updateAttendanceInside(attendance);
	}
}
