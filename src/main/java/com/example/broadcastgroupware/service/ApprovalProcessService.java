package com.example.broadcastgroupware.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.BroadcastEpisode;
import com.example.broadcastgroupware.domain.BroadcastSchedule;
import com.example.broadcastgroupware.mapper.ApprovalMapper;
import com.example.broadcastgroupware.mapper.ApprovalQueryMapper;
import com.example.broadcastgroupware.mapper.BroadcastMapper;

@Service
public class ApprovalProcessService {
    private final ApprovalMapper approvalMapper;
    private final ApprovalQueryMapper approvalQueryMapper;
    private final VacationService vacationService;
    private final BroadcastMapper broadcastMapper;

    public ApprovalProcessService(ApprovalMapper approvalMapper, ApprovalQueryMapper approvalQueryMapper,
    								VacationService vacationService, BroadcastMapper broadcastMapper) {
        this.approvalMapper = approvalMapper;
        this.approvalQueryMapper = approvalQueryMapper;
        this.vacationService = vacationService;
        this.broadcastMapper = broadcastMapper;
    }

    // 결재 처리 (승인/반려)
    @Transactional
    public void decide(int documentId, int userId, String decision, String comment) {
        // 1) 현재 '대기' 차수 확인 & 사용자의 결재선 검증
        Integer currentSeq = approvalQueryMapper.selectCurrentPendingSequence(documentId);
        Map<String, Object> myLine = approvalQueryMapper.selectUserApprovalLine(documentId, userId);
        
        if (currentSeq == null || myLine == null) throw new IllegalStateException("결재할 수 있는 상태가 아닙니다.");

        Integer mySeq = (Integer) myLine.get("approvalLineSequence");
        String myStatus = (String) myLine.get("approvalLineStatus");
        
        if (!"대기".equals(myStatus) || !currentSeq.equals(mySeq)) {
            throw new IllegalStateException("현재 결재 차수가 아닙니다.");
        }

        // 2) 요청값 -> 시스템 상태값으로 변환
        String targetStatus = switch (decision.toUpperCase()) {
            case "APPROVE" -> "승인";
            case "REJECT" -> "반려";
            default -> throw new IllegalArgumentException("invalid decision");
        };
        
        // 3) 승인 시: 사용자의 최신 서명을 문서별 폴더에 복사
        if ("승인".equals(targetStatus)) {
        	saveApprovalSignature(documentId, userId);
        }

        // 4) 결재선 상태/코멘트 갱신
        int updated = approvalMapper.updateMyApprovalLineDecision(documentId, userId, targetStatus, comment);
        if (updated == 0) throw new IllegalStateException("결재 업데이트에 실패했습니다.");
        
        // 5) 다음 차수 활성화 / 문서 최종 상태 반영
        if ("승인".equals(targetStatus)) {
            Integer nextSeq = approvalQueryMapper.selectNextSequenceToActivate(documentId);  // 다음 NULL 차수
            if (nextSeq != null) {
                approvalMapper.activateNextApprover(documentId, nextSeq);  // 다음 결재자 '대기'
                approvalMapper.updateDocumentStatus(documentId, "진행 중");
            } else {
                approvalMapper.updateDocumentStatus(documentId, "승인");    // 최종 승인
                
                // 휴가 문서라면: 휴가 이력 저장 + 사용일 누적
                if (isVacationDoc(documentId)) {
                    Integer myApprovalLineId = (Integer) myLine.get("approvalLineId");

                    // 휴가 일수 계산 (반차=0.5, 그 외 = 시작~종료 일수 기준)
                    Map<String, Object> vf = approvalQueryMapper.selectVacationFormDetail(documentId);
                    double dayCount = computeVacationDays(vf);  // 아래 메서드 참고

                    // 휴가 이력 등록 + 사용일 업데이트
                    vacationService.applyApprovedVacation(documentId, myApprovalLineId, dayCount);
                }
                              
                // 방송 문서라면: 편성/회차 자동 생성
                autoCreateScheduleAndEpisodes(documentId, userId);  // 아래 메서드 참고
            
            }
        } else {
            approvalMapper.updateDocumentStatus(documentId, "반려");
        }
    }
        

