package com.example.broadcastgroupware.dto;

import java.util.List;

import lombok.Data;

@Data
public class ChatroomGroupDto {
	private String roomName;
	private List<Integer> memberIds;	// [1, 2, 3]
}
