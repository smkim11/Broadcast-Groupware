package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.ChatMessage;
import com.example.broadcastgroupware.dto.ChatMessageDto;

@Mapper
public interface ChatMapper {
	//roomId + userId -> chatroom_userId 찾기
	Integer selectChatroomUserId(@Param("chatroomId") int chatroomId, @Param("userId") int userId);
	
	// 도메인으로 저장 (pk채워짐)
	int insertChatMessage(ChatMessage chatMessage);
	
	// 단건 뷰(방금 저장한 메시지) 조회 -> Dto로 (이름/직급/방ID 포함)
	ChatMessageDto selectMessageViewById(@Param("messageId") int messageId);
	
	// 히스토리 조회 (초기 로드용)
	List<ChatMessageDto> selectMessages(@Param("chatroomId") int chatroomId,
										@Param("afterId") Integer afterId,
										@Param("limit") int limit);
	
	//(옵션) 내 읽음 시간 갱신
	int updateLastReadAt(@Param("chatroomId") int chatroomId,
						 @Param("userId") int userId,
						 @Param("lastMessageId") int lastMessageId);
	
}
