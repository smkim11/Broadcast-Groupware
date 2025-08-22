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
	
	// (옵션) LAST_INSERT_ID() 보정용
    Integer selectLastInsertId();
	
	// 채팅방 생성
	int upsertDmChatroom(Chatroom room);
	
	// 채팅방 - 사용자 추가
	int insertChatroomUserIgnore(@Param("chatroomId") int chatroomId,
						   		 @Param("userId") int userId);
}
