package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class RoomReservation {
	private int roomReservationId;
	private int userId;
	private int roomId;
	private String roomReservationStartTime;
	private String roomReservationEndTime;
	private String createDate;
	private String updateDate;
}
