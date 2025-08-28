package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.ApprovalLine;
import com.example.broadcastgroupware.domain.BroadcastForm;
import com.example.broadcastgroupware.domain.BroadcastWeekday;
import com.example.broadcastgroupware.domain.ReferenceLine;
import com.example.broadcastgroupware.domain.VacationForm;
import com.example.broadcastgroupware.dto.ApprovalDocumentDto;
import com.example.broadcastgroupware.dto.ApprovalLineDto;
import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.ReferenceLineDto;
import com.example.broadcastgroupware.dto.VacationFormDto;
import com.example.broadcastgroupware.mapper.ApprovalMapper;

@Service
public class ApprovalService {
	private final ApprovalMapper approvalMapper;

    public ApprovalService(ApprovalMapper approvalMapper) {
        this.approvalMapper = approvalMapper;
    }

    // 공통(일반) 문서 작성
    @Transactional
    public int createCommonDocument(ApprovalDocumentDto request, boolean draft) {
    	request.setApprovalDocumentStatus(draft ? "임시저장" : "진행 중");  // 버튼에 따라 저장 상태 확정
        return saveDocumentWithLines(request);
    }

    // 휴가 문서 작성
    @Transactional
    public int createVacationDocument(ApprovalDocumentDto request, boolean draft) {
    	request.setApprovalDocumentStatus(draft ? "임시저장" : "진행 중");
    	int docId = saveDocumentWithLines(request);

        VacationFormDto vacationFormRequest = request.getVacationForm();  // 휴가 문서일 때만 값 존재
        if (vacationFormRequest != null) {
            VacationForm vacationForm = toEntity(vacationFormRequest);
            vacationForm.setApprovalDocumentId(docId);
            approvalMapper.insertVacationForm(vacationForm);
        }
        return docId;
    }

    // 방송 문서 작성
    @Transactional
    public int createBroadcastDocument(ApprovalDocumentDto request, boolean draft) {
    	request.setApprovalDocumentStatus(draft ? "임시저장" : "진행 중");
        int docId = saveDocumentWithLines(request);

        BroadcastFormDto broadcastFormRequest = request.getBroadcastForm();  // 방송 문서일 때만 값 존재
        if (broadcastFormRequest != null) {
            BroadcastForm form = toEntity(broadcastFormRequest);
            form.setApprovalDocumentId(docId);

            approvalMapper.insertBroadcastForm(form);  // 방송 폼 저장

            // 요일 저장 (항상 1레코드 생성: 선택 없으면 전부 0)
            BroadcastWeekday wd = toWeekdayEntity(broadcastFormRequest.getBroadcastDays(), form.getBroadcastFormId());
            approvalMapper.insertBroadcastWeekday(wd);
        }
        return docId;
    }
    
    private BroadcastWeekday toWeekdayEntity(List<String> days, int broadcastFormId) {
        BroadcastWeekday bw = new BroadcastWeekday();
        bw.setBroadcastFormId(broadcastFormId);

        // 기본 0으로 시작
        int sun=0, mon=0, tue=0, wed=0, thu=0, fri=0, sat=0;

        if (days != null && !days.isEmpty()) {
        	// 스트림으로 정규화 + 중복 제거
            Set<String> set = days.stream()			  
                    .filter(Objects::nonNull)		   // null 값 제거	
                    .map(s -> s.trim().toUpperCase())  // 앞뒤 공백 제거 + 대문자로 통일 ("mon" -> "MON")
                    .collect(Collectors.toSet());	   // Set으로 수집해 중복 제거
            sun = set.contains("SUN") ? 1 : 0;
            mon = set.contains("MON") ? 1 : 0;
            tue = set.contains("TUE") ? 1 : 0;
            wed = set.contains("WED") ? 1 : 0;
            thu = set.contains("THU") ? 1 : 0;
            fri = set.contains("FRI") ? 1 : 0;
            sat = set.contains("SAT") ? 1 : 0;
        }

        bw.setBroadcastSunday(sun);
        bw.setBroadcastMonday(mon);
        bw.setBroadcastTuesday(tue);
        bw.setBroadcastWednesday(wed);
        bw.setBroadcastThursday(thu);
        bw.setBroadcastFriday(fri);
        bw.setBroadcastSaturday(sat);
        return bw;
    }


