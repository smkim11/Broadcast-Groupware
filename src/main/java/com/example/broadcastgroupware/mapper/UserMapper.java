package com.example.broadcastgroupware.mapper;

import com.example.broadcastgroupware.domain.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
    User findByUsername(String username);
}
