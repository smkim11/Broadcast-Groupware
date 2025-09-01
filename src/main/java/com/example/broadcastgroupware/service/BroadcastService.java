package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.BroadcastTeamRowDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.mapper.BroadcastMapper;

@Service
public class BroadcastService {

    private final BroadcastMapper broadcastMapper;

    public BroadcastService(BroadcastMapper broadcastMapper) {
        this.broadcastMapper = broadcastMapper;
    }
    
    // 요일 변환 공통
    private static boolean on(Integer v) { return v != null && v == 1; }

    // 요일 플래그(0/1) -> 화면용 요일 목록
    private static void computeDays(BroadcastFormDto dto) {
        List<String> days = new ArrayList<>(7);
        if (on(dto.getBroadcastMonday())) days.add("월");
        if (on(dto.getBroadcastTuesday())) days.add("화");
        if (on(dto.getBroadcastWednesday())) days.add("수");
        if (on(dto.getBroadcastThursday())) days.add("목");
        if (on(dto.getBroadcastFriday())) days.add("금");
        if (on(dto.getBroadcastSaturday())) days.add("토");
        if (on(dto.getBroadcastSunday())) days.add("일");

        dto.setBroadcastDays(days);
        dto.setBroadcastDaysText(days.isEmpty() ? "-" : String.join(" / ", days));
    }

    
    // 방송편성 목록 조회
    public Map<String, Object> getBroadcastList(String keyword, int currentPage, int rowPerPage) {
        // 전체 행 개수 조회
        int totalCount = broadcastMapper.countBroadcasts(keyword);

        // PageDto 생성
        PageDto pageDto = new PageDto(currentPage, rowPerPage, totalCount, keyword);

        // 방송편성 목록 조회
        List<BroadcastFormDto> rows = broadcastMapper.selectBroadcasts(
        	keyword, pageDto.getBeginRow(), pageDto.getRowPerPage()
        );
        
        // 요일 변환
        for (BroadcastFormDto dto : rows) {
        	computeDays(dto);
        }

        Map<String, Object> model = new HashMap<>();
        model.put("programs", rows);
        model.put("pageDto", pageDto);  // JSP에서 pageDto로 접근
        return model;
    }
        
    // 방송편성 상세 조회
    public BroadcastFormDto getBroadcastDetail(int id) {
        BroadcastFormDto dto = broadcastMapper.selectBroadcastDetail(id);
        if (dto == null) return null;

        // 요일 변환
        computeDays(dto);
        
        return dto;
    }

}
