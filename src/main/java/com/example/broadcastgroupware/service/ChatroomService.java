package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Chatroom;
import com.example.broadcastgroupware.dto.ChatroomDto;
import com.example.broadcastgroupware.dto.ChatroomListDto;
import com.example.broadcastgroupware.mapper.ChatroomMapper;

@Service
public class ChatroomService {
	private final ChatroomMapper chatroomMapper;
	
	public ChatroomService(ChatroomMapper chatroomMapper) {
		this.chatroomMapper = chatroomMapper;
	}
	
	// DM 목록
	public List<ChatroomListDto> getDmList(int userId) {
		List<ChatroomListDto> list = chatroomMapper.selectDmListByUser(userId);
		return list;
	}
	
	// DM 생성
	@Transactional
	public ChatroomDto createDm(int meUserId, int targetUserId) {
		int a = Math.min(meUserId, targetUserId);
		int b = Math.max(meUserId, targetUserId);
		String dmKey = a + ":" + b;
		
		Chatroom exist = chatroomMapper.selectByDmKey(dmKey);
		if (exist != null) {
			return toDto(exist);	// toDto : 변환한 결과를 잠시 담아두는 용도라서 “변환된 것”이라는 의미
		}
		
		Chatroom room = new Chatroom();
		room.setRoomType("DM");
		room.setDmKey(dmKey);
		room.setChatroomName("DM-" + meUserId + "-" + targetUserId); 	//DM은 이름을 굳이 저장하지 않아도 (표시명은 조회시 상대방 이름 직급으로)
		room.setChatroomStatus("Y");
		room.setLastMessageAt(null);	// 최초엔 null (메시지 도착 시 갱신)
		System.out.println(">>> ChatroomName = " + room.getChatroomName());
		chatroomMapper.insertChatroom(room);	// pk 채변됨
		
		chatroomMapper.insertChatroomUser(room.getChatroomId(), meUserId);
		chatroomMapper.insertChatroomUser(room.getChatroomId(), targetUserId);
		
		return toDto(room);
	}

	private ChatroomDto toDto(Chatroom chatroom) {
		ChatroomDto dto	= new ChatroomDto();
		dto.setChatroomId(chatroom.getChatroomId());
		//dto.setUserId(chatroom.getUserId());
		dto.setDmKey(chatroom.getDmKey());
		dto.setRoomType(chatroom.getRoomType());
		dto.setChatroomName(chatroom.getChatroomName());
		dto.setChatroomStatus(chatroom.getChatroomStatus());
		dto.setLastMessageAt(chatroom.getLastMessageAt());
		dto.setCreateDate(chatroom.getCreateDate());
		return dto;
	}
}






















