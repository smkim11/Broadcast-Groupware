package com.example.broadcastgroupware.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.service.ReservationService;

@Controller
public class ReservationController {
	
	private final ReservationService reservationService;
	public ReservationController(ReservationService reservationService) {
		this.reservationService = reservationService;
	}

	@GetMapping("/user/car")
	public String carList(Model model, 
						@RequestParam(value = "page", defaultValue = "1") int page,
				        @RequestParam(value = "size", defaultValue = "10") int size) {
		
		// 전체 차량 조회
		int totalCount = reservationService.getTotalCount();
		
		PageDto pageDto = new PageDto(page, size, totalCount);
		
		List<CarReservationDto> carReservationList = reservationService.getCarReservationList(pageDto);
		
		model.addAttribute("carReservationList", carReservationList);
		model.addAttribute("pageDto", pageDto);
		return "user/car";
	}
	
	@GetMapping("/user/cuttingroom")
	public String cuttingroom() {
		
		return "user/cuttingroom";
	}
	
	@GetMapping("/user/meetingroom")
	public String meetingroom() {
		
		return "user/meetingroom";
	}
}
