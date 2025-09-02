package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ApprovalProcessService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/approval")
public class ApprovalProcessController {

    private final ApprovalProcessService approvalProcessService;

    public ApprovalProcessController(ApprovalProcessService approvalProcessService) {
        this.approvalProcessService = approvalProcessService;
    }

    @ModelAttribute("loginUser")
    public UserSessionDto loadLoginUser(HttpSession session) {
        return (UserSessionDto) session.getAttribute("loginUser");
    }
    
    // JSP 폼 전용 결재 처리 (승인/반려) -> 처리 후 상세로 리다이렉트
    @PostMapping("/document/decide-web")
    public String decideWeb(@RequestParam int documentId, @RequestParam String decision,  // APPROVE | REJECT
                            @RequestParam(required = false) String comment,
                            @ModelAttribute("loginUser") UserSessionDto loginUser,
                            RedirectAttributes ra, HttpSession session) {
        if (loginUser == null) {
            ra.addFlashAttribute("error", "로그인이 필요합니다.");
            return "redirect:/login";
        }
        
        try {
        	// 실제 결재(승인/반려) 처리 로직 실행
            approvalProcessService.decide(documentId, loginUser.getUserId(), decision, comment);
            ra.addFlashAttribute("message",
                    "APPROVE".equalsIgnoreCase(decision) ? "승인 완료" : "반려 완료");
        } catch (IllegalArgumentException | IllegalStateException e) {
            ra.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
            ra.addFlashAttribute("error", "결재 처리 중 오류가 발생했습니다.");
        }
        return "redirect:/approval/document/detail/" + documentId;
    }
      
}
