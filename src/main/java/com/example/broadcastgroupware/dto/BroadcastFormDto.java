package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class BroadcastFormDto {
	private Integer broadcastFormId;
    private Integer approvalDocumentId;
    private String broadcastFormName;
    private Integer broadcastFormCapacity;
    private String broadcastFormStartDate;
    private String broadcastFormEndDate;
    private String broadcastFormStartTime;
    private String broadcastFormEndTime;
}