package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Calendar {
	private int calendarId;
	private int userId;
	private String calendarTitle;
	private String calendarLocation;
	private String calendarType;
	private String calendarMemo;
	private String calendarStartTime;
	private String calendarEndTime;
	private String createDate;
	private String updateDate;
}
