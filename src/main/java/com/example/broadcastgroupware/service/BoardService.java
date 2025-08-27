package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.example.broadcastgroupware.domain.Board;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.mapper.BoardMapper;

@Service
public class BoardService {
	
	private final BoardMapper boardMapper;

	public BoardService(BoardMapper boardMapper) {
		this.boardMapper = boardMapper;
	}

	public int boardCount(String searchWord, String searchType) {
		return boardMapper.boardCount(searchWord, searchType);
	}

	public List<Board> boardList(PageDto pageDto) {
		return boardMapper.boardList(pageDto);
	}

}
