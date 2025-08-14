package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class BroadcastEpisode {
	private int broadcastEpisodeId;
	private int broadcastScheduleId;
	private int broadcastEpisodeNo;
	private String broadcastEpisodeDate;
	private String broadcastEpisodeWeekday;
	private String broadcastEpisodeComment;
	private String createDate;
}
