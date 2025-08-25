package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class AddIssueToRoom {
	private int roomId;
	private String roomStatus;
	private String roomReservationStartTime;
	private String roomReservationEndTime;
	private String roomUseReasonContent;
	private String roomUseReasonStartDate;
	private String roomUseReasonEndDate;
}
