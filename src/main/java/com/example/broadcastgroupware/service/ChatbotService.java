package com.example.broadcastgroupware.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.dto.ChatbotDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.ChatbotMapper;

@Service
public class ChatbotService {
	private final ChatbotMapper chatbotMapper;
	
	public ChatbotService(ChatbotMapper chatbotMapper) {
		this.chatbotMapper = chatbotMapper;
	}
	
	public Map<String,Object> searchItem(String q, UserSessionDto user) {
		//limit는 ui에 맞게 적당히(50)
		List<ChatbotDto> list = chatbotMapper.find(q, user.getUserId(), 50);
		
		Map<String,Object> res = new HashMap<>();
		res.put("items", list);
		res.put("count", list.size());
		res.put("message", list.isEmpty() ? "결과 없음" : "최근순으로 정렬되었습니다.");
		return res;
	}
}
