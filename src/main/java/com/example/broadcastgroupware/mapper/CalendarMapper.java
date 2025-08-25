package com.example.broadcastgroupware.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Calendar;

@Mapper
public interface CalendarMapper {
	// ID에 맞는 일정
	List<HashMap<String,Object>> selectUserCalendar(int userId);
	// Id에 맞는 개인일정
	List<HashMap<String,Object>> selectPersonalCalendar(int userId);
	// Id에 맞는 팀 일정
	List<HashMap<String,Object>> selectTeamCalendar(int userId);
	// 전체 일정
	List<HashMap<String,Object>> selectTotalCalendar();
	// 공휴일 조회
	List<HashMap<String,Object>> selectHoliday();
	// 일정 생성
	void insertCalendar(Calendar calendar);
	// 일정 수정
	void updateCalendar(Calendar calendar);
	// 일정 삭제
	void deleteCalendar(Calendar calendar);
}
