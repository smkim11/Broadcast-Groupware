package com.example.broadcastgroupware.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class ChatroomListDto {
	/*
	 * 사이드바 그룹채팅/1:1채팅 리스트 표시용 Dto
	 * 필드명은 DB 컬럼과 1:1로 최대한 맞춤
	 * DM이면 chatroom_name 대신 상배당 이름을 sql에서 alias로 넣어줌
	 */
	
	private int chatroomId;		// chatroom_id;
	private String chatroomName;	// chatroom_name 목록 채팅방 이름
	private String peerFullName;	// 상대방 이름
	private String peerUserRank;	// 상대방 직급
	private String lastMessage;		// last_message (JOIN/서브쿼리에서 AS)
	private String lastMessageAt;	// last_message_at (chatroom 테이블)
	private Integer unreadCount;	// unred_count (계산값이면 null 가능 -> Integer)
	private String roomType;		// room_type ('DM' | 'GROUP')
	private String dmKey;			// dm_key
	private LocalDateTime lastIncomingAt;	// 방 나가기 상태

	// 서비스에서 프로필이미지 경로 계산
	private Integer peerUserId;		// DM일 때 상대 user_id
	private String peerAvatarPath;	// DM일 때 상대 아바타 "원 경로"
	private String groupAvatarPath;	// GROUP일 때 방 아바타 경로
	
	// 최종 응답용 (서비스단에서)
	private String avatarUrl;		// 최종 URL
}
