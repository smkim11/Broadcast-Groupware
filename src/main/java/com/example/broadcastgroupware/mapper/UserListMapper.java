package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.dto.UserRowDto;

@Mapper
public interface UserListMapper {
	
	// 조직도 트리 만들 때 사용할 "조인 한 줄" 결과
	List<UserRowDto> selectUsersRow();
	
}
