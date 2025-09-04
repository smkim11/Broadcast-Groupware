package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.dto.UserListDto;
import com.example.broadcastgroupware.dto.UserRowDto;

@Mapper
public interface UserListMapper {
	
	// 조직도 트리 만들 때 사용할 "조인 한 줄" 결과
	List<UserRowDto> selectUsersRow();
	
	
	// 유저리스트 
	// 조직도리스트 조회
	int countUserList(@Param("q") String q);
	
	// 유저리스트
	List<UserListDto> selectUserList(@Param("q") String q,
									 @Param("limit") int limit,
									 @Param("offset") int offset);
	
}
