package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class UserCreateDto {
	private int userId;
	private String username;
	private String role;
	private String fullName;
	private String userSn1;
	private String userSn2;
	private String userPhone;
	private String userEmail;
	private String userRank;
	private String userJoinDate;
	private String userResignDate;
	private String password;
	
	private int teamId;		// 화면요청
	private int deptId;
}
