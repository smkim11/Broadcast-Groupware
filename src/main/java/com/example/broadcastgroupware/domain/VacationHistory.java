package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class VacationHistory {
	private int vacationHistoryId;
	private int approvalLineId;
	private double vacationHistoryDay;
	private String createDate;
}
