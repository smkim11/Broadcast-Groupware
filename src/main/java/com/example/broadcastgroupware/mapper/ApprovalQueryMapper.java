package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.ApprovalLine;
import com.example.broadcastgroupware.domain.ReferenceLine;

@Mapper
public interface ApprovalQueryMapper {
	
	// ===== 결재선/참조선 조회 =====
	
	// 결재선 조회
	List<ApprovalLine> selectApprovalLines(@Param("approvalDocumentId") int approvalDocumentId);
	
	// 결재선 상태별 카운트 조회
	Map<String, Object> selectApprovalLineStatusCounts(@Param("approvalDocumentId") int approvalDocumentId);
	
	// 참조선 조회
    List<ReferenceLine> selectReferenceLines(@Param("approvalDocumentId") int approvalDocumentId);
	
    
	// ===== 문서 상태별 목록 조회 =====
    
    // 진행 중 문서 목록 조회
    List<ApprovalDocument> selectInProgressDocuments(@Param("userId") int userId);

    // 결재 완료 목록 문서 (승인 + 반려)
    List<ApprovalDocument> selectCompletedDocuments(@Param("userId") int userId);

    // 임시저장 목록 문서
    List<ApprovalDocument> selectDraftDocuments(@Param("userId") int userId);

    // 참조 목록 문서
    List<ApprovalDocument> selectReferencedDocuments(@Param("userId") int userId);
}
