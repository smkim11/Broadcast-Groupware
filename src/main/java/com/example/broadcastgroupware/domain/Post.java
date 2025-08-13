package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Post {
	private int postId;
	private int boardId;
	private int userId;
	private String postTitle;
	private String postContent;
	private String postStatus;
	private String createDate;
	private String updateDate;
}
