package com.example.broadcastgroupware.rest;

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
}
