package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.domain.Vehicle;
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
	
	// 예약 리스트 조회
	public List<CarReservationDto> getCarReservationList(PageDto pageDto) {
		
		return reservationMapper.getCarReservationList(pageDto);
	}

	// 차량등록
	public void addCar(Vehicle vehicle) {
		reservationMapper.addCar(vehicle);	
	}

	// 관리자용 차량 리스트
	public List<Vehicle> adminCarList() {

		return reservationMapper.adminCarList();
	}


}
