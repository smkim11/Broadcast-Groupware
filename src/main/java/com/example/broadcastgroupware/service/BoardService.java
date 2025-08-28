package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.dto.BoardMenuDto;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.mapper.BoardMapper;

import lombok.RequiredArgsConstructor;

@Service
public class BoardService {
	
	private final BoardMapper boardMapper;

	public BoardService(BoardMapper boardMapper) {
		this.boardMapper = boardMapper;
	}

	// 관리자 게시판
	public int boardCount(String searchWord, String searchType) {
		return boardMapper.boardCount(searchWord, searchType);
	}
	public List<BoardPageDto> boardList(BoardPageDto boardPageDto) {
		return boardMapper.boardList(boardPageDto);
	}

	// header에 게시판리스트
	public List<BoardMenuDto> getBoardMenuList() {
		return boardMapper.getBoardMenuList();
	}

	// 게시판 내 게시글 수
	public int getBoardPostCount(int boardId, BoardPageDto pageDto) {
		return boardMapper.getBoardPostCount(boardId, pageDto);
	}

	// 게시글 리스트
	public List<BoardPostDto> getBoardPosts(int boardId, BoardPageDto pageDto) {
		return boardMapper.getBoardPosts(boardId, pageDto);
	}




}
