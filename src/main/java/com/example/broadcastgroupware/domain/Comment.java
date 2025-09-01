package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Comment {
	private int commentId;
	private int postId;
	private int userId;
	private String commentContent;
	private int commentParent;
	private String commentStatus;
	private String createDate;
	private String updateDate;
}
