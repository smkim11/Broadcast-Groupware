package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class BoardPostDto {
    private int postId;    
    private String title;     
    private String userName; 
    private String createDate; 
    private String postStatus; 
}
