package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.dto.ChatbotDto;

@Mapper
public interface ChatbotMapper {
	List<ChatbotDto> find(@Param("q") String q,
					   @Param("userId") int userId,
					   @Param("limit") int limit);
}
