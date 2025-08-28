package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class AttendanceListDto {
	private int userId;
	private String role;
	private String userRank;
	private Integer year;
	private Integer month;
}
