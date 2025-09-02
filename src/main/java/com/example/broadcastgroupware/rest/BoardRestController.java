package com.example.broadcastgroupware.rest;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.broadcastgroupware.domain.Comment;
import com.example.broadcastgroupware.domain.Post;
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
        result.put("boardId", boardId);
        return result;
    }
    
    // 관리자-게시판생성
	@PostMapping("/newBoard")
	public ResponseEntity<?> newBoard(@RequestParam("boardTitle") String boardTitle, HttpSession session){
        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        int userId = loginUser.getUserId();
        
		boardService.newBoard(boardTitle);
		
		return ResponseEntity.ok("success");
	}
	
	// 관리자-게시판명 수정
	@PostMapping("/modifyBoardName")
	public ResponseEntity<?> modifyBoardName(@RequestParam("boardTitle") String boardTitle, 
			@RequestParam("boardId") int boardId, HttpSession session){
		
		log.info("게시판 수정 아이디: {}", boardId);
		log.info("게시판 수정 명: {}", boardTitle);
		
        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        int userId = loginUser.getUserId();
        
		boardService.modifyBoardName(boardId, boardTitle);
		
		return ResponseEntity.ok("success");
	}
	
	// 관리자-게시판 상태값 수정
	@PostMapping("/modifyBoardStatus")
	public ResponseEntity<?> modifyBoardStatus(@RequestBody Map<String, String> data) {
	    int boardId = Integer.parseInt(data.get("boardId"));
	    String boardStatus = data.get("boardStatus");
	    
	    //log.info("게시판 수정 아이디: {}", boardId);
	    //log.info("게시판 수정 상태: {}", boardStatus);
	    
	    boardService.modifyBoardStatus(boardId, boardStatus);

	    return ResponseEntity.ok("success");
	}


	
	// 관리자- 상태값 변경
	// 상단노출(긴급공지)
	@PostMapping("/toggleFixed")
	@ResponseBody
	public ResponseEntity<?> toggleFixed(@RequestBody Post post) {
	    try {
	        boardService.modifyFixed(post.getPostId(), post.getTopFixed());
	        return ResponseEntity.ok("success");
	    } catch (Exception e) {
	        e.printStackTrace(); // 콘솔 로그 확인
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
	    }
		
	}

	// 노출(비활성화시 게시글리스트에 출력x)
	@PostMapping("/togglePostStatus")
	@ResponseBody
	public ResponseEntity<?> togglePostStatus(@RequestBody Post post) {
	    try {
	        boardService.modifyPostStatus(post.getPostId(), post.getPostStatus());
	        return ResponseEntity.ok("success");
	    } catch (Exception e) {
	        e.printStackTrace(); // 콘솔 로그 확인
	        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
	    }

	}

	// 게시글 등록
    @PostMapping("/insertPost")
    @ResponseBody
    public String insertPost(HttpSession session,
                             @ModelAttribute PostDto postDto) throws IOException {
    	
    	// log.info("게시글 비밀번호: {}", postDto.getPostPassword());

        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        int userId = loginUser.getUserId();

        List<MultipartFile> files = postDto.getFiles();
        if (files != null) {
            //log.info("파일 개수: " + files.size());
            for (MultipartFile file : files) {
               /* log.info("파일 이름: " + file.getOriginalFilename() 
                    + ", 사이즈: " + file.getSize()); */
            }
        } else {
            log.info("files가 null입니다.", "");
        }

        return boardService.insertPost(postDto, userId);
    }
    
    
    
    // 게시글 삭제
    @PostMapping("/deletePost")
    @ResponseBody
    public Map<String, Boolean> deletePost(@RequestParam int postId, @RequestParam String postPassword) {
    	
    	log.info("삭제할 게시글: {}", postId);
    	log.info("게시글 암호: {}", postPassword);
    	
        boolean result = boardService.deletePost(postId, postPassword);

        Map<String, Boolean> response = new HashMap<>();
        response.put("success", result);

        return response;
    }


    
    // 최초댓글
    @PostMapping("/comment/insert")
    public ResponseEntity<Comment> commentInsert(@RequestBody Comment comment) {
    	// log.info("댓글 내용: " + comment.getCommentContent());
        try {

        	Comment commentInsert = boardService.commentInsert(comment);
            return ResponseEntity.ok(commentInsert);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    // 대댓글
    @PostMapping("/cecondComment/insert")
    public ResponseEntity<Comment> cecondCommentInsert(@RequestBody Comment comment) {
    	//log.info("댓글 내용: " + comment.getCommentContent());
    	//log.info("원댓글 아이디: " + comment.getCommentParent());
    	//log.info("postId: " + comment.getPostId());
    	//log.info("userId: " + comment.getUserId());
    	
        try {

        	Comment cecondCommentInsert = boardService.cecondCommentInsert(comment);
            return ResponseEntity.ok(cecondCommentInsert);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    // 댓글, 대댓글 수정
    @PostMapping("/comment/modify")
    @ResponseBody
    public ResponseEntity<?> updateComment(@RequestBody Comment comment, HttpSession session){
        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        
        //log.info("댓글 id: " + comment.getCommentId());
        //log.info("수정 댓글 내용: " + comment.getCommentContent());

        if(loginUser == null || loginUser.getUserId() != comment.getUserId()){
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("권한 없음");
        }

        boardService.modifyComment(comment);
        return ResponseEntity.ok("success");
    }

    // 댓글, 대댓글 삭제(비활성화)
    @PostMapping("/comment/delete")
    @ResponseBody
    public ResponseEntity<?> deleteComment(@RequestBody Map<String, Integer> param, HttpSession session){
        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        

        if(loginUser == null){
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("권한 없음");
        }
        
        Integer commentId = param.get("commentId");
        if(commentId == null){
            return ResponseEntity.badRequest().body("commentId 필요");
        }
        // log.info("삭제할 댓글 id: {}, commentId");
        
        /*
        Comment target = boardService.getCommentById(commentId);
        if(target == null || !loginUser.getUserId().equals(target.getUserId())){
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("권한 없음");
        }
        */

        boardService.deleteComment(commentId);
        return ResponseEntity.ok("success");
    }


}
