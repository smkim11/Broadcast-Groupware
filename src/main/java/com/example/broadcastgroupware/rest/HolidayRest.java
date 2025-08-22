package com.example.broadcastgroupware.rest;

import java.io.UnsupportedEncodingException;
import java.net.URISyntaxException;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.service.HolidayService;
import com.fasterxml.jackson.core.JsonProcessingException;

@RestController
public class HolidayRest {
	private HolidayService holidayService;
	public HolidayRest(HolidayService holidayService) {
		this.holidayService = holidayService;
	}
	
	// 공휴일 api로 원하는 년도 공휴일 검색
	@GetMapping("/holidays")
    public String holidays(@RequestParam String year) throws UnsupportedEncodingException, URISyntaxException, JsonProcessingException, IllegalArgumentException {
        holidayService.getHolidays(year);
        return "공휴일 저장 완료";
    }
}
