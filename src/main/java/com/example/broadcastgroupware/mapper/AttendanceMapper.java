package com.example.broadcastgroupware.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

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
	// 잔여 휴가
	Double selectRemainVacation(int userId);
	// 오늘 퇴근을 찍지않고 퇴근한 직원목록
	List<Integer> selectNotOutUser();
	// 직책별 팀,부서,전체 근태
	List<HashMap<String,Object>> selectAttendanceListByRank(AttendanceListDto attendanceListDto);
	// 로그인한 직원의 휴가기록 조회
	List<HashMap<String,Object>> selectVacationList(int userId);
	// 출근 기록
	void insertAttendanceIn(Attendance attendance);
	// 퇴근 기록
	void updateAttendanceOut(Attendance attendance);
	// 외근 기록
	void updateAttendanceOutside(Attendance attendance);
	// 외근복귀 기록
	void updateAttendanceInside(Attendance attendance);
	// 퇴근 안누른사람 정시퇴근 처리
	void updateNotOutUser(int userId);
	
	// home페이지 근태 갯수 및 시간 조회
	// 최근 N일 카운트
	Map<String,Object> selectCountsInDays(int userId, int days);
}
