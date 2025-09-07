package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

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
	
	// 공통/일반 문서
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
    
    
    // ===== 문서 수정 =====

	// 공통/일반 문서
	int updateApprovalDocument(@Param("approvalDocumentId") int approvalDocumentId,
                               @Param("title") String title,
                               @Param("content") String content);
	// 휴가 폼
	int updateVacationForm(@Param("approvalDocumentId") int approvalDocumentId,
						   @Param("vacationForm") VacationForm vacationForm);
	// 방송 폼
	int updateBroadcastForm(@Param("approvalDocumentId") int approvalDocumentId,
							@Param("broadcastForm") BroadcastForm broadcastForm);
	// 방송 요일
	int updateBroadcastWeekday(@Param("broadcastFormId") int broadcastFormId,
							   @Param("weekday") BroadcastWeekday weekday);
	
	// 문서 ID로 방송 폼 PK 조회 (요일 갱신/삭제 전 formId 추출)
	Integer selectBroadcastFormIdByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
	
	
	// ===== 문서 삭제 (FK 제약 때문에 자식 테이블부터 삭제) =====
	
	// 휴가 폼
	int deleteVacationFormByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
	// 방송 폼
	int deleteBroadcastFormByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
	// 방송 요일
	int deleteBroadcastWeekdayByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
	// 공통/일반 문서
	int deleteDocumentById(@Param("approvalDocumentId") int approvalDocumentId);
	
	// 결재선/참조선 전체 삭제
	int deleteApprovalLinesByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
	int deleteReferenceLinesByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
		 
    
	// ===== 그 외 =====
	
    // home화면 문서 현황 조회
    Map<String, Object> selectHomeDocCounts(@Param("userId") int userId);
    
}
