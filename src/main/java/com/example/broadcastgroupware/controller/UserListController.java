package com.example.broadcastgroupware.controller;

import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.UserListDto;
import com.example.broadcastgroupware.mapper.UserListMapper;

@Controller
public class UserListController {
	private final UserListMapper userListMapper;
	
	public UserListController(UserListMapper userListMapper) {
		this.userListMapper = userListMapper;
	}
	
	
	@GetMapping("/user/userList")
	public String userList(@RequestParam(defaultValue = "1") int page,
						   @RequestParam(defaultValue = "10") int size,
						   @RequestParam(required = false) String q,
						   @RequestParam(required = false) String field,
						   Model model) {
		
		  // ---- 파라미터 정리 ----
        if (size <= 0) size = 10;
        if (page <= 0) page = 1;

        // field 정규화
        List<String> allow = Arrays.asList("all","name","dept","team","rank");
        if (field == null || !allow.contains(field)) field = "all";

        // ---- 카운트 / 페이지 계산 ----
        int totalRows = userListMapper.countUserList(q, field);
        int lastPage  = (totalRows == 0) ? 0 : (int)Math.ceil(totalRows / (double)size);

        if (lastPage > 0 && page > lastPage) page = lastPage;
        int offset = (page - 1) * size;

        // ---- 목록 ----
        List<UserListDto> rows = userListMapper.selectUserList(q, field, size, offset);
        
        PageDto p = new PageDto();
        p.setCurrentPage(page);
        p.setRowPerPage(size);
        model.addAttribute("page", p);

        // ---- 뷰 바인딩 ----
        model.addAttribute("rows", rows);
        model.addAttribute("q", q == null ? "" : q);
        model.addAttribute("field", field);      // 드롭다운/링크 유지용
        model.addAttribute("totalRows", totalRows);
        model.addAttribute("lastPage", lastPage);


        return "user/userList";
	}
	
	@GetMapping("/admin/adminUserList")
	public String adminUserList(@RequestParam(defaultValue = "1") int page,
						   @RequestParam(defaultValue = "10") int size,
						   @RequestParam(required = false) String q,
						   @RequestParam(required = false) String field,
						   Model model) {
		
		  // ---- 파라미터 정리 ----
        if (size <= 0) size = 10;
        if (page <= 0) page = 1;

        // field 정규화
        List<String> allow = Arrays.asList("all","name","dept","team","rank");
        if (field == null || !allow.contains(field)) field = "all";

        // ---- 카운트 / 페이지 계산 ----
        int totalRows = userListMapper.countUserList(q, field);
        int lastPage  = (totalRows == 0) ? 0 : (int)Math.ceil(totalRows / (double)size);

        if (lastPage > 0 && page > lastPage) page = lastPage;
        int offset = (page - 1) * size;

        // ---- 목록 ----
        List<UserListDto> rows = userListMapper.selectUserList(q, field, size, offset);

        // ---- 뷰 바인딩 ----
        
        PageDto p = new PageDto();
        p.setCurrentPage(page);
        p.setRowPerPage(size);
        model.addAttribute("page", p);
        
        
        model.addAttribute("rows", rows);
        model.addAttribute("q", q == null ? "" : q);
        model.addAttribute("field", field);      // 드롭다운/링크 유지용
        model.addAttribute("totalRows", totalRows);
        model.addAttribute("lastPage", lastPage);
        


        return "admin/adminUserList";
    }

}





