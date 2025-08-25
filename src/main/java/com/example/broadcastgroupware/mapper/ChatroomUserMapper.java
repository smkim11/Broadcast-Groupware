package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.ChatroomUser;
import com.example.broadcastgroupware.dto.ChatroomUserDto;

@Mapper
public interface ChatroomUserMapper {
	
	 List<Integer> selectMemberIds(@Param("chatroomId") int chatroomId);
	 
	 List<Integer> selectAllMemberIds(@Param("chatroomId") int chatroomId);   // 전원
	 
	 List<ChatroomUserDto> selectCurrentMembers(@Param("chatroomId") int chatoomId);	// 현재 참여자 목록리스트

	 ChatroomUser findStatus(@Param("chatroomId") int chatroomId, 
			 				 @Param("userId") int userId);
	 
	 int updateStatus(@Param("chatroomId") int chatroomId, 
					  @Param("userId") int userId, 
					  @Param("status") String string);
	 
	 // 떠났던 사용자를 다시 활성화(Y)
	 int upsertActive(@Param("chatroomId") int chatroomId,
	                  @Param("userId") int userId);
	 
	 

}
