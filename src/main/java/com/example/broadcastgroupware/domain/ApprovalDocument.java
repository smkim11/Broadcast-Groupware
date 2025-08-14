package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ApprovalDocument {
	private int approvalDocumentId;
	private int userId;
	private String approvalDocumentTitle;
	private String approvalDocumentContent;
	private String approvalDocumentSave;  // 'Y','N'
	private String createDate;
	private String updateDate;
}
