package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ChatMessage;
import com.example.broadcastgroupware.dto.ChatMessageDto;
import com.example.broadcastgroupware.dto.InboxEvent;
import com.example.broadcastgroupware.mapper.ChatMapper;
import com.example.broadcastgroupware.mapper.ChatroomMapper;
import com.example.broadcastgroupware.mapper.ChatroomUserMapper;

@Service
public class ChatService {
	private final ChatMapper chatMapper;
	private final ChatroomMapper chatroomMapper;
	private final ChatroomUserMapper chatroomUserMapper;
	private final SimpMessagingTemplate messagingTemplate;
	
	
	public ChatService(ChatMapper chatMapper,
					   ChatroomMapper chatroomMapper,
					   ChatroomUserMapper chatroomUserMapper,
					   SimpMessagingTemplate messagingTemplate) {
		this.chatMapper = chatMapper;
		this.chatroomMapper = chatroomMapper;
		this.chatroomUserMapper = chatroomUserMapper;
		 this.messagingTemplate = messagingTemplate;
	}
	
	@Transactional
	public ChatMessageDto saveMessage(int chatroomId, int userId, String chatMessageContent) {
		//System.out.println("[saveMessage] room=" + chatroomId + ", user=" + userId + ", content=" + chatMessageContent);
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
		//System.out.println("[saveMessage] insertedId=" + m.getChatMessageId());
		
		// 방의 최근 활동 시간 캐시 갱신(정렬/ 표시 안정화)
		chatroomMapper.updateChatroomLastActivity(chatroomId);
		
		// 4) 방금 저장한 메시지를 Dto 뷰로 다시 조회해서 반환
		ChatMessageDto dto = chatMapper.selectMessageViewById(m.getChatMessageId());
		  //System.out.println("[saveMessage] dto=" + dto);
		
		 //  기존 방 브로드캐스트
	   // messagingTemplate.convertAndSend("/topic/rooms/" + chatroomId, dto);

	    // 유저 인박스 이벤트 (보낸 사람 제외)
	    List<Integer> memberIds = chatroomUserMapper.selectMemberIds(chatroomId);
	    for (Integer uid : memberIds) {
	      if (uid == null || uid == userId) continue;
	      InboxEvent evt = new InboxEvent(chatroomId, dto.getChatMessageContent(), dto.getCreateDate());
	      // Principal.getName() == String.valueOf(uid) 여야 수신됨
	      messagingTemplate.convertAndSendToUser(String.valueOf(uid), "/queue/inbox", evt);
	    }
		return dto;
		
	}

	public List<ChatMessageDto> getMessages(int chatroomId, Integer afterId, int limit) {
		return chatMapper.selectMessages(chatroomId, afterId, limit);
	}
}
