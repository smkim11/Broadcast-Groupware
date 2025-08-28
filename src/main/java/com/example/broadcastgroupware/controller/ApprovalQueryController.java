package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
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
}
