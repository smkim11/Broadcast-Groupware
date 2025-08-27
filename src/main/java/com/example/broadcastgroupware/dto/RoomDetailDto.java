package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class RoomDetailDto {
	private String userName;
	private String userRank;
	private String roomReservationReason;
	private String roomReservationStartTime;
	private String roomReservationEndTime;
}
