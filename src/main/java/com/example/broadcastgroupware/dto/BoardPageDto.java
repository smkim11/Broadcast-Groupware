package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class BoardPageDto {
	private int currentPage;   // 현재 페이지
	private int rowPerPage;    // 페이지당 글 수
	private int beginRow;      // LIMIT 시작점
	private int totalCount;    // 전체 글 수
	private String searchWord;
	private String searchType;

	// 블럭 페이징
	private int startPage;     // 현재 블럭 시작 페이지
	private int endPage;       // 현재 블럭 끝 페이지
	private int lastPage;      // 전체 마지막 페이지
	private int blockSize = 5; // 블럭 크기 (5개씩)

	// 이전/다음 여부
	private boolean hasPrev;
	private boolean hasNext;

	// 생성자
	public BoardPageDto(int currentPage, int rowPerPage, int totalCount, String searchWord, String searchType){
		this.currentPage = currentPage;
		this.rowPerPage = rowPerPage;
		this.totalCount = totalCount;
		this.searchWord = searchWord;
		this.searchType = searchType;

		// LIMIT 시작점
		this.beginRow = (currentPage - 1) * rowPerPage;

		// 전체 마지막 페이지
		this.lastPage = (int) Math.ceil((double) totalCount / rowPerPage);

		// 현재 블럭 계산
		int currentBlock = (currentPage - 1) / blockSize;
		this.startPage = currentBlock * blockSize + 1;
		this.endPage = Math.min(startPage + blockSize - 1, lastPage);

		// 이전, 다음 여부 계산
		this.hasPrev = (startPage > 1);
		this.hasNext = (endPage < lastPage);
	}

}
