package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class HolidayDto {
	private String dateKind;
	private String dateName;
	private String isHoliday;
	private int locdate;
	private int seq;
	private String remarks;
}
