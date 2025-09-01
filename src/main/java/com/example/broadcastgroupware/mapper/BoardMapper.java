package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.File;
import com.example.broadcastgroupware.domain.Post;
import com.example.broadcastgroupware.dto.BoardMenuDto;
import com.example.broadcastgroupware.dto.BoardPageDto;
import com.example.broadcastgroupware.dto.BoardPostDto;
import com.example.broadcastgroupware.dto.CommentDto;
import com.example.broadcastgroupware.dto.PostDto;
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


    // 게시글 저장
    int savePost(PostDto postDto, int userId);

    // 파일 저장 (복수)
    void saveFiles(List<File> fileList);

    // 게시글 리스트
    List<BoardMenuDto> getBoardMenuListForFiles();
    
    // 상세 게시글
	List<Post> postDetail(int postId);
	
	//댓글
	List<CommentDto> selectComment(int postId);
	
	// 게시글 파일
	List<File> fileList(int postId);
	
	// 파일
	File fileById(int fileId);


}
