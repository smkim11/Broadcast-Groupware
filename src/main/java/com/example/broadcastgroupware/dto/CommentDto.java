package com.example.broadcastgroupware.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class CommentDto {
	private int commentId;
	private int postId;
	private String userName;
	private String userRank;
	private String commentContent;
	private int commentParent;
	private String commentStatus;
	private String createDate;
	private String updateDate;
	
	private List<CommentDto> replies = new ArrayList<>();
}
