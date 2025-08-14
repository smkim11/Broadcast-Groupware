package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.mapper.ReservationMapper;

@Service
public class ReservationService {
	private final ReservationMapper reservationMapper;

	public ReservationService(ReservationMapper reservationMapper) {
		this.reservationMapper = reservationMapper;
	}

	public int getTotalCount() {
		
		return reservationMapper.getTotalCount();
	}
	
	public List<CarReservationDto> getCarReservationList(PageDto pageDto) {
		
		return reservationMapper.getCarReservationList(pageDto);
	}


}
