package com.example.broadcastgroupware.rest;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.service.BroadcastService;

@RestController
@RequestMapping("/broadcast/team")
public class BroadcastRestController {

    private final BroadcastService broadcastService;

    public BroadcastRestController(BroadcastService broadcastService) {
        this.broadcastService = broadcastService;
    }

    // 프로그램별 팀원 목록
    @GetMapping("/list")
    public Map<String, Object> teamList(@RequestParam int scheduleId,
                                        @RequestParam(defaultValue = "1") int page,
                                        @RequestParam(defaultValue = "10") int size) {
        return broadcastService.getBroadcastTeamPage(scheduleId, page, size);
    }
    
    
    // 프로그램 팀원 등록
    @PostMapping("/add")
    public Map<String, Object> add(@RequestBody Map<String, Integer> body) {
        int scheduleId = body.getOrDefault("scheduleId", 0);
        int userId = body.getOrDefault("userId", 0);
        int result = broadcastService.addBroadcastTeam(scheduleId, userId);
        String message;
        int status = 200;
        if (result == 1) {
            message = "등록되었습니다.";
        } else if (result == -1) {
            message = "이미 등록된 팀원입니다.";
            status = 409;
        } else if (result == -2) {
            message = "정원을 초과할 수 없습니다.";
            status = 409;
        } else {
            message = "등록에 실패했습니다.";
            status = 500;
        }
        return Map.of("status", status, "message", message, "result", result);
    }

    
    // 프로그램 팀원 삭제
    @PostMapping("/delete")
    public Map<String, Object> delete(@RequestBody Map<String, List<Integer>> body) {
        List<Integer> ids = body.get("ids");
        int deleted = broadcastService.deleteBroadcastTeam(ids);
        return Map.of("deleted", deleted);
    }
}
