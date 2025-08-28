package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class File {
	private int fileId;
	private String fileType;      // '게시글','결재문서'
	private int fileTargetId;     // postId
	private String fileName;      // 원본 이름
	private String fileSaveName;  // 서버 저장 이름
	private String fileExt;
	private String filePath;
	private String createDate;
}
