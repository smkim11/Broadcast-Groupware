package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class PostDetailDto {
	private int postId;
	private int userId;
	private String postTitle;
	private String postContent;
	private String postStatus;
	private String createDate;
	private String userName;
	private String userRank;
	
	private String topFixed;
}
