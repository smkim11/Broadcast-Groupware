package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class BroadcastTeamRowDto {
	private Integer broadcastTeamId;
    private Integer userId;
    
    private String  fullName;      // 팀원명
    private String  deptName;      // 소속 부서
    private String  teamName;      // 소속 팀
    private String  positionName;  // 직급
}
