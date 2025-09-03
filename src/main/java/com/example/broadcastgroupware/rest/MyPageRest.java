package com.example.broadcastgroupware.rest;

import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.domain.UserImages;
import com.example.broadcastgroupware.dto.PasswordDto;
import com.example.broadcastgroupware.service.MyPageService;


@RestController
public class MyPageRest {
	private MyPageService myPageService;
	public MyPageRest(MyPageService myPageService) {
		this.myPageService=myPageService;
	}
	// 서명 추가
	@PostMapping("/addSign")
	public String addSign(UserImages userImages) {
		System.out.println(userImages.toString());
		// service 통해서 이미지 저장 - mapper 통해서 db저장
		return myPageService.addSign(userImages);
	}
	
	// 정보 수정
	@PatchMapping("/updateMyPage")
	public void updateMyPage(@RequestBody User user) {
		myPageService.updateMyPage(user);
	}
	
	// 비밀번호 수정
	@PatchMapping("/updatePassword")
	public String updatePassword(@RequestBody PasswordDto passwordDto) {
		int userId = passwordDto.getUserId();
		if(!myPageService.findPw(userId).equals(passwordDto.getPrevPw())) {
			return "기존 비밀번호를 틀렸습니다.";
		}else if(!passwordDto.getNewPw().equals(passwordDto.getNewPw2())) {
			return "변경 비밀번호가 일치하지 않습니다.";
		}else if(myPageService.findPrevPw(userId).equals(passwordDto.getNewPw())) {
			return "직전에 사용한 비밀번호입니다.";
		}else if(!passwordDto.getNewPw().matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,13}$")) {
		    return "비밀번호는 8~13자이며, 숫자·문자·특수문자를 포함해야 합니다.";
		}
		
		myPageService.updatePassword(passwordDto);
		return "변경성공";
	}
}
