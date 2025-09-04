package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.BroadcastSchedule;

@Mapper
public interface BroadcastScheduleMapper {
    // 프로그램 생성
    int insertBroadcastSchedule(BroadcastSchedule schedule);

    // 결재 라인 기준으로 이미 생성된 편성 재사용
    Integer findScheduleIdByApprovalLineId(@Param("approvalLineId") int approvalLineId);
}
