package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class CarToggle {
	private int vehicleId;
	private String vehicleUseReasonContent;
	private String vehicleUseReasonStartDate;
	private String vehicleUseReasonEndDate;
	private String vehicleStatus;
}
