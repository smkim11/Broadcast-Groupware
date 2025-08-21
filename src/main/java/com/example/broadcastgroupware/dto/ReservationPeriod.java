package com.example.broadcastgroupware.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class ReservationPeriod {
	private String reservationStart;
	private String reservationEnd;
	
	public ReservationPeriod(String start, String end){
		this.reservationStart = start;
		this.reservationEnd = end;
	}
}
