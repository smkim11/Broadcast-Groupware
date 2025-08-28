package com.example.broadcastgroupware.rest;

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

}
