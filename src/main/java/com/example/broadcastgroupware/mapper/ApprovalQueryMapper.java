package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.dto.ApprovalDocumentDto;

@Mapper
public interface ApprovalQueryMapper {	
    
	// ===== 내 문서함 조회 (목록 조회) =====
    
    // 진행 중 문서 목록
    List<ApprovalDocumentDto> selectInProgressDocuments(@Param("userId") int userId);

    // 종료 목록 문서 (승인 + 반려)
    List<ApprovalDocumentDto> selectCompletedDocuments(@Param("userId") int userId,
    												   @Param("status") String status);

    // 임시저장 목록 문서
    List<ApprovalDocumentDto> selectDraftDocuments(@Param("userId") int userId);
    
    
    // ===== 내 문서함 조회 (문서 상세 조회) =====
    
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

    
    // ===== 문서 수정 및 삭제 =====
    
    // 최초 결재자의 현재 상태
    String selectFirstApproverStatus(@Param("approvalDocumentId") int approvalDocumentId);

    // 문서 기안자 ID
    Integer selectDrafterIdByDocumentId(@Param("approvalDocumentId") int approvalDocumentId);
    
    
    // ===== 결재 (승인/반려) =====
    
    // 현재 '대기' 차수
    Integer selectCurrentPendingSequence(int approvalDocumentId);

    // 해당 문서에서 사용자의 결재선 (차수/상태)
    Map<String,Object> selectUserApprovalLine(@Param("approvalDocumentId") int approvalDocumentId,
                                              @Param("userId") int userId);
    
    // 다음 활성화될 차수 (status IS NULL 중 가장 작은 차수)
    Integer selectNextSequenceToActivate(int approvalDocumentId);
    
    // 결재자 최신 서명 파일의 전체 경로
    String selectLatestSignatureByUser(@Param("userId") int userId);
    

	// ===== 받은 문서함 조회 (목록 조회) =====
    
    // 사용자가 현재 '대기'인 문서
	List<ApprovalDocumentDto> selectMyPendingApprovals(@Param("userId") int userId);
	
	// 사용자는 '승인' + 문서는 아직 진행 중
	List<ApprovalDocumentDto> selectMyInProgressApprovals(@Param("userId") int userId);
	
	// 종료 (최종 승인/반려) + 필터
	List<ApprovalDocumentDto> selectMyCompletedApprovals(@Param("userId") int userId,
            											@Param("status") String status);
    // 참조 목록 문서
    List<ApprovalDocumentDto> selectReferencedDocuments(@Param("userId") int userId);
    
    
    // ===== 회차 =====
    
    // 결재라인 ID로 공통 양식(approval_document) ID 조회
    Integer selectApprovalDocumentIdByLine(@Param("approvalLineId") int approvalLineId);
}
