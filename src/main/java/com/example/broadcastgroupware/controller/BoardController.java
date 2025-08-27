package com.example.broadcastgroupware.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.domain.Board;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.BoardService;

import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
public class BoardController {
	
	private final BoardService boardService;
	
	public BoardController(BoardService boardService) {
		this.boardService = boardService;
	}
	
	// 관리자 게시판리스트
	@GetMapping("/user/adminBoard")
	public String adminBoard(HttpSession session, Model model, @RequestParam(defaultValue = "1") int currentPage,
							@RequestParam(required = false) String searchType, @RequestParam(required = false) String searchWord) {
		
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		
		if(loginUser == null) {
			return "redirect:/login";
		} 
		
		int userId = loginUser.getUserId();
		String role = loginUser.getRole();
		
		if(!"admin".equals(role)) {
			return "redirect:/home"; 
		}
		
		int totalCount = boardService.boardCount(searchWord, searchType);
		
		PageDto pageDto = new PageDto(currentPage, 10, totalCount, searchWord, searchType);
		
		List<Board> boardList = boardService.boardList(pageDto);
		
		model.addAttribute("boardList", boardList);
		model.addAttribute("userId", userId);
		model.addAttribute("role", role);
		return "user/adminBoard";
	}
}
