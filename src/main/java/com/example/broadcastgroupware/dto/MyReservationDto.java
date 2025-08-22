package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class MyReservationDto {
	private int vehicleReservationId;
	private int userId;
	private String vehicleNo;
	private String rentDate;
	private String returnDate;
}
