package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.ApprovalLine;
import com.example.broadcastgroupware.domain.BroadcastForm;
import com.example.broadcastgroupware.domain.BroadcastWeekday;
import com.example.broadcastgroupware.domain.ReferenceLine;
import com.example.broadcastgroupware.domain.VacationForm;

@Mapper
public interface ApprovalMapper {
	
	// ===== 문서 작성 =====
	
	// 일반 문서
	int insertApprovalDocument(ApprovalDocument doc);
	// 휴가 폼
    int insertVacationForm(VacationForm form);
    // 방송 폼
    int insertBroadcastForm(BroadcastForm form);	
    // 방송 요일
    int insertBroadcastWeekday(BroadcastWeekday weekday);
    
    
    // ===== 결재선/참조선 =====
    
    // 결재선
    int insertApprovalLines(@Param("lines") List<ApprovalLine> lines);
    // 참조선
    int insertReferenceLines(@Param("refs") List<ReferenceLine> refs);
    
        
    // 팀 ID로 사용자 ID 조회
    List<Integer> selectUserIdsByTeamIds(@Param("teamIds") List<Integer> teamIds);
    
    
    // ===== 결재 (승인/반려) =====
    
    // 결재선 상태/코멘트 갱신 (대기 -> 승인/반려)
    int updateMyApprovalLineDecision(@Param("approvalDocumentId") int approvalDocumentId,
                                     @Param("userId") int userId,
                                     @Param("status") String status,
                                     @Param("comment") String comment);

    // 다음 차수 활성화 (NULL -> 대기)
    int activateNextApprover(@Param("approvalDocumentId") int approvalDocumentId,
                             @Param("nextSequence") int nextSequence);
    
    // 문서 상태 변경
    int updateDocumentStatus(@Param("approvalDocumentId") int approvalDocumentId,
            				@Param("status") String status);
    
    
    
}
