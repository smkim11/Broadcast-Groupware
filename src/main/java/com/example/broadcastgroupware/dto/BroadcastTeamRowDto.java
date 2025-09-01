package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class BroadcastTeamRowDto {
	private Integer broadcastTeamId;
    private Integer userId;
    private String fullName;  		// 팀원명
    private String departmentName;  // 소속 부서
    private String teamName;      	// 소속 팀
    private String userRank;  		// 직급
}
