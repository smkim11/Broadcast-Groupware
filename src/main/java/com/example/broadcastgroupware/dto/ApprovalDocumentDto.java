package com.example.broadcastgroupware.dto;

import java.util.List;

import lombok.Data;

@Data
public class ApprovalDocumentDto {
    private Integer approvalDocumentId;
    private Integer userId;
    private String approvalDocumentTitle;
    private String approvalDocumentContent;
    private String approvalDocumentSave;  // 'Y' = 임시저장 | 'N' = 제출 (기본값)
    private String createDate;
    private String updateDate;
    
    private VacationFormDto vacationForm;           // 휴가 문서면 입력
    private BroadcastFormDto broadcastForm;         // 방송 문서면 입력
    private List<ApprovalLineDto> approvalLines;    // 결재선
    private List<ReferenceLineDto> referenceLines;  // 참조선
    private List<Integer> referenceTeamIds;
}
