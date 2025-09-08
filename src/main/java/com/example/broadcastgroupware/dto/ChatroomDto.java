package com.example.broadcastgroupware.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class ChatroomDto {
	/*
	 * 채팅방 상세/목록 공통으로 내려 줄 때 사용할 응답 Dto
	 * 도메인 Chatroom 과 필드 1:1 대응(문자열 시간 유지)
	 */
	private Integer chatroomId;				// chatroom_id(PK)
	private int userId;						// user_id(FK)
	private String dmKey;					// "작은id:큰id (3:5)
	private String roomType;				// "DM" 또는 "GROUP"
	private String chatroomName;			// 방 이름(DM이면 상대 이름 등)
	private String chatroomStatus;			// 방 나가기 상태
	private String lastMessage;				// 마지막 메시지
	private LocalDateTime lastMessageAt;			// 마지막 메시지 시각(캐시)
	private boolean alreadyExists;
	private String createDate;				// 생성 시각
	
	private String roomAvatarUrl;

}
