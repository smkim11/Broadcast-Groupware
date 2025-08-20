package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.domain.VehicleUseReason;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
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

	// 차량 수정
	public void modifyCar(Vehicle vehicle) {
		reservationMapper.modifyCar(vehicle);	
	}

	// 차량 비활성 <-> 활성화
	@Transactional
	public void carToggle(CarToggle carToggle) {
		reservationMapper.modifyVehicleStatus(carToggle); // 스테이터스 'Y' -> 'N'으로 변경
		reservationMapper.insertVehicleReason(carToggle); // reason테이블에 추가
	}

	// 차량예약
	public boolean carReservation(VehicleReservation vehicleReservation) {
		
		return reservationMapper.carReservation(vehicleReservation);
	}


}
