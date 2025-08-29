package com.example.broadcastgroupware.service;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.User;
import com.example.broadcastgroupware.domain.UserImages;
import com.example.broadcastgroupware.dto.MyPageDto;
import com.example.broadcastgroupware.mapper.MyPageMapper;

import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
public class MyPageService {
	private MyPageMapper myPageMapper;
	public MyPageService(MyPageMapper myPageMapper) {
		this.myPageMapper=myPageMapper;
	}
	
	// 마이페이지
	public MyPageDto userInfo(int userId) {
		return myPageMapper.userInfo(userId);
	}
	
	// 서명등록
	public String addSign(UserImages userImages) {
	    // 0) 확장자 추출 (data:image/png;base64,...)
	    String base64Data = userImages.getUserImagesName();
	    String ext = base64Data.substring(base64Data.indexOf("/") + 1, base64Data.indexOf(";")); // png, jpg 등
	    
	    // 1) 랜덤 파일명 생성
	    String filename = UUID.randomUUID().toString().replace("-", "");

	    // 2) 저장 경로 지정
	    String savePath = "c:\\final\\"; 
	    File file = new File(savePath + filename+ "." + ext);

	    // 3) 디코딩해서 파일 저장
	    try (FileOutputStream fos = new FileOutputStream(file)) {
	        fos.write(Base64.getDecoder().decode(base64Data.split(",")[1]));
	    } catch (IOException e) {
	        throw new RuntimeException("파일 저장 실패", e);
	    }

	    // 4) UserImages 객체에 값 채우기
	    userImages.setUserImagesType("서명");
	    userImages.setUserImagesName(filename); // 파일명
	    userImages.setUserImagesExt(ext);
	    userImages.setUserImagesPath(savePath);
	    
	    // DB에 저장
	    myPageMapper.insertUserSign(userImages);

	    return filename;
	}
	
	// 정보수정
	public void updateMyPage(User user) {
		myPageMapper.updateMyPage(user);
	}
}
