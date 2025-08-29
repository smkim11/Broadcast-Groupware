package com.example.broadcastgroupware.rest;

import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.domain.UserImages;
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
}
