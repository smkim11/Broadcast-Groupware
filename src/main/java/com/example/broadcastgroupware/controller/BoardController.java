package com.example.broadcastgroupware.controller;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.domain.File;
import com.example.broadcastgroupware.domain.Post;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.dto.CommentDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.BoardService;

import jakarta.servlet.http.HttpServletResponse;
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
	@GetMapping("/admin/adminBoard")
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
		return "admin/adminBoard";
	}
	
	// 게시판
	@GetMapping("/board/{boardId}/list")
    public String boardList(@PathVariable int boardId, HttpSession session,
                            @RequestParam(defaultValue = "1") int currentPage,
                            @RequestParam(required = false) String searchType,
                            @RequestParam(required = false) String searchWord,
                            Model model) {
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		
		if(loginUser == null) {
			return "redirect:/login";
		} 
		
		int userId = loginUser.getUserId();
		String role = loginUser.getRole();

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
        model.addAttribute("userId", userId);
        model.addAttribute("role", role);

        return "user/board";
    }
	
	// 게시글 상세보기 
	@GetMapping("/post/detail")
	public String postDetail(HttpSession session, Model model, @RequestParam int postId, @RequestParam int boardId) {
		
		// log.info("게시글 번호: {}", postId);
		// log.info("게시판 번호: {}", boardId);
		
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		
		if(loginUser == null) {
			return "redirect:/login";
		} 
		
		int userId = loginUser.getUserId();
		String userRole = loginUser.getRole();
		
		// 상세게시글 
		List<Post> detail = boardService.postDetail(postId);
		
		// 댓글
		List<CommentDto> allComments = boardService.selectComment(postId);
		
	    // 댓글 + 대댓글 (1단계)
	    List<CommentDto> oneLevelComments = new ArrayList<>();
	    for (CommentDto c : allComments) {
	        if (c.getCommentParent() == null) {
	            // 최상위 댓글
	        	oneLevelComments.add(c);
	        } else {
	            // 대댓글
	            for (CommentDto parent : allComments) {
	                if (parent.getCommentId() == c.getCommentParent()) {
	                    parent.getReplies().add(c);
	                    break;
	                }
	            }
	        }
	    }
	    
	    List<File> fileList = boardService.fileList(postId);
		
		model.addAttribute("postId", postId);
		model.addAttribute("boardId", boardId);
		model.addAttribute("userRole", userRole);
		model.addAttribute("detail", detail);
		model.addAttribute("oneLevelComments", oneLevelComments);
		model.addAttribute("fileList", fileList);
		
		return "user/postDetail";
	}
	
	// 파일 다운로드
	@GetMapping("/file/download")
	public void downloadFile(@RequestParam("fileId") int fileId, HttpServletResponse response) throws IOException {

		log.info("fileId: {}", fileId);
	    // DB에서 DTO 가져오기
	    File fileDto = boardService.fileById(fileId);
	    if (fileDto == null) {
	        response.sendError(HttpServletResponse.SC_NOT_FOUND, "파일이 존재하지 않습니다.");
	        return;
	    }

	    // DTO에서 실제 파일 객체 생성
	    java.io.File f = new java.io.File(fileDto.getFilePath());
	    if (!f.exists()) {
	        response.sendError(HttpServletResponse.SC_NOT_FOUND, "서버에 파일이 없습니다.");
	        return;
	    }

	    // 다운로드 헤더
	    response.setContentType("application/octet-stream");
	    response.setHeader("Content-Disposition",
	            "attachment; filename=\"" + URLEncoder.encode(fileDto.getFileName(), "UTF-8") + "\";");

	    try (InputStream in = new FileInputStream(f);
	         OutputStream out = response.getOutputStream()) {
	        byte[] buffer = new byte[1024];
	        int len;
	        while ((len = in.read(buffer)) != -1) {
	            out.write(buffer, 0, len);
	        }
	    }
	}

	
}
