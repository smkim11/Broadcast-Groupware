package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ApprovalDocument {
	private int approvalDocumentId;
	private int userId;
	private String approvalDocumentTitle;
	private String approvalDocumentContent;
	private String approvalDocumentStatus;  // '임시저장','진행 중','승인','반려'
	private String createDate;
	private String updateDate;
}
