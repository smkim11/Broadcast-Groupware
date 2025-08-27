package com.example.broadcastgroupware.rest;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ChatbotService;

@RestController
@RequestMapping("/api/search")
public class ChatbotRestController {
	private final ChatbotService chatbotService;
	
	public ChatbotRestController(ChatbotService chatbotService) {
		this.chatbotService = chatbotService;
	}
	
	@PostMapping("/attendance")
	public ResponseEntity<Map<String,Object>> attendance(
			@RequestBody Map<String,String> body,
			@SessionAttribute("loginUser") UserSessionDto loginUser) {
		
		String q = String.valueOf(body.getOrDefault("q","")).trim();
		return ResponseEntity.ok(chatbotService.searchItem(q, loginUser));
	}
}
