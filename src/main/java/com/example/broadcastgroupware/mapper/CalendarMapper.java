package com.example.broadcastgroupware.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Calendar;

@Mapper
public interface CalendarMapper {
	// ID에 맞는 일정
	List<HashMap<String,Object>> selectUserCalendar();// int userId
	// 일정 생성
	void insertCalendar(Calendar calendar);
	// 일정 수정
	void updateCalendar(Calendar calendar);
}
