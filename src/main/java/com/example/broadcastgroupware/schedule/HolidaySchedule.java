package com.example.broadcastgroupware.schedule;

import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;
import java.time.LocalDate;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.example.broadcastgroupware.service.HolidayService;
import com.fasterxml.jackson.core.JsonProcessingException;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class HolidaySchedule {
	private HolidayService holidayService;
	public HolidaySchedule(HolidayService holidayService) {
		this.holidayService = holidayService;
	}
	
	// 매년 12월1일에 내년 공휴일 정보가 DB에 저장
	@Scheduled(cron = "0 0 0 1 12 *")
	public void HolidaySchedule() throws JsonProcessingException, UnsupportedEncodingException, IllegalArgumentException, URISyntaxException {
		LocalDate now = LocalDate.now();
		String year = String.valueOf(now.getYear()+1);
		holidayService.getHolidays(year);
		log.info("공휴일 저장 완료");
	}
}
