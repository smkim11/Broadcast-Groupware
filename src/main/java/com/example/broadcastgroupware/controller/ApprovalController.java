package com.example.broadcastgroupware.controller;

import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.UserMapper;
import com.example.broadcastgroupware.service.UserListService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/approval")
public class ApprovalController {
	private final UserMapper userMapper;
	private final UserListService userListService;

    public ApprovalController(UserMapper userMapper, UserListService userListService) {
        this.userMapper = userMapper;
        this.userListService = userListService; 
    }
    
    // 결재 화면 부서명 / 팀명 조회
    // 세션/인증정보에서 userId를 확보 -> 부서/팀 포함 DTO 조회 -> 세션/모델("loginUser")에 주입
    @ModelAttribute("loginUser")
    public UserSessionDto loadLoginUserDeptTeamInfo(HttpSession session, Authentication auth) {
    	// 1) 세션에 userId가 있으면 최우선 사용
    	Integer userId = (Integer) session.getAttribute("userId");

    	// 2) 세션의 loginUser(UserSessionDto 또는 User)에서 보강
        if (userId == null) {
            Object sess = session.getAttribute("loginUser");
            if (sess instanceof UserSessionDto dto && dto.getUserId() != 0) {
                userId = dto.getUserId();
            } else if (sess instanceof User u) {
                userId = u.getUserId();
            }
        }

        // 3) Authentication이 있으면 username으로 userId 최후 보강
        if (userId == null && auth != null) {
            String username = auth.getName();
            User user = userMapper.findByUsername(username);
            if (user != null) userId = user.getUserId();
        }

        // 4) userId 없으면 주입 불가 -> null 반환 (뷰에서는 값이 비어 보임)
        if (userId == null) return null;

        // 5) DB에서 부서/팀 포함 최신 DTO 조회하여 세션/모델에 주입
        UserSessionDto loginUser = userMapper.selectUserDeptTeamByUserId(userId);
        if (loginUser != null) {
            session.setAttribute("loginUser", loginUser);
        }
        return loginUser;
    }
	
    
	// 결재 문서 작성 메인 (문서 양식 선택)
    @GetMapping("/document/main")
    public String documentMain(Model model) {
        return "approval/document_main";
    }

    // 공통(일반) 문서 작성
    @GetMapping("/common/new")
    public String commonNew(Model model) {
        return "approval/document_common";
    }

    // 방송 문서 작성
    @GetMapping("/broadcast/new")
    public String broadcastNew(Model model) {
        return "approval/document_broadcast";
    }

    // 휴가 문서 작성
    @GetMapping("/vacation/new")
    public String vacationNew(Model model) {
        return "approval/document_vacation";       
    } 
    
    // 결재선 선택
    @GetMapping("/line/input")
    public String approvalLineInput(Model model) {
    	// 팀원(UserListService) 조직도 메서드 재사용
    	model.addAttribute("orgTree", userListService.getUserTreeForInvite());
        return "approval/line_input";
    }

    // 참조선 선택
    @GetMapping("/reference/input")
    public String referenceLineInput(Model model) {
    	// 팀원(UserListService) 조직도 메서드 재사용
    	model.addAttribute("orgTree", userListService.getUserTreeForInvite());
        return "approval/reference_input";
    }

}
