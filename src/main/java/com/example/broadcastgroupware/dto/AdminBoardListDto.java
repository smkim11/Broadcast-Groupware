package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class AdminBoardListDto {
	private int boardId;
	private int postId;
	private String boardTitle;
	private String boardStatus;
	private String title;
	private String postStatus;
	private String fixed;
	private String userName;
	private String createDate;
}
