package com.example.broadcastgroupware.rest;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.ChatMessageDto;
import com.example.broadcastgroupware.service.ChatService;

@RestController
@RequestMapping("/api/rooms")
public class ChatRestController {
	private final ChatService chatService;
	
	public ChatRestController(ChatService chatService) {
		this.chatService = chatService;
	}
	
	// 메시지 히스토리 조회
	@GetMapping("/{chatroomId}/messages")
	public List<ChatMessageDto> getMessages(
			@PathVariable int chatroomId,
			@RequestParam(required = false) Integer afterId,
			@RequestParam(defaultValue = "50") int limit) {
		return chatService.getMessages(chatroomId, afterId, limit);
	}
}
