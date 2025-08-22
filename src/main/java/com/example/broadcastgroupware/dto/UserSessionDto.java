package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class UserSessionDto {
    private int userId;
    private String username;
    private String role;
    private String fullName;
    private String userSn1;
    private String userSn2;
    private String userPhone;
    private String userEmail;
    private String userRank;
    private String userJoinDate;
    private String userResignDate;
    private String userimagesName;  // 추가 추후 수정

    // password 필드는 제외
    
    // 결재 화면용 추가 필드
    private Integer departmentId;
    private String departmentName;
    private Integer teamId;
    private String teamName;
}
