package com.example.broadcastgroupware.controller;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.example.broadcastgroupware.domain.UserImages;
import com.example.broadcastgroupware.dto.MyPageDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.UserMapper;
import com.example.broadcastgroupware.service.MyPageService;

import jakarta.servlet.http.HttpSession;

@Controller
public class MyPageController {
	private MyPageService myPageService;
	private final UserMapper userMapper;
	
	  public MyPageController(MyPageService myPageService,
              				  UserMapper userMapper) {     
		this.myPageService = myPageService;
		this.userMapper = userMapper;
		}
	
	@GetMapping("/myPage")
	public String myPage(Model model, HttpSession session) {
	    UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
	    if (loginUser == null) {
	        return "redirect:/login"; // 로그인 안 했으면 로그인 페이지로
	    }
	    MyPageDto mpd = myPageService.userInfo(loginUser.getUserId());
	    if(mpd.getProfile()==null) {
	    	mpd.setProfile("defaultProfile.png");
	    }
	    
	    System.out.println(mpd);
	    model.addAttribute("myInfo",mpd);
	    return "user/myPage";
	}
	
	@PostMapping("/addProfile")
	public String addProfile(@RequestParam("file") MultipartFile file, HttpSession session) {
	    UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
	    int userId = loginUser.getUserId();
	    
	    UserImages userImages = new UserImages();
	    if (file != null && !file.isEmpty()) {
	        // 확장자 추출
	        String ext = file.getOriginalFilename()
	                         .substring(file.getOriginalFilename().lastIndexOf(".") + 1);

	        // 저장 파일명 (UUID)
	        String fileName = UUID.randomUUID().toString().replace("-", "");

	        // 저장 경로
	        String savaPath = "c:\\final\\";
	        String fullPath = savaPath + fileName + "." + ext;
	        File saveFile = new File(fullPath);

	        try {
	            file.transferTo(saveFile);
	        } catch (IllegalStateException | IOException e) {
	            e.printStackTrace();
	        }
	        
	        
	        userImages.setUserId(userId);
	        userImages.setUserImagesType("프로필");
	        userImages.setUserImagesName(fileName);
	        userImages.setUserImagesExt(ext);
	        userImages.setUserImagesPath(savaPath);
	    }
	    myPageService.addProfile(userImages);
	    
        // 2) ★ 저장 직후, 표시용 URL/버전 조회 → 세션 갱신 (핵심!)
        Map<String, Object> p = userMapper.selectProfileInfo(userId); // {url, ver}
        String url = p != null ? (String) p.get("url") : null;
        String ver = (p != null && p.get("ver") != null) ? String.valueOf(p.get("ver")) : null;

        loginUser.setProfileUrl(url);
        loginUser.setProfileVer(ver);
        session.setAttribute("loginUser", loginUser);
	    
	    return "redirect:/myPage";
	}
}
