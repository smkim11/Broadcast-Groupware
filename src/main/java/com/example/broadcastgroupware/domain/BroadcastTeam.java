package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class BroadcastTeam {
	private int broadcastTeamId;
	private int broadcastScheduleId;
	private int userId;
	private String createDate;
}
