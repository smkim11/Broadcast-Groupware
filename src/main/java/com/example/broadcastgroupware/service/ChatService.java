package com.example.broadcastgroupware.service;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ChatMessage;
import com.example.broadcastgroupware.domain.ChatroomUser;
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
		
		// 보낸 사람을 최소 Y로 보장 — 떠났던 본인도 바로 재활성화
	    chatroomUserMapper.upsertActive(chatroomId, userId);
	    
	    // 2) 상대 중에 N인 사람은 이번 메시지로 자동 재입장
	    //    (upsertActive가 'N일 때만 create_date=NOW()'로 갱신되도록 되어있어야 함)
	    List<Integer> allIds = chatroomUserMapper.selectAllMemberIds(chatroomId);
	    for (Integer uid : allIds) {
	        if (uid == null || uid.intValue() == userId) continue;
	        chatroomUserMapper.upsertActive(chatroomId, uid); // N이면 Y로 + create_date=NOW(), Y면 그대로 유지
	    }
	    
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
		
		// 3)  내 읽음시간 갱신
		chatMapper.updateLastReadAt(chatroomId, userId, m.getChatMessageId());
		//System.out.println("[saveMessage] insertedId=" + m.getChatMessageId());
		
		// 메시지 INSERT 직후
		chatroomMapper.updateChatroomLastMessage(chatroomId, chatMessageContent);
		
		// 4) 방금 저장한 메시지를 Dto 뷰로 다시 조회해서 반환
		ChatMessageDto dto = chatMapper.selectMessageViewById(m.getChatMessageId());
		  //System.out.println("[saveMessage] dto=" + dto);
		
		// ---- (여기만 변경) 인박스 알림: 중복 제거 + 보낸 사람 제외 ----
		List<Integer> memberIds = chatroomUserMapper.selectMemberIds(chatroomId); // 기존 그대로 사용
		Set<Integer> targets = new LinkedHashSet<>(); // 순서 유지하며 디듀프
		if (memberIds != null) {
			for (Integer uid : memberIds) {
				if (uid == null || uid.intValue() == userId) continue; // null/보낸사람 제외
				targets.add(uid.intValue());
			}
		}
		// 이벤트는 한 번만 생성
		InboxEvent evt = new InboxEvent(
			chatroomId,
			dto.getChatMessageId(),
			dto.getChatMessageContent(),
			dto.getCreateDate()
		);
		for (Integer uid : targets) {
			messagingTemplate.convertAndSend("/topic/user." + uid + "/inbox", evt);
		}
		return dto;
		
	}

	public List<ChatMessageDto> getMessages(int chatroomId, int userId, Integer afterId, int limit) {
		return chatMapper.selectMessages(chatroomId, userId, afterId, limit);
	}

	public void markRead(int chatroomId, int userId, Integer lastMessageId) {
		chatMapper.updateLastReadAt(chatroomId, userId, lastMessageId);
		
	}

	public void leaveRoom(int chatroomId, int userId) {
		// 참여 중인지 체크
		ChatroomUser cu = chatroomUserMapper.findStatus(chatroomId, userId);
		if (cu==null) {
			throw new IllegalStateException("이미 나갔거나 참여중이 아닙니다.");
		}
		chatroomUserMapper.updateStatus(chatroomId, userId, "N");
		
	}
	
	public void publishRoomCreated(int chatroomId, List<Integer> targetUserIds) {
	    InboxEvent evt = new InboxEvent(
	        chatroomId,
	        0,                             // messageId 없음 → 0 또는 null
	        "[새 대화 시작]",               // preview (아무 문자열 OK)
	        java.time.LocalDateTime.now()  // createdAt
	    );
	    for (Integer uid : targetUserIds) {
	        if (uid != null) {
	            messagingTemplate.convertAndSend("/topic/user." + uid + "/inbox", evt);
	        }
	    }
	}
}
