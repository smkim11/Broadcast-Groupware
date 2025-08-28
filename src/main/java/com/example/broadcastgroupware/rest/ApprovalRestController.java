package com.example.broadcastgroupware.rest;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.ApprovalDocumentDto;
import com.example.broadcastgroupware.service.ApprovalService;

@RestController
@RequestMapping("/approval")
public class ApprovalRestController {
	private final ApprovalService approvalService;

    public ApprovalRestController(ApprovalService approvalService) {
        this.approvalService = approvalService;
    }

    // 공통 문서 작성
    @PostMapping("/common/new")
    public ResponseEntity<Integer> createCommon(@RequestBody ApprovalDocumentDto dto,
    											@RequestParam(defaultValue = "false") boolean draft) {
        int docId = approvalService.createCommonDocument(dto, draft);
        return ResponseEntity.ok(docId);
    }

    // 휴가 문서 작성
    @PostMapping("/vacation/new")
    public ResponseEntity<Integer> createVacation(@RequestBody ApprovalDocumentDto dto,
    											@RequestParam(defaultValue = "false") boolean draft) {
        int docId = approvalService.createVacationDocument(dto, draft);
        return ResponseEntity.ok(docId);
    }

    // 방송 문서 작성
    @PostMapping("/broadcast/new")
    public ResponseEntity<Integer> createBroadcast(@RequestBody ApprovalDocumentDto dto,
    											@RequestParam(defaultValue = "false") boolean draft) {
        int docId = approvalService.createBroadcastDocument(dto, draft);
        return ResponseEntity.ok(docId);
    }
}
