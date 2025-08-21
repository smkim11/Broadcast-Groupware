package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.dto.ChatUserRowDto;
import com.example.broadcastgroupware.dto.ChatUserTreeDto;
import com.example.broadcastgroupware.mapper.ChatListMapper;

@Service
public class ChatListService {
	private final ChatListMapper chatListMapper;
	
	public ChatListService(ChatListMapper chatListMapper) {
		this.chatListMapper = chatListMapper;
	}

	 /*
     * 초대 모달에 뿌릴 조직도 트리 생성
     * 원리:
     *  1) 부서 Map(부서id→노드)에서 한 번만 생성
     *  2) 팀 Map(부서id:팀id→노드)에서 한 번만 생성
     *  3) 사용자(리프)를 부모(팀/부서)에 추가
     */
	
	public List<ChatUserTreeDto> getUserTreeForInvite() {
		List<ChatUserRowDto> rows = chatListMapper.selectUsersRow();
		
		Map<Integer, ChatUserTreeDto> deptMap = new LinkedHashMap<>();
		Map<String, ChatUserTreeDto> teamMap = new HashMap<>();
		
		for (ChatUserRowDto r : rows) {
			// 1) 부서
			ChatUserTreeDto dept = deptMap.computeIfAbsent(r.getDepartmentId(), id -> {
				ChatUserTreeDto t = new ChatUserTreeDto();
				t.setId(id);
				t.setName(r.getDepartmentName());
				t.setKind("DEPT");
				return t;
			});
			
			// 2) 팀
			String key = r.getDepartmentId() + ":" + r.getTeamId();
			ChatUserTreeDto team = teamMap.computeIfAbsent(key, k -> {
				ChatUserTreeDto t = new ChatUserTreeDto();
				t.setId(r.getTeamId());
				t.setName(r.getTeamName());
				t.setKind("TEAM");
				dept.getUsers().add(t);
				return t;
			});
			
			// 3) 사용자
			ChatUserTreeDto user = new ChatUserTreeDto();
			user.setId(r.getUserId());
			user.setName(r.getFullName());
			user.setKind("USER");
			user.setUserRank(r.getUserRank());
			user.setUsers(new ArrayList<>()); 
			team.getUsers().add(user);
			
			// System.out.println("row fullName = " + r.getFullName());
		}
		return new ArrayList<>(deptMap.values());
	  }
	}