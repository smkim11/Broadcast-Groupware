package com.example.broadcastgroupware.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.UserListDto;
import com.example.broadcastgroupware.mapper.UserListMapper;

@Controller
@RequestMapping("/user")
public class UserListController {
	private final UserListMapper userListMapper;
	
	public UserListController(UserListMapper userListMapper) {
		this.userListMapper = userListMapper;
	}
	
	
	@GetMapping("/userList")
	public String userList(@RequestParam(defaultValue = "1") int page,
						   @RequestParam(defaultValue = "10") int size,
						   @RequestParam(required = false) String q,
						   Model model) {
		
		if (size <= 0) size = 10;
		
		// 총 행수
		int totalRows = userListMapper.countUserList(q);
		
		// 마지막 페이지 계산(빈 결과 시 1페이지 고정 방지)
		int lastPage = (int) Math.ceil(totalRows / (double) size);
		if (lastPage == 0) lastPage = 1;
		
		// page 보정
		if (page < 1) page = 1;
		if (page > lastPage) page = lastPage;
		
		// pageDto (주의 : totalPage 자리에 totlalRows를 넣고 있음)
		PageDto pageDto = new PageDto(page, size, totalRows, q);
		
		// 목록
		List<UserListDto> rows = userListMapper.selectUserList(q, size, pageDto.getBeginRow());
		
		model.addAttribute("rows", rows);
		model.addAttribute("page", pageDto);	// currentPage, rowPerPage, beginRow 등
		model.addAttribute("lastPage", pageDto.getLastPage());	// 계산식 있음
		model.addAttribute("totalRows", totalRows);
		model.addAttribute("q", q);
		
		return "user/userList";
	}
}