    // ===== 휴가 문서인 경우 =====
    
    // 휴가 문서 여부
    private boolean isVacationDoc(int documentId) {
    	Map<String, Object> vf = approvalQueryMapper.selectVacationFormDetail(documentId);
    	return vf != null && !vf.isEmpty();
    }
    
    // 휴가 사용일수 계산: 반차=0.5, 그 외 = 날짜 차이 + 1
    private double computeVacationDays(Map<String, Object> vf) {
    	// 휴가 유형 조회: '반차'면 0.5일 처리
    	String type = String.valueOf(vf.getOrDefault("vacationFormType", "")).trim();
    	if ("반차".equals(type)) return 0.5;
    	
    	// 시작일~종료일 포함 휴가 일수 계산
    	String s = String.valueOf(vf.get("vacationFormStartDate"));
    	String e = String.valueOf(vf.get("vacationFormEndDate"));
    	LocalDate start = LocalDate.parse(s);
    	LocalDate end = LocalDate.parse(e);
    	
    	long days = ChronoUnit.DAYS.between(start, end) + 1;
    	return (double) days;
    }
    
    
    // ===== 방송 문서인 경우 =====
    
    private void autoCreateScheduleAndEpisodes(int documentId, int approverUserId) {
        // 방송 문서 여부
        Map<String, Object> form = approvalQueryMapper.selectBroadcastFormDetail(documentId);
        if (form == null || form.isEmpty()) {
            return;
        }

        // 1) 마지막 결재자의 결재라인 정보 조회 (PK/차수/상태)
        Map<String, Object> myLine = approvalQueryMapper.selectUserApprovalLine(documentId, approverUserId);
        if (myLine == null || myLine.get("approvalLineId") == null) {
            throw new IllegalStateException("결재라인을 찾을 수 없습니다. doc=" + documentId + ", user=" + approverUserId);
        }
        int approvalLineId = ((Number) myLine.get("approvalLineId")).intValue();

        // 2) 편성(프로그램) 생성 또는 재사용
        Integer found = broadcastMapper.findScheduleIdByApprovalLineId(approvalLineId);
        int scheduleId;
        if (found != null) {
            scheduleId = found;
        } else {
            var schedule = new BroadcastSchedule();
            schedule.setApprovalLineId(approvalLineId);
            // INSERT 실행 시 useGeneratedKeys로 PK가 schedule.broadcastScheduleId에 채워짐
            broadcastMapper.insertBroadcastSchedule(schedule);
            scheduleId = schedule.getBroadcastScheduleId();
        }

        // 3) 회차가 이미 있으면 재생성 스킵
        int existing = broadcastMapper.countEpisodesByScheduleId(scheduleId);
        if (existing > 0) return;

        // 4) 요일 및 기간으로 회차 계산 -> 일괄 INSERT (코멘트 제외)
        var episodes = buildEpisodes(scheduleId, form);
        if (!episodes.isEmpty()) {
            broadcastMapper.insertEpisodes(episodes);
        }
    }

    // 회차 목록 계산
    private List<BroadcastEpisode> buildEpisodes(int scheduleId, Map<String, Object> form) {
        String startStr = String.valueOf(form.get("broadcastFormStartDate"));
        String endStr = String.valueOf(form.get("broadcastFormEndDate"));
        
        // 문자열을 날짜 연산이 가능한 LocalDate로 변환
        LocalDate start = LocalDate.parse(startStr);
        LocalDate end = LocalDate.parse(endStr);
        
        if (end.isBefore(start)) throw new IllegalArgumentException("종료일이 시작일보다 앞섭니다.");

        // 선택된 방송 요일 수집
        EnumSet<DayOfWeek> days = collectSelectedWeekdays(form);
        
        if (days.isEmpty()) throw new IllegalArgumentException("방송 요일이 선택되지 않았습니다.");

        DateTimeFormatter iso = DateTimeFormatter.ISO_DATE;
        
        // 결과 회차 목록과 회차 번호 카운터
        List<BroadcastEpisode> out = new ArrayList<>();
        int no = 1;

        // 종료일 포함 범위: totalDays로 순회
        long totalDays = ChronoUnit.DAYS.between(start, end);   // end는 미포함 일수
        for (long offset = 0; offset <= totalDays; offset++) {  // 종료일 포함
            LocalDate d = start.plusDays(offset);
            if (!days.contains(d.getDayOfWeek())) continue;

            // 해당 날짜가 포함되는 경우 회차 엔티티 생성
            var e = new BroadcastEpisode();
            e.setBroadcastScheduleId(scheduleId);
            e.setBroadcastEpisodeNo(no++);
            e.setBroadcastEpisodeDate(d.format(iso));
            e.setBroadcastEpisodeWeekday(toKor(d.getDayOfWeek()));
            out.add(e);
        }
        return out;
    }

