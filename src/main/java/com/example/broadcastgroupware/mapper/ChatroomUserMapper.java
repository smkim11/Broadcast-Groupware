package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatroomUserMapper {
	 List<Integer> selectMemberIds(@Param("chatroomId") int chatroomId);
}
