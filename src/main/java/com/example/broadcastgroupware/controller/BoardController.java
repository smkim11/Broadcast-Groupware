package com.example.broadcastgroupware.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
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
		
		BoardPageDto boardPageDto = new BoardPageDto(currentPage, 10, totalCount, searchWord, searchType);
		
		List<BoardPageDto> boardList = boardService.boardList(boardPageDto);
		
		model.addAttribute("boardList", boardList);
		model.addAttribute("pageDto", boardPageDto);
		model.addAttribute("userId", userId);
		model.addAttribute("role", role);
		return "user/adminBoard";
	}
	
	// 게시판
	@GetMapping("/board/{boardId}/list")
    public String boardList(@PathVariable int boardId,
                            @RequestParam(defaultValue = "1") int currentPage,
                            @RequestParam(required = false) String searchType,
                            @RequestParam(required = false) String searchWord,
                            Model model) {

		//log.info("이동할 게시판 번호: {}", boardId);
        // 페이징 DTO 생성
        BoardPageDto pageDto = new BoardPageDto(currentPage, 10,
                boardService.getBoardPostCount(boardId, new BoardPageDto(currentPage, 10, 0, searchWord, searchType)),
                searchWord, searchType);

        // 게시글 리스트 가져오기
        List<BoardPostDto> postList = boardService.getBoardPosts(boardId, pageDto);

        // JSP로 전달
        model.addAttribute("postList", postList);
        model.addAttribute("pageDto", pageDto);
        model.addAttribute("boardId", boardId);

        return "user/board";
    }
}
