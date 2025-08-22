package com.example.broadcastgroupware.service;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;

import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.example.broadcastgroupware.dto.HolidayDto;
import com.example.broadcastgroupware.mapper.HolidayMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class HolidayService {
	private final RestTemplate restTemplate;
	private HolidayMapper holidayMapper;
	public HolidayService(RestTemplateBuilder builder) {
		this.restTemplate = builder.build();
		this.holidayMapper = holidayMapper;
	}
	
	// 공휴일 api로 원하는 년도 공휴일 조회
	public void getHolidays(String year) throws UnsupportedEncodingException, URISyntaxException, JsonProcessingException, IllegalArgumentException {
        String serviceKey = "X5crsn5JobgfMEbWjbf2jZ8751ZRHfZPmGLvOmiwf9VxUxRS5PgbuzO2HNu%2BVyjQvk9%2B2c2A1%2B%2FtVSM%2FvPUSyw%3D%3D"; // 본인 서비스 키
        String url = "http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getHoliDeInfo"
                + "?serviceKey=" + serviceKey
                + "&pageNo=1"
                + "&numOfRows=100"
                + "&solYear=" + year;
        // URI를 이용해서 url을 인코딩하여 보내서 인식하지 못하던것들을 인식하게한다
        URI uri = new URI(url);
        String json = restTemplate.getForObject(url, String.class);

        // JSON으로된 정보들을 DTO로 변환하여 DB에 저장
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(json);
        JsonNode items = root.path("response").path("body").path("items").path("item");

        if (items.isArray()) {
            for (JsonNode node : items) {
                HolidayDto holiday = mapper.treeToValue(node, HolidayDto.class);
                
                if(holiday.getIsHoliday() == "Y") {
                	holidayMapper.insertHoliday(holiday);
                }else {
                	return;
                }
                
            }
        }
    }
}
