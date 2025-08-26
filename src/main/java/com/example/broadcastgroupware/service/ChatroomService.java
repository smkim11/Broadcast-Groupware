package com.example.broadcastgroupware.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

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
		List<ChatroomListDto> list = chatroomMapper.selectRoomListByUser(userId, "DM");
		return list;
	}
	
	// GROUP 목록
		public List<ChatroomListDto> getGroupList(int userId) {
			List<ChatroomListDto> list = chatroomMapper.selectRoomListByUser(userId, "GROUP");
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
	    
	    // 두 유저를 활성화(나갔던 사람도 Y로)
	    chatroomUserMapper.upsertActive(room.getChatroomId(), meUserId);
	    chatroomUserMapper.upsertActive(room.getChatroomId(), targetUserId);

	    // 새 방 생성 인박스 이벤트 (좌측 목록 즉시 갱신 트리거)
	    if (affected == 1) {
	        chatService.publishRoomCreated(
	            room.getChatroomId(),
	            java.util.Arrays.asList(meUserId, targetUserId)
	        );
	    }

	    // 이미 있었는지 플래그 (INSERT=1, 나머지(UPDATE/변경없음)=true)
	    ChatroomDto dto = toDto(room);
	    dto.setAlreadyExists(affected != 1);
	    return dto;
	}
	
	// GROUP채팅방 생성
	@Transactional
	public int createGroupRoom(String roomName, int ownerId, List<Integer> memberIds) {
		// 방 이름 보정( null/공백 처리)
		final String safeName = (roomName == null || roomName.isBlank()) ? "그룹채팅" : roomName.trim();
		
		Chatroom groupRoom = new Chatroom();
		groupRoom.setRoomType("GROUP");						// DM과 구분
		groupRoom.setChatroomName(safeName);				// 좌측 리스트/헤더에서 보일 이름
		groupRoom.setChatroomStatus("Y");					// 활성 상태
		groupRoom.setLastMessageAt(LocalDateTime.now());	// 생성 시각을 최근활동으로
		
		// Mapper 메서드 사용
		chatroomMapper.insertGroupChatroom(groupRoom);
		final int chatroomId = groupRoom.getChatroomId();
		
		// 멤버 등록 (소유자 + 초대 멤버) - 중복/null 제거 후 insert ignore
		// insert ignore : 이미 있는 (chatroom_id, user_id) 조합이면 조용히 무시
		Set<Integer> dedup = new LinkedHashSet<>();
		dedup.add(ownerId);
		if (memberIds != null) {
			for (Integer uid : memberIds) {
				 if(uid != null) dedup.add(uid);
			}
		}
		for (Integer uid : dedup) {
			// 주의 - ChatroomMapper의 인터페이스가 @Param("chatroomId"), @Param("userId)로 선언 돼 있고,
			// xml의 #{chatroomId}, #{userId}와 바인딩이 맞음
			chatroomMapper.insertChatroomUserIgnore(chatroomId, uid);
		}
		
		// 인박스 알림 (새 방 생성 알림) - 기존 메서드 사용
		// - 프런트에서 이 이벤트를 받아 좌측 리스트에 새 방을 끼워넣으면 "바로 보임"
		chatService.publishRoomCreated(chatroomId, new ArrayList<>(dedup));
		
		// 반환 : 컨트롤러/프런트에서 즉시 이 roomId로 전환 + 구독 + 첫 메시지 전송 가능
		return chatroomId;
		
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

	public List<ChatroomListDto> getGroupList(int userId, String roomType) {
		return chatroomMapper.selectRoomListByUser(userId, roomType);
}
}






















