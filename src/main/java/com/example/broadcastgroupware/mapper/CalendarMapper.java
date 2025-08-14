package com.example.broadcastgroupware.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CalendarMapper {
	// ID에 맞는 일정
	List<HashMap<String,Object>> selectUserCalendar();// int userId
}
