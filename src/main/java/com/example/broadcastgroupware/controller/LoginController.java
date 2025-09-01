package com.example.broadcastgroupware.controller;

import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class LoginController {
	
	@GetMapping({"/login", "/"})
	public String login(HttpServletRequest req) {
	    HttpSession s = req.getSession(false);
	    if (s != null) {
	        s.setAttribute("LOCKED", false);
	    }
	    return "login";
    }
	
	  // 잠금 화면
	  @GetMapping("/lock")
	  public String lock(@RequestParam(value = "from", required = false) String from,
	                     Authentication auth,
	                     HttpServletRequest req,
	                     HttpSession session) {
	    // 비로그인 상태면 로그인 화면으로
	    boolean authed = auth != null && auth.isAuthenticated() && !(auth instanceof AnonymousAuthenticationToken);
	    if (!authed) return "redirect:/login";

	    if ("timeout".equals(from)) {            // 타임아웃으로 온 경우만 잠금 ON
	        session.setAttribute("LOCKED", true);
	      }
	      return "lock";
	    }

	  // 잠금 해제(비밀번호 검증 없이)
	  @PostMapping("/unlock")
	  public String unlock(@RequestParam String password, HttpServletRequest req) {
		  // 비밀번호 검증 로직…
		  req.getSession().setAttribute("LOCKED", false);
		  return "redirect:/home";
	  }
}
