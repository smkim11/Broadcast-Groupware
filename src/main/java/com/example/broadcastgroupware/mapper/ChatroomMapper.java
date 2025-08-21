package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.Chatroom;
import com.example.broadcastgroupware.dto.ChatroomListDto;

@Mapper
public interface ChatroomMapper {
	
	// DM 목록 (1:1대화 용)
	List<ChatroomListDto> selectDmListByUser(@Param("userId") int userId);
	
	// dm_key로 방 존재 여부 확인
	Chatroom selectByDmKey(@Param("dmKey") String dmKey);
	
	// 채팅방 생성
	int insertChatroom(Chatroom room);
	
	// 채팅방 - 사용자 추가
	int insertChatroomUser(@Param("chatroomId") int chatroomId,
						   @Param("userId") int userId);
}
