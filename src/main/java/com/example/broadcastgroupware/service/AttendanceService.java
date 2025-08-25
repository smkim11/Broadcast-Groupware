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
	
	// 출근 기록
	public void insertAttendanceIn(Attendance attendance) {
		attendanceMapper.insertAttendanceIn(attendance);
	}
}
