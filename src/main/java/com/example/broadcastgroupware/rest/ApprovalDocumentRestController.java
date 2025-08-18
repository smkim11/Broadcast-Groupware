package com.example.broadcastgroupware.rest;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.BroadcastDocumentRequestDto;
import com.example.broadcastgroupware.dto.CommonDocumentRequestDto;
import com.example.broadcastgroupware.dto.VacationDocumentRequestDto;
import com.example.broadcastgroupware.service.ApprovalDocumentService;

@RestController
@RequestMapping("/approvals")
public class ApprovalDocumentRestController {
	private final ApprovalDocumentService approvalDocumentService;

    public ApprovalDocumentRestController(ApprovalDocumentService approvalDocumentService) {
        this.approvalDocumentService = approvalDocumentService;
    }

    // 공통 문서 작성
    @PostMapping("/common")
    public ResponseEntity<Integer> createCommon(@RequestBody CommonDocumentRequestDto dto) {
        int docId = approvalDocumentService.createCommonDocument(dto);
        return ResponseEntity.ok(docId);
    }

    // 휴가 문서 작성
    @PostMapping("/vacation")
    public ResponseEntity<Integer> createVacation(@RequestBody VacationDocumentRequestDto dto) {
        int docId = approvalDocumentService.createVacationDocument(dto);
        return ResponseEntity.ok(docId);
    }

    // 방송 문서 작성
    @PostMapping("/broadcast")
    public ResponseEntity<Integer> createBroadcast(@RequestBody BroadcastDocumentRequestDto dto) {
        int docId = approvalDocumentService.createBroadcastDocument(dto);
        return ResponseEntity.ok(docId);
    }
}
