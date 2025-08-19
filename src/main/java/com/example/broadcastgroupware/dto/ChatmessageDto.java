package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class ChatmessageDto {
	private Integer chatMessageId;		// 서버가 생성
	private String chatroomId;			// 어느 방
	private int userId;				// 보낸 사람(오른쪽 정렬 기준)
	private String chatMessageContent;	// 메시지 내용(프론트 -> 서버)
	private String chatMessageStatus;	// "SENT" 등 상태 값
	private String createDate;			// 보낸날짜
	private String fullName;			// 화면에 표시할 이름
	private String userRank;			// 화면에 표시할 직급

}
