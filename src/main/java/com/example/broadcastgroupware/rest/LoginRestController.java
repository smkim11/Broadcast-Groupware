package com.example.broadcastgroupware.rest;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

// 세션이 살아있을 때만 의미가 있음
// 아무 일도 안 해도 엔드포인트에 도달하는 순간 lastAccessedTime이 갱신됨
@RestController
public class LoginRestController {
    @GetMapping("/session/ping")
    public ResponseEntity<String> ping() {
        return ResponseEntity.ok("ok");
    }
}
