package com.example.broadcastgroupware.rest;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
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
    

	// 공통/일반 문서 수정
	@PostMapping("/common/update/{id}")
	public ResponseEntity<Integer> updateCommon(@PathVariable("id") int approvalDocumentId,
	                                            @RequestBody ApprovalDocumentDto dto) {
	    int updatedId = approvalService.updateCommonDocument(approvalDocumentId, dto);
	    return ResponseEntity.ok(updatedId);
	}
	
	// 휴가 문서 수정
	@PostMapping("/vacation/update/{id}")
	public ResponseEntity<Integer> updateVacation(@PathVariable("id") int approvalDocumentId,
	                                              @RequestBody ApprovalDocumentDto dto) {
	    int updatedId = approvalService.updateVacationDocument(approvalDocumentId, dto);
	    return ResponseEntity.ok(updatedId);
	}
	
	// 방송 문서 수정
	@PostMapping("/broadcast/update/{id}")
	public ResponseEntity<Integer> updateBroadcast(@PathVariable("id") int approvalDocumentId,
	                                               @RequestBody ApprovalDocumentDto dto) {
	    int updatedId = approvalService.updateBroadcastDocument(approvalDocumentId, dto);
	    return ResponseEntity.ok(updatedId);
	}

}
