package com.example.broadcastgroupware.domain;

import lombok.Data;

@Data
public class VacationForm {
	private int vacationFormId;
	private int approvalDocumentId;
	private String vacationFormType;  // '연차','반차'
	private String vacationFormHalfType;  // 오전, 오후
	private String vacationFormStartDate;
	private String vacationFormEndDate;
	private String createDate;
	private String updateDate;
}
