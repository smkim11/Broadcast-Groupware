package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Board;
import com.example.broadcastgroupware.dto.PageDto;
@Mapper
public interface BoardMapper {

	int boardCount(String searchWord, String searchType);

	List<Board> boardList(PageDto pageDto);

}
