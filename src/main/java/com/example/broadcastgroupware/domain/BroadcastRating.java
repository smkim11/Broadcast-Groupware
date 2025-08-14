package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class BroadcastRating {
	private int broadcastRatingId;
	private int broadcastEpisodeId;
	private double broadcastRating;
	private String createDate;
}
