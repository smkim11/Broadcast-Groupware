package com.example.broadcastgroupware.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class CarReservationDto {
	private int vehicleId;
	private String vehicleStatus;
	private String vehicleNo;
	private String vehicleType;
	private String vehicleName;
	private String createDate;

	// 예약 구간 리스트
	private List<ReservationPeriod> reservationPeriods = new ArrayList<>();

	// 편의용 필드 (기존 코드 호환)
	private int vehicleReservationId;
	private int userId;
	private String reservationStart; 
	private String reservationEnd;   
	private String updateDate;

	// 첫 예약 시작 시간을 반환 (기존 코드 호환용)
	public String getReservationStart() {
		return reservationStart;
	}

	// 마지막 예약 종료 시간을 반환 (기존 코드 호환용)
	public String getReservationEnd() {
		return reservationEnd;
	}
}

