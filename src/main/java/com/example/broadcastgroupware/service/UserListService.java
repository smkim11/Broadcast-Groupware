package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.dto.UserRowDto;
import com.example.broadcastgroupware.dto.UserTreeDto;
import com.example.broadcastgroupware.mapper.UserListMapper;

@Service
public class UserListService {
	private final UserListMapper userListMapper;
	
	public UserListService(UserListMapper userListMapper) {
		this.userListMapper = userListMapper;
	}

	 /*
     * 초대 모달에 뿌릴 조직도 트리 생성
     * 원리:
     *  1) 부서 Map(부서id→노드)에서 한 번만 생성
     *  2) 팀 Map(부서id:팀id→노드)에서 한 번만 생성
     *  3) 사용자(리프)를 부모(팀/부서)에 추가
     */
	
	public List<UserTreeDto> getUserTreeForInvite() {
		List<UserRowDto> rows = userListMapper.selectUsersRow();
		
		Map<Integer, UserTreeDto> deptMap = new LinkedHashMap<>();
		Map<String, UserTreeDto> teamMap = new HashMap<>();
		
		for (UserRowDto r : rows) {
			// 1) 부서
			UserTreeDto dept = deptMap.computeIfAbsent(r.getDepartmentId(), id -> {
				UserTreeDto t = new UserTreeDto();
				t.setId(id);
				t.setName(r.getDepartmentName());
				t.setKind("DEPT");
				return t;
			});
			
			// 2) 팀
			String key = r.getDepartmentId() + ":" + r.getTeamId();
			UserTreeDto team = teamMap.computeIfAbsent(key, k -> {
				UserTreeDto t = new UserTreeDto();
				t.setId(r.getTeamId());
				t.setName(r.getTeamName());
				t.setKind("TEAM");
				dept.getUsers().add(t);
				return t;
			});
			
			// 3) 사용자
			UserTreeDto user = new UserTreeDto();
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