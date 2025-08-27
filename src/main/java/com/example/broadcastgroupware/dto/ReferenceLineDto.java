package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class ReferenceLineDto {
    private Integer userId;  // 개인 참조
    private Integer teamId;  // 팀 참조
}
