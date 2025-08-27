package com.example.broadcastgroupware.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.AttendanceListDto;

@Mapper
public interface AttendanceMapper {
	// 오늘날짜로 근태기록 조회
	Attendance selectUserAttendance(int userId);
	// 로그인한 직원의 근태기록 조회
	List<HashMap<String,Object>> selectAttendanceList(int userId);
	// 이번주 총 근무시간
	String selectWeekWorkHours(int userId);
	// 입사후 총 근무일
	String selectTotalWorkDay(int userId);
	// 직책별 팀,부서,전체 근태
	List<HashMap<String,Object>> selectAttendanceListByRank(AttendanceListDto attendanceListDto);
	// 출근 기록
	void insertAttendanceIn(Attendance attendance);
	// 퇴근 기록
	void updateAttendanceOut(Attendance attendance);
	// 외근 기록
	void updateAttendanceOutside(Attendance attendance);
	// 외근복귀 기록
	void updateAttendanceInside(Attendance attendance);
}
