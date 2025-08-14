package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class BroadcastWeekday {
	private int broadcastWeekdayId;
	private int broadcastFormId;
	private int broadcastSunday;
	private int broadcastMonday;
	private int broadcastTuesday;
	private int broadcastWednesday;
	private int broadcastThursday;
	private int broadcastFriday;
	private int broadcastSaturday;
	private String createDate;
}
