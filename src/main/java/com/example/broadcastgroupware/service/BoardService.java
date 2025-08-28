package com.example.broadcastgroupware.service;

import java.beans.Transient;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.broadcastgroupware.dto.BoardMenuDto;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.dto.PostDto;
import com.example.broadcastgroupware.domain.File;
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
			String uploadDir = "C:/upload/"; // 로컬 C드라이브 경로

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



}
