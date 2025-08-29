package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.ApprovalLine;
import com.example.broadcastgroupware.domain.ReferenceLine;
import com.example.broadcastgroupware.dto.ApprovalDocumentDto;

@Mapper
public interface ApprovalQueryMapper {	
    
	// ===== 문서 상태별 목록 조회 =====
    
    // 진행 중 문서 목록 조회
    List<ApprovalDocumentDto> selectInProgressDocuments(@Param("userId") int userId);

    // 결재 완료 목록 문서 (승인 + 반려)
    List<ApprovalDocumentDto> selectCompletedDocuments(@Param("userId") int userId);

    // 임시저장 목록 문서
    List<ApprovalDocumentDto> selectDraftDocuments(@Param("userId") int userId);

    // 참조 목록 문서
    List<ApprovalDocumentDto> selectReferencedDocuments(@Param("userId") int userId);
    
    
    // ===== 문서 상세 조회 =====
    
    // 문서 + 기안자 정보
    Map<String, Object> selectDocumentDetail(@Param("approvalDocumentId") int approvalDocumentId);

    // 방송 폼 상세 (+ 방송 요일)
    Map<String, Object> selectBroadcastFormDetail(@Param("approvalDocumentId") int approvalDocumentId);

    // 휴가 폼 상세
    Map<String, Object> selectVacationFormDetail(@Param("approvalDocumentId") int approvalDocumentId);
    
    // 결재선 상세
    List<Map<String, Object>> selectApprovalLinesByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);

    // 참조선 상세 (개인 기준)
    List<Map<String, Object>> selectReferenceLinesByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
    
    // 팀 인원 수
    List<Map<String, Object>> selectTeamMemberCountsByIds(@Param("teamIds") List<Integer> teamIds);

    
    // ===== 그 외 =====
    
    // 최초 결재자의 현재 상태
    String selectFirstApproverStatus(@Param("approvalDocumentId") int approvalDocumentId);

    // 문서 기안자 ID
    Integer selectDrafterIdByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);

}
