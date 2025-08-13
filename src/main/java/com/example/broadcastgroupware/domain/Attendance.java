package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Attendance {
	private int attendanceId;
	private int userId;
	private String attendanceDate;
	private String attendanceIn;
	private String attendanceOut;
	private String attendanceOutside;
	private String attendanceInside;
	private String updateDate;
}
