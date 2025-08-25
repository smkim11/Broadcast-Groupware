package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Attendance;

@Mapper
public interface AttendanceMapper {
	// 출근 기록
	void insertAttendanceIn(Attendance attendance);
}
