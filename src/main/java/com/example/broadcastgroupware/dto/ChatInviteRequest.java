package com.example.broadcastgroupware.dto;

import java.util.List;


import lombok.Data;

@Data
public class ChatInviteRequest {
	
	private List<Integer> userIds;

}
