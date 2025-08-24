package com.example.broadcastgroupware.domain;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

@Data
public class ChatMessage {
	private Integer chatMessageId;		    // chat_message_id(PK)
	private Integer chatroomUserId;		    // chatroom_user_id(FK)
	private Integer chatroomId;				// chatroom_id(FK)
	private String chatMessageContent;		// chat_message_content
	private String chatMessageStatus;		// chat_message_status
	@JsonFormat(pattern="yyyy-MM-dd'T'HH:mm:ssXXX")
	private LocalDateTime createDate;		// create_date
}
