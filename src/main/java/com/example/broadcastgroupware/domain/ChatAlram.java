package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ChatAlram {
	private int chatAlramId;    	// chat_alram_id(PK)
	private int chatMessageId;		// chat_message_id(FK)
	private String chatMessageRead; // chat_message_read
	private String createDate;		// create_date
}
