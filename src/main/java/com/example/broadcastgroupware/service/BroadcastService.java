package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.BroadcastEpisode;
import com.example.broadcastgroupware.domain.BroadcastTeam;
import com.example.broadcastgroupware.domain.Department;
import com.example.broadcastgroupware.domain.Team;
import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.BroadcastTeamRowDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.UserRowDto;
import com.example.broadcastgroupware.mapper.BroadcastEpisodeMapper;
import com.example.broadcastgroupware.mapper.BroadcastProgramMapper;
import com.example.broadcastgroupware.mapper.BroadcastTeamMapper;

@Service
public class BroadcastService {

    private final BroadcastProgramMapper broadcastProgramMapper;
    private final BroadcastTeamMapper broadcastTeamMapper;
    private final BroadcastEpisodeMapper broadcastEpisodeMapper;

    public BroadcastService(BroadcastProgramMapper broadcastProgramMapper, BroadcastTeamMapper broadcastTeamMapper,
    						BroadcastEpisodeMapper broadcastEpisodeMapper) {
        this.broadcastProgramMapper = broadcastProgramMapper;
        this.broadcastEpisodeMapper = broadcastEpisodeMapper;
        this.broadcastTeamMapper = broadcastTeamMapper;
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
        int total = broadcastTeamMapper.countBroadcastTeamBySchedule(scheduleId);  // 전체 인원 수
        int lastPage = Math.max(1, (int) Math.ceil((double) total / size));    // 마지막 페이지 번호
        int safePage = Math.max(1, Math.min(page, lastPage));				   // 유효한 페이지 번호 보정
        int beginRow = (safePage - 1) * size;								   // 조회 시작 행

        // 페이징된 팀원 목록 조회
        List<BroadcastTeamRowDto> rows =
        		broadcastTeamMapper.selectBroadcastTeamBySchedule(scheduleId, beginRow, size);

        // 결과 Map 구성
        Map<String, Object> out = new HashMap<>();
        out.put("totalCount", total);       // 총 인원 수
        out.put("page", safePage);          // 현재 페이지
        out.put("size", size);              // 페이지 크기
        out.put("beginRow", beginRow + 1);  // 화면 번호 시작값
        out.put("rows", rows);              // 팀원 목록
        return out;
    }
    
    
    // 프로그램 팀원 등록 (반환값: 1=성공, -1=중복, -2=정원초과, -3=권한없음)
    @Transactional
    public int addBroadcastTeam(int scheduleId, int userId, int loginUserId) {
        if (loginUserId > 0) {
        	// 등록 권한 여부 확인
            if (broadcastTeamMapper.existsOwnerByScheduleAndUser(scheduleId, loginUserId) != 1) {
                return -3;  // 권한 없음
            }
        }

        // 중복 등록 차단
        if (broadcastTeamMapper.existsBroadcastTeam(scheduleId, userId) > 0) {
            return -1;  // 이미 등록됨
        }

        // 정원 검사
        Integer capacity = broadcastTeamMapper.selectCapacityBySchedule(scheduleId);
        if (capacity != null && capacity > 0) {
            int assigned = broadcastTeamMapper.countBroadcastTeamBySchedule(scheduleId);
            
            // 정원이 가득 찼다면 등록 불가
            if (assigned >= capacity) {
                return -2;  // 정원 초과
            }
        }

        // 등록
        BroadcastTeam row = new BroadcastTeam();
        row.setBroadcastScheduleId(scheduleId);
        row.setUserId(userId);
        return broadcastTeamMapper.insertBroadcastTeam(row);  // 성공 시 1 반환
    }
    
    // 부서 목록 (드롭다운)
    public List<Department> listDepartments() {
        return broadcastTeamMapper.listDepartments();
    }

    // 부서별 팀 목록 (드롭다운)
    public List<Team> listTeamsByDepartment(int departmentId) {
        return broadcastTeamMapper.listTeamsByDepartment(departmentId);
    }

    // 등록 가능 사용자 목록 (드롭다운)
    public List<UserRowDto> listAssignableUsersByTeam(int scheduleId, int teamId) {
        return broadcastTeamMapper.listAssignableUsersByTeam(scheduleId, teamId);
    }

    // 기안자(=대표자) 권한 확인
    public boolean isOwner(int scheduleId, int loginUserId) {
        return broadcastTeamMapper.existsOwnerByScheduleAndUser(scheduleId, loginUserId) == 1;
    }
    
    
    // 프로그램 팀원 삭제
    @Transactional
    public int deleteBroadcastTeam(List<Integer> ids) {
        return (ids == null || ids.isEmpty()) ? 0 : broadcastTeamMapper.deleteBroadcastTeamByIds(ids);
    }

    
    // 회차 목록 + 페이징
    public Map<String, Object> getEpisodeList(int scheduleId, int page, int size) {
    	int total = broadcastEpisodeMapper.countEpisodesByScheduleId(scheduleId);
    	int lastPage = Math.max(1, (int) Math.ceil((double) total / size));
    	int safePage = Math.max(1, Math.min(page, lastPage));
    	int beginRow = (safePage - 1) * size;
    	
    	// 페이징된 회차 목록 조회
    	List<BroadcastEpisode> rows =
    			broadcastEpisodeMapper.selectEpisodesBySchedule(scheduleId, beginRow, size);
    	
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
        return broadcastEpisodeMapper.updateEpisodeComment(episodeId, normalized);
    }
    
}
