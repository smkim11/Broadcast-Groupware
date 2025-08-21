package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class ChatroomUser {
	private int chatroomUserId;			// chatroom_user_id(PK)
	private int chatroomId;				// chatroom_id(FK)
	private int userId;					// user_id(FK)
	private String chatroomUserStatus;	// chatroom_user_status
	private String lastReadAt;			// last_read_at 읽음확인용
	private String createDate;			// create_date
}
