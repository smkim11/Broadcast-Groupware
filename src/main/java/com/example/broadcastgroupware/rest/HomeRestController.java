package com.example.broadcastgroupware.rest;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.SessionAttribute; // 세션에서 loginUser 꺼낼 때 필요

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.FindPassword;
import com.example.broadcastgroupware.dto.PostDetailDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.mapper.ApprovalMapper;
import com.example.broadcastgroupware.mapper.AttendanceMapper;
import com.example.broadcastgroupware.mapper.BoardMapper;
import com.example.broadcastgroupware.mapper.BroadcastProgramMapper;
import com.example.broadcastgroupware.mapper.ReservationMapper;
import com.example.broadcastgroupware.mapper.VacationMapper;
import com.example.broadcastgroupware.service.LoginService;

import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api")
@Slf4j
public class HomeRestController {

    private final AttendanceMapper attendanceMapper;
    private final VacationMapper vacationMapper;
    private final ApprovalMapper approvalMapper;
    private final ReservationMapper reservationMapper;
    private final BoardMapper boardMapper;
    private final BroadcastMapper broadcastMapper;
    private final LoginService loginService;

    // 생성자 주입
	public HomeRestController(AttendanceMapper attendanceMapper, VacationMapper vacationMapper,
			ApprovalMapper approvalMapper, ReservationMapper reservationMapper, BoardMapper boardMapper,
			BroadcastProgramMapper broadcastProgramMapper, LoginService loginService) {
		this.attendanceMapper = attendanceMapper;
		this.vacationMapper = vacationMapper;
		this.approvalMapper = approvalMapper;
		this.reservationMapper = reservationMapper;
		this.boardMapper = boardMapper;
		this.broadcastProgramMapper = broadcastProgramMapper;
		this.loginService = loginService;
	}

    /**
     * 근태 요약 API
     * - 기본은 "세션의 로그인 사용자" 기준
     * - 관리자 화면에서 특정 유저를 보고 싶으면 ?userId=... 로 넘기면 됨
     */
    @GetMapping("/attendance/summary")
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
        int outsideCnt = toInt(c != null ? c.get("outside")    : null);   // 외근 일수

        // 4) JS가 기대하는 형태로 JSON 구성 (normalize()에서 그대로 먹음)
        Map<String, Object> body = Map.of(
                "days", days,
                "counts", Map.of("checkin", inCnt, "checkout", outCnt, "outside", outsideCnt),
                "today", Map.of(
                        "checkinTime",  in  != null ? in  : "--:--",
                        "checkoutTime", out != null ? out : "--:--",
                        "outsideTime",    fld
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
    
    // 휴가 현황
    // /api/vacation/home-summary
    @GetMapping("/vacation/home-summary")
    public ResponseEntity<Map<String,Object>> vacationHomeSummary(
        @RequestParam(required=false) Integer year,
        @RequestParam(required=false) Integer userId,
        @SessionAttribute(name="loginUser", required=false) UserSessionDto loginUser
    ) {
        int y = (year != null) ? year : java.time.Year.now().getValue();
        Integer target = (userId != null) ? userId
                         : (loginUser != null ? loginUser.getUserId() : null);
        if (target == null || target <= 0) return ResponseEntity.badRequest().build();

        Map<String,Object> p = new java.util.HashMap<>();
        p.put("userId", target);
        p.put("year", y);

        Map<String,Object> r = vacationMapper.selectVacationHomeSummary(p);
        if (r == null) r = java.util.Map.of("year", y, "total", 0, "remaining", 0, "approvalPending", 0);

        return ResponseEntity.ok(r);
    }
    
    // 문서현황
    @GetMapping("/docs/home-summary")
    public ResponseEntity<Map<String, Object>> docsHomeSummary(
            @SessionAttribute(name = "loginUser", required = false) UserSessionDto me) {

        if (me == null) return ResponseEntity.status(401).build();

        Map<String, Object> m = approvalMapper.selectHomeDocCounts(me.getUserId());
        int pending  = ((Number) (m.getOrDefault("pending", 0))).intValue();
        int progress = ((Number) (m.getOrDefault("progress", 0))).intValue();
        int done     = ((Number) (m.getOrDefault("done", 0))).intValue();

        return ResponseEntity.ok(Map.of(
                "counts", Map.of(
                        "PENDING",  pending,
                        "PROGRESS", progress,
                        "DONE",     done
                )
        ));
    }
    
    // 예약 현황
    @GetMapping("/reservations/home-summary")
    public ResponseEntity<Map<String, Object>> reservationsHomeSummary(
            @SessionAttribute(name = "loginUser", required = false) UserSessionDto me
            /* @RequestParam(name="days", required=false) Integer days  // 받아도 무시 */) {

        if (me == null) return ResponseEntity.status(401).build();

        Map<String, Object> m = reservationMapper.selectHomeReservationTotals(me.getUserId());
        int meeting = ((Number)((m != null) ? m.getOrDefault("meeting", 0) : 0)).intValue();
        int edit    = ((Number)((m != null) ? m.getOrDefault("edit",    0) : 0)).intValue();
        int vehicle = ((Number)((m != null) ? m.getOrDefault("vehicle", 0) : 0)).intValue();

        // JS는 totals.MEETING / totals.EDIT / totals.VEHICLE 를 읽습니다.
        return ResponseEntity.ok(Map.of(
            "totals", Map.of(
                "MEETING", meeting,
                "EDIT",    edit,
                "VEHICLE", vehicle
            )
        ));
    }
    
    // 공지사항
    // 누적 TopN: /api/notices/home-top?limit=4&boardId=1
    @GetMapping("/notices/home-top")
    public List<PostDetailDto> homeTop(@RequestParam(defaultValue = "4") int limit,
                                       @RequestParam(required = false) Integer boardId){
        int safe = (limit <= 0 || limit > 10) ? 4 : limit;
        return boardMapper.selectHomeTopPosts(safe, boardId);
    }
    
    // 방송편성
    // 홈 카드: /api/broadcasts/home-top?limit=4
    @GetMapping("/broadcasts/home-top")
    public List<BroadcastFormDto> homeTop(@RequestParam(defaultValue = "4") int limit){
        int safe = (limit <= 0 || limit > 10) ? 4 : limit;
        return broadcastProgramMapper.selectHomeTopBroadcasts(safe);
    }
    
    // 비밀번호 찾기
    @PostMapping("/find/password")
    public Map<String, String> findPassword(@RequestBody FindPassword userInfo) {
        log.info("raw userInfo: {}", userInfo);
        log.info("사원번호: {}", userInfo.getUsername());
        log.info("생년월일: {}", userInfo.getUserSn1());

        try {
            int username = Integer.parseInt(userInfo.getUsername());
            loginService.findPassword(username, userInfo.getUserSn1());

            return Map.of("status", "success", "message", "임시 비밀번호 메일 발송 완료!");
        } catch (NumberFormatException e) {
            log.error("사원번호 변환 실패", e);
            return Map.of("status", "error", "message", "잘못된 사원번호입니다.");
        } catch (Exception e) {
            log.error("비밀번호 찾기 처리 실패", e);
            return Map.of("status", "error", "message", "서버 오류 발생. 관리자에게 문의하세요.");
        }
    }
    
}
