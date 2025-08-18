package com.example.broadcastgroupware.dto;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.BroadcastForm;

import lombok.Data;

@Data
public class BroadcastDocumentRequestDto {
	private ApprovalDocument approvalDocument;
    private BroadcastForm broadcastForm;
}
