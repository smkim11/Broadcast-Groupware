package com.example.broadcastgroupware.controller;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ApprovalQueryService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/approval")
public class ApprovalQueryController {

    private final ApprovalQueryService approvalQueryService;

    public ApprovalQueryController(ApprovalQueryService approvalQueryService) {
        this.approvalQueryService = approvalQueryService;
    }

    // 공통적으로 세션에서 loginUser 주입
    @ModelAttribute("loginUser")
    public UserSessionDto loadLoginUser(HttpSession session) {
        return (UserSessionDto) session.getAttribute("loginUser");
    }

    // 진행 중 문서 목록 조회
    @GetMapping("/documents/in-progress")
    public String listInProgress(@ModelAttribute("loginUser") UserSessionDto loginUser, Model model) {
        model.addAttribute("docs", approvalQueryService.findInProgressDocuments(loginUser.getUserId()));
        return "approval/list_inprogress";
    }

    // 결재 완료 문서 목록 조회
    @GetMapping("/documents/completed")
    public String listCompleted(@ModelAttribute("loginUser") UserSessionDto loginUser, Model model) {
        model.addAttribute("docs", approvalQueryService.findCompletedDocuments(loginUser.getUserId()));
        return "approval/list_completed";
    }

    // 임시저장 문서 목록 조회
    @GetMapping("/documents/draft")
    public String listDraft(@ModelAttribute("loginUser") UserSessionDto loginUser, Model model) {
        model.addAttribute("docs", approvalQueryService.findDraftDocuments(loginUser.getUserId()));
        return "approval/list_draft";
    }

    // 내가 참조된 문서 목록 조회
    @GetMapping("/documents/referenced")
    public String listReferenced(@ModelAttribute("loginUser") UserSessionDto loginUser, Model model) {
        model.addAttribute("docs", approvalQueryService.findReferencedDocuments(loginUser.getUserId()));
        return "approval/list_referenced";
    }
    
    
    // 문서 상세 조회
    @GetMapping("/document/detail/{id}")
    public String documentDetail(@PathVariable("id") int approvalDocumentId,
                                 @ModelAttribute("loginUser") UserSessionDto loginUser,
                                 Model model) {

        Map<String, Object> bundle = approvalQueryService.getDetailPageModel(approvalDocumentId, loginUser.getUserId());
        if (bundle == null) {
            model.addAttribute("message", "문서를 찾을 수 없습니다.");
            return "error/404";
        }

        model.addAttribute("document", bundle.get("document"));
        model.addAttribute("broadcastForm", bundle.get("broadcastForm"));
        model.addAttribute("vacationForm", bundle.get("vacationForm"));
        model.addAttribute("approvalLines", bundle.get("approvalLines"));
        model.addAttribute("referenceLines", bundle.get("referenceLines"));  // 원본 개인 목록
        model.addAttribute("referenceTeams", bundle.get("referenceTeams"));  // 팀/개인 분리 목록
        model.addAttribute("referenceIndividuals", bundle.get("referenceIndividuals"));  // 팀/개인 분리 목록
        model.addAttribute("docType", bundle.get("docType"));
        model.addAttribute("isEditable", bundle.get("isEditable"));
        return "approval/document_detail";
    }
    
}
