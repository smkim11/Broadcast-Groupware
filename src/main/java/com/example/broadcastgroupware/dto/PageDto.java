package com.example.broadcastgroupware.dto;

import lombok.Data;

@Data
public class PageDto {
	private int currentPage;
	private int rowPerPage;
	private int beginRow;
	private int totalPage;
	private String searchWord;
	private String type;
	private String startDateTime;
	private String endDateTime;
	private String searchType;
	
	// 검색 없는 페이징
	public PageDto(int currentPage, int rowPerPage, int totalPage){
	 		this.rowPerPage = rowPerPage;
	 		this.currentPage = currentPage;
			this.totalPage = totalPage;
			this.beginRow = (currentPage-1)*rowPerPage;
	 }
	
	// 검색 있는 페이징
	public PageDto(int currentPage, int rowPerPage, int totalPage, String searchWord){
 		this.rowPerPage = rowPerPage;
		this.currentPage = currentPage;
		this.totalPage = totalPage;
		this.searchWord = searchWord;
		this.beginRow = (currentPage-1)*rowPerPage;
	}
	
	// 마지막 페이지
	public int getLastPage() {
		int lastPage = this.totalPage / this.rowPerPage;
		if(this.totalPage % this.rowPerPage != 0) {
			lastPage++;
		}
		return lastPage;
	}
	
	// 예약 페이징
	public PageDto(int currentPage, int rowPerPage, int totalPage, 
					String type, String startDateTime, String endDateTime) {
		this.rowPerPage = rowPerPage;
 		this.currentPage = currentPage;
		this.totalPage = totalPage;
		this.beginRow = (currentPage-1)*rowPerPage;
		this.type = type;
		this.startDateTime = startDateTime;
		this.endDateTime = endDateTime;
	}
}
