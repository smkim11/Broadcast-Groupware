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
	    this.totalCount = totalCount;
	    this.rowPerPage = rowPerPage;
	    this.searchWord = searchWord;
	    this.searchType = searchType;

	    // 전체 마지막 페이지
	    this.lastPage = (int) Math.ceil((double) totalCount / rowPerPage);
	    if(this.lastPage == 0) this.lastPage = 1;

	    // currentPage 제한
	    if (currentPage < 1) currentPage = 1;
	    if (currentPage > lastPage) currentPage = lastPage;
	    this.currentPage = currentPage;

	    // LIMIT 시작점
	    this.beginRow = (currentPage - 1) * rowPerPage;

	    // 현재 블럭 계산
	    int currentBlock = (currentPage - 1) / blockSize;
	    this.startPage = currentBlock * blockSize + 1;

	    // endPage 계산
	    this.endPage = Math.min(startPage + blockSize - 1, lastPage);

	    // 이전, 다음 여부 계산
	    this.hasPrev = (startPage > 1);
	    this.hasNext = (endPage < lastPage);
	}


}
