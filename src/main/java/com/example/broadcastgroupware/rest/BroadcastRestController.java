package com.example.broadcastgroupware.rest;

import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute;

import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.BroadcastService;

@RestController
@RequestMapping("/broadcast")
public class BroadcastRestController {

    private final BroadcastService broadcastService;

    public BroadcastRestController(BroadcastService broadcastService) {
        this.broadcastService = broadcastService;
    }

    // 프로그램별 팀원 목록
    @GetMapping("/team/list")
    public Map<String, Object> teamList(@RequestParam int scheduleId,
                                        @RequestParam(defaultValue = "1") int page,
                                        @RequestParam(defaultValue = "10") int size) {
        return broadcastService.getBroadcastTeamPage(scheduleId, page, size);
    }
    
    
    // 프로그램 팀원 등록
    @PostMapping("/team/add")
    public Map<String, Object> add(@RequestBody Map<String, Integer> body,
                                   @SessionAttribute(value = "loginUser", required = false) UserSessionDto loginUser) {
        int scheduleId = body.getOrDefault("scheduleId", 0);
        int userId = body.getOrDefault("userId", 0);
        int loginUserId = (loginUser != null) ? loginUser.getUserId() : 0;  // 세션 없으면 0

        int result = broadcastService.addBroadcastTeam(scheduleId, userId, loginUserId);
        
        String message;
        int status;
        switch (result) {
            case 1: message = "등록되었습니다."; status = 200; break;
            case -1: message = "이미 등록된 팀원입니다."; status = 409; break;
            case -2: message = "정원을 초과할 수 없습니다."; status = 409; break;
            case -3: message = "등록 권한이 없습니다."; status = 403; break;
            default: message = "등록에 실패했습니다."; status = 500; break;
        }
        return Map.of("status", status, "message", message, "result", result);
    }
    
    
    // 부서 목록 (드롭다운)
    @GetMapping("/departments")
    public List<com.example.broadcastgroupware.domain.Department> departments() {
        return broadcastService.listDepartments();
    }

    // 부서별 팀 목록 (드롭다운)
    @GetMapping("/teams")
    public List<com.example.broadcastgroupware.domain.Team> teams(@RequestParam int departmentId) {
        return broadcastService.listTeamsByDepartment(departmentId);
    }

    // 등록 가능 사용자 목록 (드롭다운)
    @GetMapping("/assignable-users")
    public List<com.example.broadcastgroupware.dto.UserRowDto> assignableUsers(@RequestParam int scheduleId,
                                                                               @RequestParam int teamId) {
        return broadcastService.listAssignableUsersByTeam(scheduleId, teamId);
    }

    
    // 프로그램 팀원 삭제
    @PostMapping("/team/delete")
    public Map<String, Object> delete(@RequestBody Map<String, List<Integer>> body) {
        List<Integer> ids = body.get("ids");
        int deleted = broadcastService.deleteBroadcastTeam(ids);
        return Map.of("deleted", deleted);
    }
    
    
    // 회차 목록
    @GetMapping("/episodes/list")
    public Map<String, Object> list(@RequestParam int scheduleId,
                                    @RequestParam(defaultValue = "1") int page,
                                    @RequestParam(defaultValue = "10") int size) {
        return broadcastService.getEpisodeList(scheduleId, page, size);
    }
    
    // 회차 소제목 / 회차 설명 (코멘트) 수정
    @PostMapping("/episodes/comment")
    public Map<String, Object> updateEpisodeComment(@RequestBody Map<String, Object> body) {
        int episodeId = (int) body.getOrDefault("episodeId", 0);
        String comment = (String) body.getOrDefault("comment", null);
        
        int updated = broadcastService.updateEpisodeComment(episodeId, comment);
        
        int status = updated == 1 ? 200 : 500;
        String message = updated == 1 ? "저장되었습니다." : "저장에 실패했습니다.";
        
        return Map.of("status", status, "message", message, "updated", updated);
    }

}
