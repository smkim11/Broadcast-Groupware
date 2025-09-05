package com.example.broadcastgroupware.service;

import java.security.SecureRandom;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.mapper.LoginMapper;

@Service
public class LoginService {

	private final LoginMapper loginMapper;
	private final JavaMailSender mailSender; // 메일 전송기

	public LoginService(LoginMapper loginMapper, JavaMailSender mailSender) {
		this.loginMapper = loginMapper;
		this.mailSender = mailSender;
	}

	// 비밀번호 찾기
	@Transactional
	public boolean findPassword(int username, String sn1) {
		// 이메일 조회
		String email = loginMapper.findEmail(username, sn1);
		if (email == null || email.isBlank()) {
			 return false; // ★ 예외 던지지 않음
		}

		// 랜덤 8자리 비밀번호 생성
		String newPassword = generateRandomPassword();

		// DB 업데이트
		loginMapper.updateNewPassword(username, newPassword); 

		// 이메일 전송
		SimpleMailMessage message = new SimpleMailMessage();
		message.setTo(email);
		message.setSubject("임시 비밀번호 안내");
		message.setText(String.format(
			    "새로운 임시 비밀번호는 다음과 같습니다:%n%s%n%n로그인 후 비밀번호를 변경하세요.",
			    newPassword
			));
		mailSender.send(message);
		return true;
	}

	// 랜덤 비밀번호 생성 메서드
	private String generateRandomPassword() {
		String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
		SecureRandom random = new SecureRandom();
		StringBuilder sb = new StringBuilder();
		for (int i = 0; i < 8; i++) {
			int index = random.nextInt(chars.length());
			sb.append(chars.charAt(index));
		}
		return sb.toString();
	}
}

