package com.example.broadcastgroupware.controller;

import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.service.BroadcastService;

@Controller
@RequestMapping("/broadcast")
public class BroadcastController {

    private final BroadcastService broadcastService;

    public BroadcastController(BroadcastService broadcastService) {
        this.broadcastService = broadcastService;
    }

    // 방송편성 목록 조회
    @GetMapping("/list")
    public String list(@RequestParam(required = false) String keyword,
                       @RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int size,
                       Model model) {

        Map<String, Object> data = broadcastService.getBroadcastList(keyword, page, size);
        model.addAllAttributes(data);
        return "broadcast/program_list";
    }
    
    // 방송편성 상세 조회
    @GetMapping("/detail/{scheduleId}")
    public String detail(@PathVariable int scheduleId, Model model,
    						RedirectAttributes ra) {
        BroadcastFormDto program = broadcastService.getBroadcastDetail(scheduleId);
        if (program == null) {
        	ra.addFlashAttribute("message", "방송편성을 찾을 수 없습니다.");
            return "redirect:/broadcast/list";
        }
        model.addAttribute("program", program);
        return "broadcast/program_detail";
    }

}
