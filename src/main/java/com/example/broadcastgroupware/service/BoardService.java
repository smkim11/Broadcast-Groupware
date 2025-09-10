package com.example.broadcastgroupware.service;

import java.beans.Transient;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.example.broadcastgroupware.dto.BoardMenuDto;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.dto.CommentDto;
import com.example.broadcastgroupware.dto.PostDto;
import com.example.broadcastgroupware.domain.Comment;
import com.example.broadcastgroupware.domain.File;
import com.example.broadcastgroupware.domain.Post;
import com.example.broadcastgroupware.mapper.BoardMapper;

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
	
	// 관리자 - 게시판 생성
	public void newBoard(String boardTitle) {
		boardMapper.newBoard(boardTitle);
	}
	
	// 관리자 - 게시판 이름 변경
	public void modifyBoardName(int boardId, String boardTitle) {
		boardMapper.modifyBoardName(boardId, boardTitle);
	}
	
	// 관리자 - 게시판 상태값 변경
	public void modifyBoardStatus(int boardId, String boardStatus) {
		boardMapper.modifyBoardStatus(boardId, boardStatus);
	}
	
	// 관리자 - 상단고정
	public void modifyFixed(int postId, String topFixed) {
		boardMapper.modifyFixed(postId, topFixed);
	}

	// 관리자 - 게시글 노출 성정
	public void modifyPostStatus(int postId, String postStatus) {
		boardMapper.modifyPostStatus(postId, postStatus);
	}

	// 게시글 리스트
	public List<BoardPostDto> getBoardPosts(int boardId, BoardPageDto pageDto) {
		return boardMapper.getBoardPosts(boardId, pageDto);
	}

	// 게시글 등록
	@Transactional
	public String insertPost(PostDto postDto, int userId) throws IOException {
		List<File> fileList = new ArrayList<>();
		List<MultipartFile> files = postDto.getFiles();

		// 1. 게시글 저장
		boardMapper.savePost(postDto, userId); // postId가 set됨 (useGeneratedKeys)

		// 2. 파일 처리
		if (files != null && !files.isEmpty()) {
			// String uploadDir = "C:\\final\\"; 로컬경로
			String uploadDir = "/home/ubuntu/upload/"; // 로컬 C드라이브 경로

			for (MultipartFile file : files) {
				if (file.isEmpty()) continue;

				String originalName = file.getOriginalFilename();
				String ext = originalName.substring(originalName.lastIndexOf(".") + 1);
				String saveName = UUID.randomUUID().toString() + "." + ext;
				String filePath = uploadDir + saveName;

				// 서버에 저장
				java.io.File dest = new java.io.File(filePath);
				dest.getParentFile().mkdirs();
				file.transferTo(dest);

				// DB용 DTO 생성
				File fileDto = new File();
				fileDto.setFileType("게시글");
				fileDto.setFileTargetId(postDto.getPostId()); // 방금 저장된 게시글 PK
				fileDto.setFileName(originalName);
				fileDto.setFileSaveName(saveName);
				fileDto.setFileExt(ext);
				fileDto.setFilePath(filePath);
				fileList.add(fileDto);
			}

			// 3. 파일 DB 저장
			if (!fileList.isEmpty()) {
				boardMapper.saveFiles(fileList);
			}
		}

		return "success";
	}

	// 상세 게시글
	public List<Post> postDetail(int postId) {
		return boardMapper.postDetail(postId);
	}
	
	// 게시글 수정
	public boolean modifyPost(int postId, String postTitle, String postContent) {
		
		int deletedCount = boardMapper.modifyPost(postId, postTitle, postContent);
		
		return deletedCount > 0;
	}
	
	// 게시글 삭제
	public boolean deletePost(int postId, String postPassword) {
	
		int deletedCount = boardMapper.deletePost(postId, postPassword);
		
		return deletedCount > 0;
	}

	// 댓글
	public List<CommentDto> selectComment(int postId) {
		return boardMapper.selectComment(postId);
	}
	
	// 대댓글
	public List<CommentDto> selectReplies(int postId) {
		return boardMapper.selectReplies(postId);
	}

	// 게시글 파일
	public List<File> fileList(int postId) {
		return boardMapper.fileList(postId);
	}

	// 파일 
	public File fileById(int fileId) {
		return boardMapper.fileById(fileId);
	}

	// 첫 댓글 등록
	public Comment commentInsert(Comment comment) {
		boardMapper.commentInsert(comment);
		return comment;
	}
	
	// 대댓글 등록
	public Comment cecondCommentInsert(Comment comment) {
		boardMapper.cecondCommentInsert(comment);
		return comment;
	}

	// 댓글, 대댓글 수정
	public void modifyComment(Comment comment) {
		boardMapper.modifyComment(comment);
	}

	// 댓글, 대댓글 삭제(비활성화)
	public void deleteComment(int commentId) {
		boardMapper.deleteComment(commentId);
	}



}
