package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ReservationController {
	@GetMapping("/user/car")
	public String carList() {
		
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
