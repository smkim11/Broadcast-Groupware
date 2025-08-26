package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;

import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class ReservationController {
	
	@GetMapping("/user/car")
	public String carList(HttpSession session, Model model) {
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		
		if(loginUser == null) {
			return "redirect:/login";
		} 
		
		int userId = loginUser.getUserId();
		String role = loginUser.getRole();
			
		model.addAttribute("userId", userId);
		model.addAttribute("role", role);
		
		return "user/car";
	}
	
	@GetMapping("/user/cuttingroom")
	public String cuttingroom(HttpSession session, Model model) {
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		
		if(loginUser == null) {
			return "redirect:/login";
		} 
		
		int userId = loginUser.getUserId();
		String role = loginUser.getRole();
			
		model.addAttribute("userId", userId);
		model.addAttribute("role", role);
		
		return "user/cuttingroom";
	}
	
	@GetMapping("/user/meetingroom")
	public String meetingroom(HttpSession session, Model model) {
		
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		
		if(loginUser == null) {
			return "redirect:/login";
		} 
		
		int userId = loginUser.getUserId();
		String role = loginUser.getRole();
			
		model.addAttribute("userId", userId);
		model.addAttribute("role", role);
		
		return "user/meetingroom";
		
	}
}
