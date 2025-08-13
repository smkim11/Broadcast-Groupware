package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Vacation {
	private int vacationId;
	private int userId;
	private double vacationAnnualTotal;
	private double vacationAnnualUse;
	private String createDate;
	private String updateDate;
}
