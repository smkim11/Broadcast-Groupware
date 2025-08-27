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
	int insertApprovalDocument(ApprovalDocument doc);
    int insertVacationForm(VacationForm form);
    int insertBroadcastForm(BroadcastForm form);
    int insertBroadcastWeekday(BroadcastWeekday weekday);
    // int insertDocumentFile(File file);
    
    // 결재선
    int insertApprovalLines(@Param("lines") List<ApprovalLine> lines);
    List<ApprovalLine> selectApprovalLines(@Param("approvalDocumentId") int approvalDocumentId);

    // 참조선
    int insertReferenceLines(@Param("refs") List<ReferenceLine> refs);
    List<ReferenceLine> selectReferenceLines(@Param("approvalDocumentId") int approvalDocumentId);
    List<Integer> selectUserIdsByTeamIds(@Param("teamIds") List<Integer> teamIds);

    // 문서 상태 변경
    int updateDocumentStatus(@Param("approvalDocumentId") int approvalDocumentId,
            				@Param("status") String status);
}
