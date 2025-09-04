package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class UserListDto {
	private int userId;				// 사용자 pk
	private String username;		// 사원번호
	private String fullName;		// 사용자 이름
	private String userRank;		// 사용자 직급
	private String gender;			// 남/여 구분
	private String profileImage;	// 프로필 이미지 경로(없으면 기본 아바타 경로)*/
	private String email;			// 이메일
	private int teamId;				// 팀 아이디
	private String teamName;		// 팀 이름
	private int departmentId;		// 부서 아이디
	private String departmentName;	// 부서 이름
}
