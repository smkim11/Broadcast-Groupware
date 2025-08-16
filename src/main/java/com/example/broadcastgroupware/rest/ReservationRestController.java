package com.example.broadcastgroupware.rest;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class ReservationRestController {
	@PostMapping("/user/car")
	public String car() {
		
		return "redirect:/user/car";
	}
}
