package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class VehicleUseReason {
	private int vehickeUseReasonId;
	private int vehicleId;
	private String vehicleUseReasonContent;
	private String vehicleUseReasonStartDate;
	private String vehicleUseReasonEndDate;
	private	String createDate;
}
