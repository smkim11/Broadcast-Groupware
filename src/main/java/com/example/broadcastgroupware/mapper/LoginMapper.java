package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface LoginMapper {

	// 이메일 찾아오기
	String findEmail(@Param("username") int username);
	
	// 새로만든 임시 비밀번호 저장
	void updateNewPassword(@Param("username") int username, @Param("password") String password);


}
