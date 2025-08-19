package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class VacationFormDto {
	private String vacationFormType;      // '연차','반차'
    private String vacationFormHalfType;  // 오전, 오후
    private String vacationFormStartDate;
    private String vacationFormEndDate;
}
