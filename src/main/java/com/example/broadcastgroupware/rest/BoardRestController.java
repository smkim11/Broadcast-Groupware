package com.example.broadcastgroupware.rest;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.broadcastgroupware.dto.BoardMenuDto;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.dto.PostDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.BoardService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@RequestMapping("/board")
@Slf4j
public class BoardRestController {

    private final BoardService boardService;

    // 게시판 메뉴 header에 출력
    @GetMapping("/menu")
    @ResponseBody
    public List<BoardMenuDto> boardMenu() {
        return boardService.getBoardMenuList();
    }

    // 게시판 글 리스트 페이지
    @GetMapping("/{boardId}")
    public String boardListPage(@PathVariable int boardId, 
                                @RequestParam(defaultValue = "1") int currentPage,
                                @RequestParam(required = false) String searchType,
                                @RequestParam(required = false) String searchWord,
                                Model model) {

        // 글 수
        BoardPageDto pageDto = new BoardPageDto(currentPage, 10, 
                boardService.getBoardPostCount(boardId, new BoardPageDto(currentPage, 10, 0, searchWord, searchType)),
                searchWord, searchType);

        // 글 리스트
        List<BoardPostDto> postList = boardService.getBoardPosts(boardId, pageDto);

        model.addAttribute("postList", postList);
        model.addAttribute("pageDto", pageDto);
        model.addAttribute("boardId", boardId);

        return "user/board";
    }

    // 글 리스트를 JSON으로 반환 (페이징 + 검색용 Ajax)
    @GetMapping("/{boardId}/posts")
    @ResponseBody
    public Map<String, Object> boardPostsAjax(@PathVariable int boardId,
                                              @RequestParam(defaultValue = "1") int currentPage,
                                              @RequestParam(required = false) String searchType,
                                              @RequestParam(required = false) String searchWord) {

    	// log.info("게시판 번호: {}", boardId);
        BoardPageDto pageDto = new BoardPageDto(currentPage, 10,
                boardService.getBoardPostCount(boardId, new BoardPageDto(currentPage, 10, 0, searchWord, searchType)),
                searchWord, searchType);

        List<BoardPostDto> posts = boardService.getBoardPosts(boardId, pageDto);

        Map<String, Object> result = new HashMap<>();
        result.put("posts", posts);
        result.put("pageDto", pageDto);
        return result;
    }
    
    @PostMapping("/insertPost")
    @ResponseBody
    public String insertPost(HttpSession session,
                             @ModelAttribute PostDto postDto) throws IOException {

        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        int userId = loginUser.getUserId();

        List<MultipartFile> files = postDto.getFiles();
        if (files != null) {
            log.info("파일 개수: {}" + files.size());
            for (MultipartFile file : files) {
                log.info("파일 이름: {}" + file.getOriginalFilename() 
                    + ", 사이즈: " + file.getSize());
            }
        } else {
            System.out.println("files가 null입니다.");
        }

        return boardService.insertPost(postDto, userId);
    }


}
