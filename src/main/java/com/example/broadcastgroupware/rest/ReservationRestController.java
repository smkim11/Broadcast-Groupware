package com.example.broadcastgroupware.rest;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.service.ReservationService;

@RestController
@RequestMapping("/api")
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
	
	// 관리자용 차량리스트
	@GetMapping("/car/adminCarList")
	public List<Vehicle> adminCarList() {
		return reservationService.adminCarList();
	}
}
