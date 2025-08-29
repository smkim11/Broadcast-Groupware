package com.example.broadcastgroupware.rest;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ApprovalProcessService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/approval")
public class ApprovalProcessRestController {

    private final ApprovalProcessService approvalProcessService;

    public ApprovalProcessRestController(ApprovalProcessService approvalProcessService) {
        this.approvalProcessService = approvalProcessService;
    }

    // 결재 (승인/반려)
    @PostMapping("/document/decide")
    public ResponseEntity<?> decide(@RequestParam("documentId") int documentId,
                                    @RequestParam("decision") String decision,  // APPROVE | REJECT
                                    @RequestParam(value = "comment", required = false) String comment,
                                    HttpSession session) {
        UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "로그인이 필요합니다."));
        }

        try {
            approvalProcessService.decide(documentId, loginUser.getUserId(), decision, comment);
            return ResponseEntity.ok(Map.of("result", "OK"));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (IllegalStateException e) {
            // 차수가 아닌 경우 등
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("error", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "결재 처리 중 오류가 발생했습니다."));
        }
    }
}
