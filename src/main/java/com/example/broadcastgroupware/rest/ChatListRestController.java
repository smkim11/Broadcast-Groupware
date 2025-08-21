package com.example.broadcastgroupware.rest;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.ChatUserTreeDto;
import com.example.broadcastgroupware.service.ChatListService;


@RestController
@RequestMapping("/api/chat")
public class ChatListRestController {
	
	private final ChatListService chatListService;
	
	public ChatListRestController (ChatListService chatListService) {
		this.chatListService = chatListService;
	}
	
	// 조직도 트리 조회
	@GetMapping("/org-tree")
	public List<ChatUserTreeDto> getOrgTree() {
		return chatListService.getUserTreeForInvite();
	}

}
