package com.example.broadcastgroupware.controller;

import java.time.LocalDateTime;
import java.util.Map;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.dto.ChatMessageDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ChatService;

import jakarta.servlet.http.HttpSession;



@Controller
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;		
    // Spring에서 WebSocket + STOMP를 쓸 때, 서버에서 특정 유저나 특정 topic으로 메시지를 푸시(push) 전송할 수 있게 해주는 객체
    // 특정 대상 유저에게만 보내거나, 조건에 따라 다른 경로로 메시지를 전송하려면 필요
    private final ChatService chatService;	

    public ChatController(SimpMessagingTemplate messagingTemplate,
    					  ChatService chatService) {
        this.messagingTemplate = messagingTemplate;
        this.chatService = chatService;
    }

    @GetMapping("/user/chat")
    public String chat(@RequestParam(defaultValue = "1") int chatroomId,
    				   HttpSession session,
    				   Model model) {
    	UserSessionDto login = (UserSessionDto) session.getAttribute("loginUser");
    	
    	model.addAttribute("chatroomId", chatroomId);
    	model.addAttribute("loginUserId", login != null ? login.getUserId() : 0);
    	model.addAttribute("loginUserName", login != null ? login.getFullName() : "");
    	
        return "user/chat";
    }
    
    // 메시지 보내기
    // 클라: stompClient.send(`/app/rooms/${chatroomId}/send`, {}, JSON.stringify({ chatMessageContent: '...' }))
    @MessageMapping("/rooms/{chatroomId}/send")
    public void send(@DestinationVariable int chatroomId,
    				 @Payload ChatMessageDto message,
    				 SimpMessageHeaderAccessor accessor) {
    	// 세션에서 로그인 정보 꺼내기 (로그인 성공 시 세션에 loginUser 저장해둔 객체)
    	UserSessionDto login = (UserSessionDto) accessor.getSessionAttributes().get("loginUser");
    	// int userId = (login != null ? login.getUserId() : 0); 로 해도 되지만 아직 익숙치 않아서 if문으로
    	
    	// System.out.println("[WS] session loginUser = " + login);
    	if (login == null)  {
    		//  System.out.println("[WS] loginUser null, skip");
    		return;  // 세션 만료 등
    	}
    
    	
    		 //  System.out.println("[WS] send room=" + chatroomId + " user=" + login.getUserId()
             //  + " content=" + message.getChatMessageContent());
        // DB 저장(도메인으로 insert -> Dto로 다시 조회
    	ChatMessageDto saved = chatService.saveMessage(
    			chatroomId, 
    			login.getUserId(), 
    			message.getChatMessageContent()
    			);
    	
    	
        // 구독 채널로 전송 (프런트는 /topic/rooms/{roomId} 구독)
        messagingTemplate.convertAndSend("/topic/rooms/" + chatroomId, saved);
    }

    // 읽음 처리 (같은 Dto 재사용: chatroomId + chatMessageId만 필요)
    // 클라이언트: stompClient.send('/app/rooms/{chatroomId}/read', {lastMessageId: ...})
    @MessageMapping("/rooms/{chatroomId}/read")
    public void read(@DestinationVariable int chatroomId,
    				 @Payload ChatMessageDto read,
    				 SimpMessageHeaderAccessor accessor) {
    	
        UserSessionDto login = (UserSessionDto) accessor.getSessionAttributes().get("loginUser");
        if (login == null) return;	// 세션 만료 등
        
        // 옵션
        // chatService.updateLastRead(chatroomId, logingetUserId(), read.getChatMessageId());

        // 아주 가볍게 브로드캐스트(프런트에서 '읽음' UI에만 사용)
        Map<String, Object> out = Map.of(
            "roomId",        chatroomId,
            "userId",        login.getUserId(),
            "lastMessageId", read.getChatMessageId()
        );
        messagingTemplate.convertAndSend("/topic/rooms/" + chatroomId + "/read", out);
    }
}
