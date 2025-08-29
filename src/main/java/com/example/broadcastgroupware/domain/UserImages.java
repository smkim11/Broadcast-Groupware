package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class UserImages {
	private int userImagesId;
	private int userId;
	private String userImagesType;
	private String userImagesName;
	private String userImagesExt;
	private String userImagesPath;
	private String createDate;
	private String updateDate;
}
