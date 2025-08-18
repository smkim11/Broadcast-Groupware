package com.example.broadcastgroupware.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import com.example.broadcastgroupware.dto.ChatmessageDto;



@Controller
public class ChatController {
	
	@GetMapping("/user/chat")
	public String chat() {
		return "user/chat";
	}
	
    // 클라이언트에서 "/app/chat" 으로 메시지를 보내면
    @MessageMapping("/chat.send")
    @SendTo("/topic/public") // 구독자들에게 브로드캐스트됨
    public ChatmessageDto sendMessage(ChatmessageDto message) {
        return message; // 그대로 반환 → 구독자에게 전달
    }
}
