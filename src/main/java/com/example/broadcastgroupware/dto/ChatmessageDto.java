package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class ChatmessageDto {
	private int chatMessageId;		    // chat_message_id(PK)
	private int chatroomUserId;		    // chatroom_user_id(FK)
	private String chatMessageContent;	// chat_message_content
	private String chatMessageStatus;	// chat_message_status
	private String createDate;			// create_date

}
