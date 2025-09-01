package com.example.broadcastgroupware.dto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class PostDto {
	private int boardId;
	private int postId;
	private String postTitle;
	private String postContent;
	private String postPassword;
	private List<MultipartFile> files;
}
