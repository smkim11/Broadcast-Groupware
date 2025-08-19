package com.example.broadcastgroupware.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.dto.ChatmessageDto;
import com.example.broadcastgroupware.dto.UserSessionDto;

import jakarta.servlet.http.HttpSession;



@Controller
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;		
    // Spring에서 WebSocket + STOMP를 쓸 때, 서버에서 특정 유저나 특정 topic으로 메시지를 푸시(push) 전송할 수 있게 해주는 객체
    // 특정 대상 유저에게만 보내거나, 조건에 따라 다른 경로로 메시지를 전송하려면 필요
    private final DateTimeFormatter TS = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    public ChatController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @GetMapping("/user/chat")
    public String chat(@RequestParam(defaultValue = "1") Integer roomId
    					,HttpSession session
    					,Model model) {
    	UserSessionDto login = (UserSessionDto) session.getAttribute("loginUser");
    	
    	model.addAttribute("roomId", roomId);
    	model.addAttribute("loginUserId", login != null ? login.getUserId() : 0);
    	model.addAttribute("loginUserName", login != null ? login.getUsername() : 0);
    	
        return "user/chat";
    }
    
    // 메시지 보내기
    // 클라이언트: stompClient.send('/app/rooms/{roomId}/send', {}, JSON.stringify({roomId, content}))
    @MessageMapping("/chat/send")
    public void send(ChatmessageDto message
    				 ,SimpMessageHeaderAccessor accessor) {
    	// 세션에서 로그인 정보 꺼내기 (로그인 성공 시 세션에 loginUser 저장해둔 객체)
    	UserSessionDto login = (UserSessionDto) accessor.getSessionAttributes().get("loginUser");
    	// int userId = (login != null ? login.getUserId() : 0); 로 해도 되지만 아직 익숙치 않아서 if문으로
    	int userId = 0;
    	if (login != null) {
    		userId = login.getUserId();
    	} else {
    		userId = 0;
    	}
    
        // 서버가 생성할 값들 채워서 dto 생성
        ChatmessageDto chatmessage = new ChatmessageDto();
        chatmessage.setChatroomId(message.getChatroomId());
        chatmessage.setUserId(login.getUserId());
        chatmessage.setFullName(login.getFullName()); 
        chatmessage.setUserRank(login.getUserRank());  
        chatmessage.setChatMessageContent(message.getChatMessageContent());
        chatmessage.setChatMessageStatus("SENT");
        chatmessage.setCreateDate(LocalDateTime.now().format(TS));			// 시간 관련

        // 구독 채널로 전송 (프런트는 /topic/rooms/{roomId} 구독)
        messagingTemplate.convertAndSend("/topic/rooms/" + message.getChatroomId(), chatmessage);
    }

    // 읽음 처리 (같은 Dto 재사용: chatroomId + chatMessageId만 필요)
    // 클라이언트: stompClient.send('/app/rooms/{roomId}/read', {lastMessageId: ...})
    @MessageMapping("/chat/read")
    public void read(ChatmessageDto read
    				,SimpMessageHeaderAccessor accessor) {
    	
        UserSessionDto login = (UserSessionDto) accessor.getSessionAttributes().get("loginUser");
        int userId = 0;
    	if (login != null) {
    		userId = login.getUserId();
    	} else {
    		userId = 0;
    	}

        // 아주 가볍게 브로드캐스트(프런트에서 '읽음' UI에만 사용)
        Map<String, Object> out = Map.of(
            "roomId",        read.getChatroomId(),
            "userId",        userId,
            "lastMessageId", read.getChatMessageId()
        );
        messagingTemplate.convertAndSend("/topic/rooms/" + read.getChatroomId() + "/read", out);
    }
}
