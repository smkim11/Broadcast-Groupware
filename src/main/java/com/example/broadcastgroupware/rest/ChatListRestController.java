package com.example.broadcastgroupware.rest;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.UserTreeDto;
import com.example.broadcastgroupware.service.UserListService;


@RestController
@RequestMapping("/api/chat")
public class ChatListRestController {
	
	private final UserListService chatListService;
	
	public ChatListRestController (UserListService chatListService) {
		this.chatListService = chatListService;
	}
	
	// 조직도 트리 조회
	@GetMapping("/org-tree")
	public List<UserTreeDto> getOrgTree() {
		return chatListService.getUserTreeForInvite();
	}

}
