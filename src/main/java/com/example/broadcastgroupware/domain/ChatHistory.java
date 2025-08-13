package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ChatHistory {
	private int chatHistoryId;	// chat_history_id(PK)
	private int chatMessageId;	// chat_message_id(FK)
	private String createDate;	// create_date
}
