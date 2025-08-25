package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.dto.HolidayFormDto;

@Mapper
public interface HolidayMapper {
	// 공휴일 저장
	void insertHoliday(HolidayFormDto holidayFormDto);
}
