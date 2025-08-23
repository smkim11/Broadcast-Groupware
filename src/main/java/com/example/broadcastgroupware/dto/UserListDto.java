package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class UserListDto {
	private int userId;				// 사용자 pk
	private String fullname;		// 사용자 이름
	private String userRank;		// 사용자 직급
	private String profileImage;	// 프로필 이미지 경로(없으면 기본 아바타 경로)
}
