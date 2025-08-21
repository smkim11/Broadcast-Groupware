package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ChatMessage;
import com.example.broadcastgroupware.dto.ChatMessageDto;
import com.example.broadcastgroupware.mapper.ChatMapper;

@Service
public class ChatService {
	private final ChatMapper chatMapper;
	
	public ChatService(ChatMapper chatMapper) {
		this.chatMapper = chatMapper;
	}
	
	@Transactional
	public ChatMessageDto saveMessage(int chatroomId, int userId, String chatMessageContent) {
		System.out.println("[saveMessage] room=" + chatroomId + ", user=" + userId + ", content=" + chatMessageContent);
		// 1) roomId + userId로 chatroom_user_id 찾기
		Integer chatroomUserId = chatMapper.selectChatroomUserId(chatroomId, userId);
		if(chatroomUserId == null) throw new IllegalStateException("방 멤버가 아닙니다.");
		
		// 2) 도메인으로 INSERT
		ChatMessage m = new ChatMessage();
		m.setChatroomUserId(chatroomUserId);
		m.setChatroomId(chatroomId);
		m.setChatMessageContent(chatMessageContent);
		m.setChatMessageStatus("Y");
		chatMapper.insertChatMessage(m);	// chatMessageId 세팅
		
		// 3) (옵션) 내 읽음시간 갱신
		chatMapper.updateLastReadAt(chatroomId, userId);
		System.out.println("[saveMessage] insertedId=" + m.getChatMessageId());
		// 4) 방금 저장한 메시지를 Dto 뷰로 다시 조회해서 반환
		ChatMessageDto dto = chatMapper.selectMessageViewById(m.getChatMessageId());
		  System.out.println("[saveMessage] dto=" + dto);
		return dto;
		
	}

	public List<ChatMessageDto> getMessages(int chatroomId, Integer afterId, int limit) {
		return chatMapper.selectMessages(chatroomId, afterId, limit);
	}
}
