package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class VehicleReservation {
	private int vehicleReservationId;
	private int userId;
	private int vehicleId;
	private String vehicleReservationStartTime;
	private String vehicleReservationEndTime;
	private String createDate;
	private String updateDate;
}
