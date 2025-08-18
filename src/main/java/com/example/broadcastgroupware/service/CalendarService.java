package com.example.broadcastgroupware.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Calendar;
import com.example.broadcastgroupware.mapper.CalendarMapper;

@Service
@Transactional
public class CalendarService {
	private CalendarMapper calendarMapper;
	public CalendarService(CalendarMapper calendarMapper) {
		this.calendarMapper = calendarMapper;
	}
	
	// ID에 맞는 일정
	public List<HashMap<String,Object>> selectUserCalendar(){
		return calendarMapper.selectUserCalendar(); // int userId
	}
	
	// 일정 생성
	public void insertCalendar(Calendar calendar) {
		calendarMapper.insertCalendar(calendar);
	}
	
	// 일정 수정
	public void updateCalendar(Calendar calendar) {
		calendarMapper.updateCalendar(calendar);
	}
}
