package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Chatroom;
import com.example.broadcastgroupware.dto.ChatroomDto;
import com.example.broadcastgroupware.dto.ChatroomListDto;
import com.example.broadcastgroupware.mapper.ChatroomMapper;
import com.example.broadcastgroupware.mapper.ChatroomUserMapper;

@Service
public class ChatroomService {
	private final ChatroomMapper chatroomMapper;
	private final ChatroomUserMapper chatroomUserMapper;
	private final ChatService chatService;
	
	public ChatroomService(ChatroomMapper chatroomMapper,
						   ChatroomUserMapper chatroomUserMapper,
						   ChatService chatService) {
		this.chatroomMapper = chatroomMapper;
		this.chatroomUserMapper = chatroomUserMapper;
		this.chatService = chatService;
	}
	
	// DM 목록
	public List<ChatroomListDto> getDmList(int userId) {
		List<ChatroomListDto> list = chatroomMapper.selectDmListByUser(userId);
		return list;
	}
	
	// DM 생성
	@Transactional(isolation = Isolation.READ_COMMITTED)
	public ChatroomDto createDm(int meUserId, int targetUserId) {
		int a = Math.min(meUserId, targetUserId);
		int b = Math.max(meUserId, targetUserId);
		String dmKey = a + ":" + b;
		
		Chatroom room = new Chatroom();
	    room.setRoomType("DM");
	    room.setDmKey(dmKey);
	    room.setChatroomName("DM-" + meUserId + "-" + targetUserId);
	    room.setChatroomStatus("Y");
	    room.setLastMessageAt(null);

	    // UPSERT 실행 (중복이어도 예외 안 남)
	    int affected = chatroomMapper.upsertDmChatroom(room);

	    // PK 보정 (환경에 따라 getGeneratedKeys가 0일 수 있음)
	    if (room.getChatroomId() == null || room.getChatroomId() == 0) {
	        Integer id = chatroomMapper.selectLastInsertId();
	        room.setChatroomId(id);
	    }

	    // 조인 테이블은 중복 무시로 안전하게
	    chatroomMapper.insertChatroomUserIgnore(room.getChatroomId(), meUserId);
	    chatroomMapper.insertChatroomUserIgnore(room.getChatroomId(), targetUserId);
	    
	    // ★ 추가: 두 유저를 활성화(나갔던 사람도 Y로)
	    chatroomUserMapper.upsertActive(room.getChatroomId(), meUserId);
	    chatroomUserMapper.upsertActive(room.getChatroomId(), targetUserId);

	    // ★ 추가: 새 방 생성 인박스 이벤트 (좌측 목록 즉시 갱신 트리거)
	    chatService.publishRoomCreated(
	        room.getChatroomId(),
	        java.util.Arrays.asList(meUserId, targetUserId)
	    );

	    // 이미 있었는지 플래그 (INSERT=1, 나머지(UPDATE/변경없음)=true)
	    ChatroomDto dto = toDto(room);
	    dto.setAlreadyExists(affected != 1);
	    return dto;
	}

	private ChatroomDto toDto(Chatroom chatroom) {
		ChatroomDto dto	= new ChatroomDto();
		dto.setChatroomId(chatroom.getChatroomId());
		dto.setDmKey(chatroom.getDmKey());
		dto.setRoomType(chatroom.getRoomType());
		dto.setChatroomName(chatroom.getChatroomName());
		dto.setChatroomStatus(chatroom.getChatroomStatus());
		dto.setLastMessageAt(chatroom.getLastMessageAt());
		dto.setCreateDate(chatroom.getCreateDate());
		return dto;
	}
}






















