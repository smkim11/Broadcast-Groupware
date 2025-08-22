package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.dto.HolidayDto;

@Mapper
public interface HolidayMapper {
	// 공휴일 저장
	void insertHoliday(HolidayDto holidayDto);
}
