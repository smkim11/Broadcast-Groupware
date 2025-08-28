package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Board;
import com.example.broadcastgroupware.dto.BoardMenuDto;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.dto.PageDto;
@Mapper
public interface BoardMapper {

	// 관리자용 게시판
	int boardCount(String searchWord, String searchType);
	List<BoardPageDto> boardList(BoardPageDto boardPageDto);
	
	// header에 게시판리스트
	List<BoardMenuDto> getBoardMenuList();
	
	// 게시글 수 
	int getBoardPostCount(int boardId, BoardPageDto pageDto);
	
	// 게시글 리스트
	List<BoardPostDto> getBoardPosts(int boardId, BoardPageDto pageDto);



}
