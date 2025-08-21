package com.example.broadcastgroupware.dto;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class ChatUserTreeDto {
	private int id;												// 부서/팀/유저 식별자
	private String name;										// 표시 이름
	private String kind;										// "DEPT" | "TEAM" | "USER"
	private String userRank;									// user일 때만 사용
	private List<ChatUserTreeDto> users = new ArrayList<>();	// 자식 노드
}
