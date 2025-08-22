package com.example.broadcastgroupware.dto;

import java.util.List;

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
    
    // 체크된 요일 코드: ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    private List<String> broadcastDays;
}