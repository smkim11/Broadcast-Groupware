package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class CarReservationDto {
	private int vehicleId;
	private String vehicleStatus;
	private String vehicleNo;
	private String vehicleType;
	private String vehicleName;
	private String createDate;
	
	private int vehicleReservationId;
	private int userId;
	private String reservationStart;
	private String reservationEnd;
	private String updateDate;
}
