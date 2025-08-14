package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ApprovalLine {
	private int approvalLineId;
	private int approvalDocumentId;
	private int userId;
	private int approvalLineSequence;
	private String approvalLineStatus;  // '승인','반려','대기'
	private String approvalLineComment;
	private String createDate;
}
