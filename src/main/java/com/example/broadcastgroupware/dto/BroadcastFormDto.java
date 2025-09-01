package com.example.broadcastgroupware.dto;

import java.util.List;

import lombok.Data;

@Data
public class BroadcastFormDto {
	private Integer broadcastScheduleId;
	private Integer broadcastFormId;
    private Integer approvalDocumentId;
    private String broadcastFormName;
    private Integer broadcastFormCapacity;
    private String broadcastFormStartDate;
    private String broadcastFormEndDate;
    private String broadcastFormStartTime;
    private String broadcastFormEndTime;
    
    // DB 요일 플래그 (0/1)
    private Integer broadcastMonday;
    private Integer broadcastTuesday;
    private Integer broadcastWednesday;
    private Integer broadcastThursday;
    private Integer broadcastFriday;
    private Integer broadcastSaturday;
    private Integer broadcastSunday;
    
    // 요일 화면 표시
    private List<String> broadcastDays;  // 체크된 요일 코드: ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    private String broadcastDaysText;
    
    // 상세 조회
    private Integer userId;			// 결재 문서 작성자 ID (대표자)
    private String fullName;		// 대표자 이름
    private Integer episodesCount;  // 회차 수
}