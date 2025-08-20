package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.PageDto;

@Mapper
public interface ReservationMapper {

	List<CarReservationDto> getCarReservationList(PageDto pageDto);

	int getTotalCount();

	// 차량등록
	void addCar(Vehicle vehicle);

	// 관리자용 차량 리스트
	List<Vehicle> adminCarList();

	// 차량 수정
	void modifyCar(Vehicle vehicle);

	// 차량 비활성 <-> 활성화
	void modifyVehicleStatus(CarToggle carToggle);
	void insertVehicleReason(CarToggle carToggle);

	// 기존 예약이랑 겹치는지 확인
	int checkReservations(VehicleReservation vehicleReservation);
	
	// 차량 예약
	boolean carReservation(VehicleReservation vehicleReservation);

}
