package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Chatroom {
	private int chatroomId;			// chatroom_id(PK)
	private int userId;				// user_id(FK)
	private String chatroomName;	// chatroom_name
	private String chatroomStatus;	// chatroom_status
	private String createDate;		// create_date
}
