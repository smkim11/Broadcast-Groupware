package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class ApprovalLineDto {
	private Integer userId;             // 결재자
    private Integer approvalLineSequence; 
    private String approvalLineStatus;  // 승인,반려,대기
    private String approvalLineComment;
}
