package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Team {
	private int teamId;
	private int departmentId;
	private String teamName;
	private String createDate;
}
