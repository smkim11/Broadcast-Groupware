package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.BroadcastEpisode;
import com.example.broadcastgroupware.domain.BroadcastTeam;
import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.BroadcastTeamRowDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.mapper.BroadcastEpisodeMapper;
import com.example.broadcastgroupware.mapper.BroadcastProgramMapper;
import com.example.broadcastgroupware.mapper.BroadcastTeamMapper;

@Service
public class BroadcastService {

    private final BroadcastProgramMapper broadcastProgramMapper;
    private final BroadcastTeamMapper broadcastteamMapper;
    private final BroadcastEpisodeMapper broadcastepisodeMapper;

    public BroadcastService(BroadcastProgramMapper broadcastProgramMapper, BroadcastTeamMapper broadcastteamMapper,
    						BroadcastEpisodeMapper broadcastepisodeMapper) {
        this.broadcastProgramMapper = broadcastProgramMapper;
        this.broadcastepisodeMapper = broadcastepisodeMapper;
        this.broadcastteamMapper = broadcastteamMapper;
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
        int totalCount = broadcastProgramMapper.countBroadcasts(keyword);

        // PageDto 생성
        PageDto pageDto = new PageDto(currentPage, rowPerPage, totalCount, keyword);

        // 방송편성 목록 조회
        List<BroadcastFormDto> rows = broadcastProgramMapper.selectBroadcasts(
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
        BroadcastFormDto dto = broadcastProgramMapper.selectBroadcastDetail(id);
        if (dto == null) return null;

        // 요일 변환
        computeDays(dto);
        
        return dto;
    }
        
    
    // 프로그램별 팀원 목록 페이징 조회
    public Map<String, Object> getBroadcastTeamPage(int scheduleId, int page, int size) {
        int total = broadcastteamMapper.countBroadcastTeamBySchedule(scheduleId);  // 전체 인원 수
        int lastPage = Math.max(1, (int) Math.ceil((double) total / size));    // 마지막 페이지 번호
        int safePage = Math.max(1, Math.min(page, lastPage));				   // 유효한 페이지 번호 보정
        int beginRow = (safePage - 1) * size;								   // 조회 시작 행

        // 페이징된 팀원 목록 조회
        List<BroadcastTeamRowDto> rows =
        		broadcastteamMapper.selectBroadcastTeamBySchedule(scheduleId, beginRow, size);

        // 결과 Map 구성
        Map<String, Object> out = new HashMap<>();
        out.put("totalCount", total);       // 총 인원 수
        out.put("page", safePage);          // 현재 페이지
        out.put("size", size);              // 페이지 크기
        out.put("beginRow", beginRow + 1);  // 화면 번호 시작값
        out.put("rows", rows);              // 팀원 목록
        return out;
    }
    
    
    // 프로그램 팀원 등록
    @Transactional
    public int addBroadcastTeam(int scheduleId, int userId) {
        // 중복 체크
        if (broadcastteamMapper.existsBroadcastTeam(scheduleId, userId) > 0) {
            return -1;  // 이미 등록됨
        }
        // 정원 체크
        Integer capacity = broadcastteamMapper.selectCapacityBySchedule(scheduleId);
        if (capacity != null && capacity > 0) {
            int assigned = broadcastteamMapper.countBroadcastTeamBySchedule(scheduleId);
            if (assigned >= capacity) {
                return -2;  // 정원 초과
            }
        }
        BroadcastTeam row = new BroadcastTeam();
        row.setBroadcastScheduleId(scheduleId);
        row.setUserId(userId);
        return broadcastteamMapper.insertBroadcastTeam(row);  // 1 등록 성공
    }

    // 프로그램 팀원 삭제
    @Transactional
    public int deleteBroadcastTeam(List<Integer> ids) {
        return (ids == null || ids.isEmpty()) ? 0 : broadcastteamMapper.deleteBroadcastTeamByIds(ids);
    }

    
    // 회차 목록 + 페이징
    public Map<String, Object> getEpisodeList(int scheduleId, int page, int size) {
    	int total = broadcastepisodeMapper.countEpisodesByScheduleId(scheduleId);
    	int lastPage = Math.max(1, (int) Math.ceil((double) total / size));
    	int safePage = Math.max(1, Math.min(page, lastPage));
    	int beginRow = (safePage - 1) * size;
    	
    	// 페이징된 회차 목록 조회
    	List<BroadcastEpisode> rows =
    			broadcastepisodeMapper.selectEpisodesBySchedule(scheduleId, beginRow, size);
    	
    	// 결과 Map 구성
    	Map<String, Object> out = new HashMap<>();
    	out.put("totalCount", total);  // 총 회차 수
    	out.put("page", safePage);
    	out.put("size", size);
    	out.put("rows", rows);		   // 회차 목록
    	return out;
    }
    
    // 회차 소제목(코멘트) 수정
    @Transactional
    public int updateEpisodeComment(int episodeId, String comment) {
    	// 공백만 입력되면 DB에는 NULL로 저장
        String normalized = (comment != null && comment.isBlank()) ? null : comment;
        return broadcastepisodeMapper.updateEpisodeComment(episodeId, normalized);
    }
    
}