    // 공통 로직: 문서 + 결재선 + 참조선 
    private int saveDocumentWithLines(ApprovalDocumentDto request) {
    	// 1) 문서 저장 준비: DTO → 엔터티
        ApprovalDocument document = toEntity(request);
        
        // 상태값이 비어 오면 안전 보정
        if (document.getApprovalDocumentStatus() == null || document.getApprovalDocumentStatus().isBlank()) {
            document.setApprovalDocumentStatus("진행 중");  // 기본값
        }
        
        approvalMapper.insertApprovalDocument(document);  // 실제 문서 insert
        int docId = document.getApprovalDocumentId();	  // 이후 결재선/참조선에 FK로 사용

        // 2) 결재선 저장: 첫 번째만 '대기', 나머지는 NULL
        if (request.getApprovalLines() != null && !request.getApprovalLines().isEmpty()) {
        	// 결재선 정렬 + 상한 제한
            List<ApprovalLineDto> ordered = request.getApprovalLines().stream()
                .filter(l -> l != null && l.getUserId() != null)
                .sorted((a, b) -> Integer.compare(
                    a.getApprovalLineSequence() != null ? a.getApprovalLineSequence() : Integer.MAX_VALUE,
                    b.getApprovalLineSequence() != null ? b.getApprovalLineSequence() : Integer.MAX_VALUE
                ))
                .limit(3)  // 최대 3명
                .toList();

            // 정렬된 DTO -> 엔터티로 변환
            List<ApprovalLine> lines = new ArrayList<>();
            for (int i = 0; i < ordered.size(); i++) {
                ApprovalLineDto src = ordered.get(i);
                ApprovalLine line = new ApprovalLine();
                line.setApprovalDocumentId(docId);  // FK
                line.setUserId(src.getUserId());
                
                // 시퀀스가 비어 있으면 1부터 순번 부여
                line.setApprovalLineSequence(
                    src.getApprovalLineSequence() != null ? src.getApprovalLineSequence() : (i + 1)
                );
                
                // 첫 번째 결재자만 '대기', 나머지는 NULL (이후 순차적으로 상태 갱신)
                line.setApprovalLineStatus(i == 0 ? "대기" : null);
                line.setApprovalLineComment(src.getApprovalLineComment());
                lines.add(line);
            }
            // 한 번에 insert
            if (!lines.isEmpty()) {
                approvalMapper.insertApprovalLines(lines);
            }
        }

        // 3) 참조선 저장 (DB에 개인으로만 저장)
        List<ReferenceLineDto> refs = request.getReferenceLines();   // userId 또는 teamId
        List<Integer> extraTeamIds = request.getReferenceTeamIds();  // 팀 ID가 따로 오는 경우

        boolean hasRefs = (refs != null && !refs.isEmpty()) || (extraTeamIds != null && !extraTeamIds.isEmpty());
        if (hasRefs) {

            // 3-1) 상한 사전검증: 팀/개인/총합 (중복 제거 후 계산)
            long teamCount = 0L;
            long userCount = 0L;

            if (refs != null) {
            	// 참조선 DTO에 포함된 팀/개인
                teamCount += refs.stream().map(ReferenceLineDto::getTeamId).filter(Objects::nonNull).distinct().count();
                userCount += refs.stream().map(ReferenceLineDto::getUserId).filter(Objects::nonNull).distinct().count();
            }
            if (extraTeamIds != null) {
            	// 별도 팀 ID 리스트까지 포함
                teamCount += extraTeamIds.stream().filter(Objects::nonNull).distinct().count();
            }
            
            final int MAX_TOTAL = 50;  // 팀+개인 선택 상한
            
            if (teamCount + userCount > MAX_TOTAL) throw new IllegalArgumentException("참조 대상은 총 " + MAX_TOTAL + "개입니다.");

            
            // 3-2) 팀 -> 개인(사용자) 전개
            List<Integer> teamIds = new ArrayList<>();
            
            if (refs != null) {
                teamIds.addAll(
                    refs.stream()
                        .map(ReferenceLineDto::getTeamId)
                        .filter(Objects::nonNull)
                        .collect(Collectors.toSet())
                );
            }
            if (extraTeamIds != null) {
                teamIds.addAll(
                    extraTeamIds.stream()
                        .filter(Objects::nonNull)
                        .collect(Collectors.toSet())
                );
            }
            // 팀 ID들을 모두 모아 중복 제거
            teamIds = teamIds.stream().distinct().toList();

            
            // 3-3) 개인 userId 집합 생성
            Set<Integer> userIds = new java.util.LinkedHashSet<>();
            
            // 참조선 중 개인 항목만 추출해서 집합에 추가
            if (refs != null) {
                userIds.addAll(
                    refs.stream()
                        .map(ReferenceLineDto::getUserId)
                        .filter(Objects::nonNull)
                        .collect(Collectors.toSet())
                );
            }

            // 팀이 선택된 경우: mapper로 팀에 속한 모든 개인 userId를 조회 후 추가
            if (!teamIds.isEmpty()) {
                List<Integer> fromTeams = approvalMapper.selectUserIdsByTeamIds(teamIds);
                if (fromTeams != null) userIds.addAll(fromTeams);  // 자동으로 중복 제거 (Set)
            }
            
            
            // 3-4) 전개 결과 기준의 실제 인원 상한 검사
            if (userIds.size() > MAX_TOTAL) {
                throw new IllegalArgumentException("참조 대상은 총 " + MAX_TOTAL + "명까지 저장할 수 있습니다.");
            }

            
            // 3-5) 최종 개인 단위로 insert
            List<ReferenceLine> entities = userIds.stream().map(uid -> {
                ReferenceLine rl = new ReferenceLine();
                rl.setApprovalDocumentId(docId);  // FK
                rl.setUserId(uid);
                return rl;
            }).toList();

            if (!entities.isEmpty()) {
                approvalMapper.insertReferenceLines(entities);
            }
        }
        
        // 최종적으로 생성된 문서 PK 반환
        return docId;
    }
    
    
    // DTO -> 엔터티 매핑
    private ApprovalDocument toEntity(ApprovalDocumentDto request) {
        ApprovalDocument entity = new ApprovalDocument();
        entity.setUserId(request.getUserId() == null ? 0 : request.getUserId());
        entity.setApprovalDocumentTitle(request.getApprovalDocumentTitle());
        entity.setApprovalDocumentContent(request.getApprovalDocumentContent());
        entity.setApprovalDocumentStatus(request.getApprovalDocumentStatus());
        return entity;
    }

    private VacationForm toEntity(VacationFormDto dto) {
        if (dto == null) return null;
        VacationForm entity = new VacationForm();
        entity.setVacationFormType(dto.getVacationFormType());
        entity.setVacationFormHalfType(dto.getVacationFormHalfType());
        entity.setVacationFormStartDate(dto.getVacationFormStartDate());
        entity.setVacationFormEndDate(dto.getVacationFormEndDate());
        return entity;
    }

    private BroadcastForm toEntity(BroadcastFormDto dto) {
        if (dto == null) return null;
        BroadcastForm entity = new BroadcastForm();
        entity.setBroadcastFormName(dto.getBroadcastFormName());
        entity.setBroadcastFormCapacity(dto.getBroadcastFormCapacity() == null ? 0 : dto.getBroadcastFormCapacity());
        entity.setBroadcastFormStartDate(dto.getBroadcastFormStartDate());
        entity.setBroadcastFormEndDate(dto.getBroadcastFormEndDate());
        entity.setBroadcastFormStartTime(dto.getBroadcastFormStartTime());
        entity.setBroadcastFormEndTime(dto.getBroadcastFormEndTime());
        return entity;
    }
}
