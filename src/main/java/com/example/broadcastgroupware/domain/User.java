package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class User {
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
}
