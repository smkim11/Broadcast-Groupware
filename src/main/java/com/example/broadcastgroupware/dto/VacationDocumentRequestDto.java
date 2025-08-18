package com.example.broadcastgroupware.dto;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.VacationForm;

import lombok.Data;

@Data
public class VacationDocumentRequestDto {
	private ApprovalDocument approvalDocument;
    private VacationForm vacationForm;
}
