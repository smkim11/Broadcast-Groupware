package com.example.broadcastgroupware.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class ChatbotDto {
	private String id;
	private String module;				// 근태(나중에 휴가,공지사항 등등)
	private String title;				// 리스트 제목(ex: 근태 2025-08-27
	private String text;				// 미리보기(ex: 출근/퇴근/외근 시간 요약
	private String url;					// 상세보기 링크
	private String updatedAt;	// 정렬용 시간
}
