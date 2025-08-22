package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class Chatroom {
	private Integer chatroomId;			// chatroom_id(PK)
	private String dmKey;			// dm_key(unique) 초대한id ex) 3:5
	private String roomType;		// room_type	enum('GROUP', 'DM') 기본값 'DM'
	private String chatroomName;	// chatroom_name
	private String chatroomStatus;	// chatroom_status
	private String lastMessageAt;	// last_message_at 최근대화가 이루어진 방이 위로 올라오도록 정렬
	private String createDate;		// create_date
}
