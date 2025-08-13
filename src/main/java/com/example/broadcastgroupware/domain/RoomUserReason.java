package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class RoomUserReason {
	private int roomUseReasonId;
	private int roomId;
	private String roomUseReasonContent;
	private String roomUseReasonStartDate;
	private String roomUseReasonEndDate;
	private String createDate;
}
