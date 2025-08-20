package com.example.broadcastgroupware.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)				// null 필드는 json에 안보이게
public class ChatMessageDto {
	private Integer chatMessageId;						// 서버가 생성
	private Integer chatroomId;								// 어느 방
	private Integer userId;									// 보낸 사람(오른쪽 정렬 기준)
	private String chatMessageContent;					// 메시지 내용(프론트 -> 서버)
	private String chatMessageStatus;					// "SENT" 등 상태 값
	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
	private java.time.LocalDateTime createDate;			// 보낸시간
	private String fullName;							// 화면에 표시할 이름
	private String userRank;							// 화면에 표시할 직급

}
