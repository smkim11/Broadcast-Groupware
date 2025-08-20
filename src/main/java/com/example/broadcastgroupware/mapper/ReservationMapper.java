package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleUseReason;
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

	// 이슈차량리스트
	List<Vehicle> issueCarList();
	
	// 이슈차량정보
	List<VehicleUseReason> issueCarData(int vehicleId);


}
