package com.example.broadcastgroupware.controller;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.ApprovalQueryMapper;
import com.example.broadcastgroupware.service.ApprovalQueryService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/approval")
public class ApprovalProcessController {

    private final ApprovalQueryService approvalQueryService;
    private final ApprovalQueryMapper approvalQueryMapper;

    public ApprovalProcessController(ApprovalQueryService approvalQueryService,
                                      ApprovalQueryMapper approvalQueryMapper) {
        this.approvalQueryService = approvalQueryService;
        this.approvalQueryMapper = approvalQueryMapper;
    }

    @ModelAttribute("loginUser")
    public UserSessionDto loadLoginUser(HttpSession session) {
        return (UserSessionDto) session.getAttribute("loginUser");
    }

    // 결재 전용 화면
    @GetMapping("/document/approve/{id}")
    public String approvePage(@PathVariable("id") int documentId,
                              @ModelAttribute("loginUser") UserSessionDto loginUser,
                              Model model) {
        Map<String, Object> bundle = approvalQueryService.getDocumentDetailBundle(documentId);
        if (bundle == null) {
            model.addAttribute("message", "문서를 찾을 수 없습니다.");
            return "error/404";
        }

        // 접근 권한 계산: 현재 대기 차수 == 내 차수 && 내 상태 == '대기'
        Integer currentSeq = approvalQueryMapper.selectCurrentPendingSequence(documentId);
        Map<String, Object> myLine = approvalQueryMapper.selectUserApprovalLine(documentId, loginUser.getUserId());
        boolean canApprove = false;
        if (currentSeq != null && myLine != null) {
            Integer mySeq = (Integer) myLine.get("approvalLineSequence");
            String myStatus = (String) myLine.get("approvalLineStatus");
            canApprove = "대기".equals(myStatus) && currentSeq.equals(mySeq);
        }
        
        model.addAttribute("document", bundle.get("document"));
        model.addAttribute("broadcastForm", bundle.get("broadcastForm"));
        model.addAttribute("vacationForm", bundle.get("vacationForm"));
        model.addAttribute("approvalLines", bundle.get("approvalLines"));  // signatureUrl 포함
        model.addAttribute("canApprove", canApprove);
        return "approval/document_approve";
    }
}
