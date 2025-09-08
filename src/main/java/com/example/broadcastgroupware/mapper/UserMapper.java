package com.example.broadcastgroupware.mapper;

import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.dto.UserSessionDto;

@Mapper
public interface UserMapper {
    User findByUsername(String username);
    UserSessionDto selectUserDeptTeamByUserId(@Param("userId") int userId);
    
    Map<String, Object> selectProfileInfo(@Param("userId") int userId);
}