    private EnumSet<DayOfWeek> collectSelectedWeekdays(Map<String, Object> f) {
    	// 선택된 요일 수집: 화면 값(0/1, '1'/'Y'/'true')을 on(...)으로 판정해 추가
        EnumSet<DayOfWeek> s = EnumSet.noneOf(DayOfWeek.class);
        if (on(f.get("broadcastMonday"))) s.add(DayOfWeek.MONDAY);
        if (on(f.get("broadcastTuesday"))) s.add(DayOfWeek.TUESDAY);
        if (on(f.get("broadcastWednesday"))) s.add(DayOfWeek.WEDNESDAY);
        if (on(f.get("broadcastThursday"))) s.add(DayOfWeek.THURSDAY);
        if (on(f.get("broadcastFriday"))) s.add(DayOfWeek.FRIDAY);
        if (on(f.get("broadcastSaturday"))) s.add(DayOfWeek.SATURDAY);
        if (on(f.get("broadcastSunday"))) s.add(DayOfWeek.SUNDAY);
        return s;
    }

    // on 판정: null=false, Number(1)=true, String '1'/'Y'/'true'=true
    private boolean on(Object v) {
        if (v == null) return false;
        if (v instanceof Number n) return n.intValue() == 1;
        String s = String.valueOf(v).trim();
        return "1".equals(s) || "Y".equalsIgnoreCase(s) || "true".equalsIgnoreCase(s);
    }

    private String toKor(DayOfWeek d) {
        return switch (d) {
            case MONDAY -> "월";
            case TUESDAY -> "화";
            case WEDNESDAY -> "수";
            case THURSDAY -> "목";
            case FRIDAY -> "금";
            case SATURDAY -> "토";
            case SUNDAY -> "일";
        };
    }
    
    
    // 승인 시: 사용자의 최신 서명을 문서별 폴더에 사본으로 저장(파일 복사)
    private void saveApprovalSignature(int documentId, int userId) {
        String latestFsPath = approvalQueryMapper.selectLatestSignatureByUser(userId);
        
        if (latestFsPath == null || latestFsPath.isBlank()) {
            throw new IllegalStateException("서명이 등록되어 있지 않습니다. 마이페이지에서 서명을 등록해 주세요.");
        }

        try {
            Path source = Paths.get(latestFsPath.replace("\\", File.separator));
            if (!Files.exists(source) || Files.size(source) == 0) {
                throw new IllegalStateException("서명 원본을 찾을 수 없습니다.");
            }

            // 확장자 추출
            String fileName = source.getFileName().toString();
            String ext = "png";
            int dot = fileName.lastIndexOf('.');
            if (dot > -1 && dot < fileName.length() - 1) {
                ext = fileName.substring(dot + 1);
            }

            // 사본 저장 경로
            Path dstDir = Paths.get("C:/final/signatures/approvals/" + documentId);
            Files.createDirectories(dstDir);
            Path dst = dstDir.resolve(userId + "." + ext);

            // 복사(덮어쓰기) - 원본이 바뀌거나 지워져도 해당 문서는 당시 서명 표시
            Files.copy(source, dst, StandardCopyOption.REPLACE_EXISTING);
            
        } catch (IllegalStateException e) {
            throw e;
        } catch (Exception e) {
            throw new IllegalStateException("서명 저장 중 오류가 발생했습니다.", e);
        }
    }
    
}
