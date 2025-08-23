package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class UserRowDto {
	private int departmentId;		// 부서 Id
	private String departmentName;	// 부서 이름
	private int teamId;				// 팀 id
	private String teamName;		// 팀 이름
	
	private int userId;				// 사용자 pk
	private String fullName;		// 이름
	private String userRank;		// 유저 직급
}
