package com.example.broadcastgroupware.rest;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class ReservationRestController {
	@GetMapping("/user/car")
	public String car() {
		
		return "user/car";
	}
}
