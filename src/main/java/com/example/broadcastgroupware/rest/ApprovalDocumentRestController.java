package com.example.broadcastgroupware.rest;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.ApprovalDocumentDto;
import com.example.broadcastgroupware.service.ApprovalDocumentService;

@RestController
@RequestMapping("/approval")
public class ApprovalDocumentRestController {
	private final ApprovalDocumentService approvalDocumentService;

    public ApprovalDocumentRestController(ApprovalDocumentService approvalDocumentService) {
        this.approvalDocumentService = approvalDocumentService;
    }

    // 공통 문서 작성
    @PostMapping("/common")
    public ResponseEntity<Integer> createCommon(@RequestBody ApprovalDocumentDto dto,
    											@RequestParam(defaultValue = "false") boolean draft) {
        int docId = approvalDocumentService.createCommonDocument(dto, draft);
        return ResponseEntity.ok(docId);
    }

    // 휴가 문서 작성
    @PostMapping("/vacation")
    public ResponseEntity<Integer> createVacation(@RequestBody ApprovalDocumentDto dto,
    											@RequestParam(defaultValue = "false") boolean draft) {
        int docId = approvalDocumentService.createVacationDocument(dto, draft);
        return ResponseEntity.ok(docId);
    }

    // 방송 문서 작성
    @PostMapping("/broadcast")
    public ResponseEntity<Integer> createBroadcast(@RequestBody ApprovalDocumentDto dto,
    											@RequestParam(defaultValue = "false") boolean draft) {
        int docId = approvalDocumentService.createBroadcastDocument(dto, draft);
        return ResponseEntity.ok(docId);
    }
}
