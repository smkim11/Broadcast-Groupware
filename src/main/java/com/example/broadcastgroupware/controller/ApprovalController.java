package com.example.broadcastgroupware.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/approval")
public class ApprovalController {
	
	// 공통(일반) 문서 작성
    @GetMapping("/common/new")
    public String commonNew() {
        return "approval/commonForm";
    }

    // 휴가 문서 작성
    @GetMapping("/vacation/new")
    public String vacationNew() {
        return "approval/vacationForm";
    }

    // 방송 문서 작성
    @GetMapping("/broadcast/new")
    public String broadcastNew() {
        return "approval/broadcastForm";
    }
}
