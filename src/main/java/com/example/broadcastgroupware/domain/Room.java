package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Room {
	private int roomId;
	private String roomType;
	private String roomName;
	private String roomLocation;
	private int roomCapacity;
	private String roomStatus;
	private String createDate;
}
