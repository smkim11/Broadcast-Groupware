package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ChatbotHistory {
	private int chatbotHistoryId;	// chatbot_history_id(PK)
	private int userId;				// user_id(FK)
	private String chatbotUserChat;	// chatbot_user_chat
	private String chatbotAiChat;	// chatbot_ai_chat
	private String createDate;		// create_date
}
