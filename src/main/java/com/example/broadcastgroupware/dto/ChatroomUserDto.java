package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class ChatroomUserDto {
	private Integer userId;
	private String fullName;
	private String userRank;
	private String avatarPath;	// null이면 기본 이미지
}
