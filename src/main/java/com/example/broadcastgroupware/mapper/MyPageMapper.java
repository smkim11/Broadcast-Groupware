package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.domain.UserImages;
import com.example.broadcastgroupware.dto.MyPageDto;
import com.example.broadcastgroupware.dto.PasswordDto;

@Mapper
public interface MyPageMapper {
	// 마이페이지 조회
	MyPageDto userInfo(int userId);
	// 프로필 이미지 조회
	UserImages findProfile(int userId);
	// 비밀번호 조회
	String findPw(int userId);
	// 직전에 사용한 비밀번호
	String findPrevPw(int userId);
	// 서명 추가
	void insertUserSign(UserImages userImages);
	// 프로필 수정
	void updateUserProfile(UserImages userImages);
	// 개인정보 수정
	void updateMyPage(User user);
	// 비밀번호 수정
	void updatePassword(PasswordDto passwordDto);
	// 비밀번호 이력에 비밀번호 추가
	void insertPasswordHistory(PasswordDto passwordDto);
	// 서명 수정
	void updateUserSign(UserImages userImages);
}
