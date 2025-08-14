package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class BroadcastForm {
	private int broadcastFormId;
	private int approvalDocumentId;
	private String broadcastFormName;
	private int broadcastFormCapacity;
	private String broadcastFormStartDate;
	private String broadcastFormEndDate;
	private String broadcastFormStartTime;
	private String broadcastFormEndTime;
	private String createDate;
	private String updateDate;
}
