package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Attendance;

@Mapper
public interface AttendanceMapper {
	// 오늘날짜로 근태기록 조회
	Attendance selectUserAttendance(int userId);
	// 출근 기록
	void insertAttendanceIn(Attendance attendance);
	// 퇴근 기록
	void updateAttendanceOut(Attendance attendance);
	// 외근 기록
	void updateAttendanceOutside(Attendance attendance);
	// 외근복귀 기록
	void updateAttendanceInside(Attendance attendance);
}
