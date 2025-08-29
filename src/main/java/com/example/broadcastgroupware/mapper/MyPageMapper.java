package com.example.broadcastgroupware.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.domain.UserImages;
import com.example.broadcastgroupware.dto.MyPageDto;

@Mapper
public interface MyPageMapper {
	MyPageDto userInfo(int userId);
	void insertUserSign(UserImages userImages);
	void updateMyPage(User user);
}
