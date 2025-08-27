package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class DeploymentHistory {
	private int deploymentHistoryId;
	private int userId;
	private int teamId;
	private String createDate;
}
