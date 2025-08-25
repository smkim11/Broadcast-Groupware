package com.example.broadcastgroupware.service;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;

import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.broadcastgroupware.dto.HolidayDto;
import com.example.broadcastgroupware.dto.HolidayFormDto;
import com.example.broadcastgroupware.mapper.HolidayMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class HolidayService {
	private final RestTemplate restTemplate;
	private HolidayMapper holidayMapper;
	public HolidayService(RestTemplateBuilder builder, HolidayMapper holidayMapper) {
		this.restTemplate = builder.build();
		this.holidayMapper = holidayMapper;
	}
	
	// 공휴일 api로 원하는 년도 공휴일 조회
	public void getHolidays(String year) throws UnsupportedEncodingException, URISyntaxException, JsonProcessingException, IllegalArgumentException {
        String serviceKey = "X5crsn5JobgfMEbWjbf2jZ8751ZRHfZPmGLvOmiwf9VxUxRS5PgbuzO2HNu+VyjQvk9+2c2A1+/tVSM/vPUSyw==";
        // 웹에서 '+'를 공백으로 만들 수 있어서 치환해서 저장
        String safeKey = serviceKey.replace("+", "%2B");
        String url = "http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getHoliDeInfo"
                + "?serviceKey=" +safeKey
                + "&pageNo=1"
                + "&numOfRows=100"
                + "&solYear=" +year
                + "&_type=json";
        // URI를 이용해서 url을 인코딩하여 보내서 인식하지 못하던것들을 인식하게한다
        URI uri = new URI(url);
        System.out.println("요청 URL = " + uri);
        String json = restTemplate.getForObject(uri, String.class);
        System.out.println(json);
        // JSON으로된 정보들을 DTO로 변환하여 DB에 저장
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(json);
        JsonNode items = root.path("response").path("body").path("items").path("item");

        if (items.isArray()) {
            for (JsonNode node : items) {
                HolidayDto holiday = mapper.treeToValue(node, HolidayDto.class);
                HolidayFormDto holidayForm = new HolidayFormDto();
                // 숫자로 넘어오는 날짜를 YYYY-MM-DD형식의 문자열로 변환하여 저장
                String hd = String.valueOf(holiday.getLocdate());
                String sd = hd.substring(0,4)+"-"+hd.substring(4,6)+"-"+hd.substring(6,8);
                holidayForm.setHolidayDate(sd);
                holidayForm.setHolidayName(holiday.getDateName());
                
                // 공휴일이면 저장
                if(holiday.getIsHoliday().equals("Y")) {
                	holidayMapper.insertHoliday(holidayForm);
                }else {
                	continue;
                }
                
            }
        }
    }
}
