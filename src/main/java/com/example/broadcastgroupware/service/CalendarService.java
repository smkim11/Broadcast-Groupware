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
	public List<HashMap<String,Object>> selectUserCalendar(int userId){
		return calendarMapper.selectUserCalendar(userId);
	}
	
	// Id에 맞는 개인일정
	public List<HashMap<String,Object>> selectPersonalCalendar(int userId){
		return calendarMapper.selectPersonalCalendar(userId);
	}
	
	// Id에 맞는 팀일정
	public List<HashMap<String,Object>> selectTeamCalendar(int userId){
		return calendarMapper.selectTeamCalendar(userId);
	}
	
	// 전체일정
	public List<HashMap<String,Object>> selectTotalCalendar(){
		return calendarMapper.selectTotalCalendar();
	}
	
	// 공휴일 조회
	public List<HashMap<String,Object>> selectHoliday(){
		return calendarMapper.selectHoliday();
	}
	
	// 일정 생성
	public void insertCalendar(Calendar calendar) {
		calendarMapper.insertCalendar(calendar);
	}
	
	// 일정 수정(본인이 작성한 일정만 수정)
	public void updateCalendar(Calendar calendar) {
		calendarMapper.updateCalendar(calendar);
	}
	
	// 일정 삭제(본인이 작성한 일정만 삭제)
	public void deleteCalendar(Calendar calendar) {
		calendarMapper.deleteCalendar(calendar);
	}
    
}
