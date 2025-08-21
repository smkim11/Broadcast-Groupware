package com.example.broadcastgroupware.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
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
	public List<HashMap<String,Object>> selectTotalCalendar(int userId){
		return calendarMapper.selectTotalCalendar(userId);
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
	/*
	private final String SERVICE_KEY = "X5crsn5JobgfMEbWjbf2jZ8751ZRHfZPmGLvOmiwf9VxUxRS5PgbuzO2HNu%2BVyjQvk9%2B2c2A1%2B%2FtVSM%2FvPUSyw%3D%3D";

    public String getHolidays(String year) {
        try {
            String apiURL = "http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getHoliDeInfo"
                    + "?numOfRows=100&solYear=" + year
                    + "&ServiceKey=" + SERVICE_KEY
                    + "&_type=json"; // JSON 요청

            HttpURLConnection conn = (HttpURLConnection) new URL(apiURL).openConnection();
            conn.setRequestMethod("GET");

            int responseCode = conn.getResponseCode();
            BufferedReader br = new BufferedReader(new InputStreamReader(
                    (responseCode == 200) ? conn.getInputStream() : conn.getErrorStream()
            ));

            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            br.close();

            return response.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    */
}
