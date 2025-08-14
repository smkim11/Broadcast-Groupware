package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ReferenceLine {
	private int referenceLineId;
	private int approvalDocumentId;
	private int userId;
	private String createDate;
}
