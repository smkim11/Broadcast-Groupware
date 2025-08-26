package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class MeetingroomReservationDto {
    private int roomId;
    private String roomReservationReason;
    private String roomReservationStartTime; 
    private String roomReservationEndTime;  
}
