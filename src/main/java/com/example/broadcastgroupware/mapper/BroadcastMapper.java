package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.BroadcastTeamRowDto;

@Mapper
public interface BroadcastMapper {
	
	// 방송편성 목록 총 개수
    int countBroadcasts(@Param("keyword") String keyword);

    // 방송편성 목록 (검색 + 페이징)
    List<BroadcastFormDto> selectBroadcasts(@Param("keyword") String keyword,
                                            @Param("beginRow") int beginRow,
                                            @Param("rowPerPage") int rowPerPage);

    // 방송편성 상세
    BroadcastFormDto selectBroadcastDetail(@Param("scheduleId") int scheduleId);

    // 프로그램별 팀원 수
    int countBroadcastTeamBySchedule(@Param("scheduleId") int scheduleId);

    // 프로그램별 팀원 목록 (페이징)
    List<BroadcastTeamRowDto> selectBroadcastTeamBySchedule(@Param("scheduleId") int scheduleId,
				                                            @Param("beginRow") int beginRow,
				                                            @Param("rowPerPage") int rowPerPage);

}
