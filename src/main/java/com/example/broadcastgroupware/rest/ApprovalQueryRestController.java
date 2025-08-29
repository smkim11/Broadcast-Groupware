package com.example.broadcastgroupware.rest;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.service.ApprovalQueryService;

@RestController
@RequestMapping("/approval")
public class ApprovalQueryRestController {
    private final ApprovalQueryService approvalQueryService;

    public ApprovalQueryRestController(ApprovalQueryService approvalQueryService) {
        this.approvalQueryService = approvalQueryService;
    }
    
    // 문서 상세 조회
    @GetMapping("/documents/{id}")
    public ResponseEntity<?> getDocumentDetail(@PathVariable("id") int approvalDocumentId) {
        Map<String, Object> bundle = approvalQueryService.getDocumentDetailBundle(approvalDocumentId);
        if (bundle == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(bundle);
    }

}
