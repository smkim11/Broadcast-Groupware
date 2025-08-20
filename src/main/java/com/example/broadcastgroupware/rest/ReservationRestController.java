package com.example.broadcastgroupware.rest;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleUseReason;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.service.ReservationService;

import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api")
@Slf4j
public class ReservationRestController {
	
	private final ReservationService reservationService;
	
	public ReservationRestController(ReservationService reservationService) {
		this.reservationService = reservationService;
	}

	// 차량 등록
	@PostMapping("/car/addCar")
	public String car(Vehicle vehicle) {
		
		reservationService.addCar(vehicle);
		
		return "success";
	}
	
	// 차량 수정
	@PostMapping("/car/modifyCar")
	public String modifyCar(Vehicle vehicle) {
		
		/*
		log.info("=== Ajax로 전달된 차량 정보 ===", "");
		log.info("vehicleId: {}", vehicle.getVehicleId());
		log.info("vehicleNo: {}", vehicle.getVehicleNo());
		log.info("vehicleName: {}", vehicle.getVehicleName());
		log.info("vehicleType: {}", vehicle.getVehicleType());
		*/
		
		reservationService.modifyCar(vehicle);
		
		return "success";
	}
	
	// 차량 비활성 <-> 활성화
	@PostMapping("/car/carToggle")
	public String carToggle(CarToggle carToggle) {
		
		/*
		log.info("=== Ajax로 전달된 차량 정보 ===", "");
		log.info("vehicleId: {}", carToggle.getVehicleId());
		log.info("reasonContent: {}", carToggle.getVehicleUseReasonContent());
		log.info("reasonStartDate: {}", carToggle.getVehicleUseReasonStartDate());
		log.info("reasonEndDate: {}", carToggle.getVehicleUseReasonEndDate());
		log.info("vehicleStatus: {}", carToggle.getVehicleStatus());
		*/
		
		reservationService.carToggle(carToggle);
		
		return "success";
	}
	
	// 관리자용 차량리스트
	@GetMapping("/car/adminCarList")
	public List<Vehicle> adminCarList() {
		return reservationService.adminCarList();
	}
	
}
