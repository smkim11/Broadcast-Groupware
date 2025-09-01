package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class PasswordDto {
	private int userId;
	private String prevPw;
	private String newPw;
	private String newPw2;
}
