package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class ChatroomDmDto {
	/*
	 * 1:1 DM 채팅방 생성 요청
	 * 클라이언트는 상대방 사용자 ID만 보냄
	 * */
	
	private int targetUserId;	// 상대방 사용자 ID
}
