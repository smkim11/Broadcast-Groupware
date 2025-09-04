package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.BroadcastTeam;
import com.example.broadcastgroupware.dto.BroadcastTeamRowDto;

@Mapper
public interface BroadcastTeamMapper {
	// 프로그램별 팀원 수
    int countBroadcastTeamBySchedule(@Param("scheduleId") int scheduleId);

    // 프로그램별 팀원 목록 (페이징)
    List<BroadcastTeamRowDto> selectBroadcastTeamBySchedule(@Param("scheduleId") int scheduleId,
				                                            @Param("beginRow") int beginRow,
				                                            @Param("rowPerPage") int rowPerPage);
    
    // 프로그램 팀원 중복 여부
    int existsBroadcastTeam(@Param("scheduleId") int scheduleId,
                            @Param("userId") int userId);

    // 프로그램 팀 정원
    int selectCapacityBySchedule(@Param("scheduleId") int scheduleId);

    // 프로그램 팀원 등록
    int insertBroadcastTeam(BroadcastTeam row);

    // 프로그램 팀원 삭제
    int deleteBroadcastTeamByIds(@Param("ids") List<Integer> ids);
}
