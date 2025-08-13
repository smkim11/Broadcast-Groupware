package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Board {
	private int boardId;
	private String boardTitle;
	private String boardStatus;
	private String createDate;
	private String updateDate;
}
