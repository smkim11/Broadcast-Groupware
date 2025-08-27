package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class MyReservationRoom {
	private int roomReservationId;
	private int roomId;
	private String roomName;
	private String roomLocation;
    private String roomReservationReason;
    private String roomReservationStartTime; 
    private String roomReservationEndTime;  
}
