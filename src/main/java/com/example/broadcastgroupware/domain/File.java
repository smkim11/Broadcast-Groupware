package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class File {
	private int fileId;
	private String fileType;  // '게시글','결재문서'
	private int fileTargetId;
	private String fileName;
	private String fileSaveName;
	private String fileExt;
	private String filePath;
	private String createDate;
}
