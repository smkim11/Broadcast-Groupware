package com.example.broadcastgroupware.rest;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import org.springframework.web.bind.annotation.SessionAttribute; // 세션에서 loginUser 꺼낼 때 필요

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.AttendanceMapper;

@RestController
@RequestMapping("/api/attendance")
public class HomeRestController {

    private final AttendanceMapper attendanceMapper;

    // 생성자 주입 (스프링이 AttendanceMapper를 넣어줌)
    public HomeRestController(AttendanceMapper attendanceMapper) {
        this.attendanceMapper = attendanceMapper;
    }

    /**
     * 근태 요약 API
     * - 기본은 "세션의 로그인 사용자" 기준
     * - 관리자 화면에서 특정 유저를 보고 싶으면 ?userId=... 로 넘기면 됨
     */
    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> summary(
            @RequestParam(defaultValue = "30") int days,                 // 최근 N일
            @RequestParam(required = false) Integer userId,              // (선택) 관리자용: 특정 사용자
            @SessionAttribute(name = "loginUser", required = false) UserSessionDto loginUser // 세션에서 꺼냄
    ) {
        // 1) 조회 대상 userId 결정: 파라미터 > 세션(loginUser)
        Integer target = (userId != null) ? userId
                         : (loginUser != null ? loginUser.getUserId() : null);

        // 대상이 없으면 400(잘못된 요청) 반환
        if (target == null || target <= 0) {
            return ResponseEntity.badRequest().build();
        }

        // 2) 오늘 시각(출근/퇴근/외근) - 기존 XML + 도메인 Attendance 그대로 사용
        Attendance a = attendanceMapper.selectUserAttendance(target);
        String in  = toHHmm(a != null ? a.getAttendanceIn()      : null); // "09:12"
        String out = toHHmm(a != null ? a.getAttendanceOut()     : null); // "18:03"
        String fld = toHHmm(a != null ? a.getAttendanceOutside() : null); // "14:10"
        if (fld == null) fld = "-"; // 외근 기록이 없으면 "-"

        // 3) 최근 N일 카운트 - DB에서 한번에 집계 (XML에 쿼리 1개 추가 필요)
        Map<String, Object> c = attendanceMapper.selectCountsInDays(target, days);
        int inCnt    = toInt(c != null ? c.get("checkin")  : null);   // 출근 일수
        int outCnt   = toInt(c != null ? c.get("checkout") : null);   // 퇴근 일수
        int fieldCnt = toInt(c != null ? c.get("field")    : null);   // 외근 일수

        // 4) JS가 기대하는 형태로 JSON 구성 (normalize()에서 그대로 먹음)
        Map<String, Object> body = Map.of(
                "days", days,
                "counts", Map.of("checkin", inCnt, "checkout", outCnt, "field", fieldCnt),
                "today", Map.of(
                        "checkinTime",  in  != null ? in  : "--:--",
                        "checkoutTime", out != null ? out : "--:--",
                        "fieldTime",    fld
                )
        );

        return ResponseEntity.ok(body);
    }

    // ── 아래는 초보자용 유틸 함수 ─────────────────────────────────────────────

    // 숫자 안전 변환 (null -> 0)
    private static int toInt(Object v) {
        return (v == null) ? 0 : ((Number) v).intValue();
    }

    // 시간 문자열을 "HH:mm"으로 맞추기
    // 예) "2025-09-02 09:12:34" → "09:12", "09:12:34" → "09:12", "09:12" → "09:12"
    private static String toHHmm(String s) {
        if (s == null || s.isBlank()) return null;
        String t = s.trim();
        // 끝에 "HH:mm:ss" 형태가 있으면 그걸 사용
        if (t.length() >= 8 && t.contains(":")) {
            String tail8 = t.substring(t.length() - 8); // e.g. "09:12:34"
            if (tail8.charAt(2) == ':' && tail8.charAt(5) == ':') {
                return tail8.substring(0, 5);           // "09:12"
            }
        }
        // 이미 "HH:mm" 이면 그대로
        return t.length() >= 5 ? t.substring(0, 5) : t;
    }
}
