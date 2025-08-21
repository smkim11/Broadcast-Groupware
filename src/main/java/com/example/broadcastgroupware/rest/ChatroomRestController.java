package com.example.broadcastgroupware.rest;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

import com.example.broadcastgroupware.dto.ChatroomDmDto;
import com.example.broadcastgroupware.dto.ChatroomDto;
import com.example.broadcastgroupware.dto.ChatroomListDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ChatroomService;

@RestController
@RequestMapping("/api/rooms")
public class ChatroomRestController {
	
	private final ChatroomService chatroomService;
	
	public ChatroomRestController(ChatroomService chatroomService) {
		this.chatroomService = chatroomService;
	}
	
	// DM 목록(1:1대화)
	@GetMapping("/dm")
    public ResponseEntity<List<ChatroomListDto>> listDm(
            @SessionAttribute("loginUser") UserSessionDto loginUser) {
		
		 System.out.println(">>> DM API 호출됨");
        int userId = loginUser.getUserId();
        return ResponseEntity.ok(chatroomService.getDmList(userId));
    }

    // DM 생성 (조직도에서 초대 → 1:1 시작)
    @PostMapping("/dm")
    public ResponseEntity<ChatroomDto> createDm(@RequestBody ChatroomDmDto req,
                                                @SessionAttribute("loginUser") UserSessionDto loginUser) {
        int meUserId = loginUser.getUserId();
        ChatroomDto dto = chatroomService.createDm(meUserId, req.getTargetUserId());
        return ResponseEntity.ok(dto);
    }
}
	
	



















