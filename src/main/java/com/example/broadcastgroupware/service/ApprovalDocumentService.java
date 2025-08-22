package com.example.broadcastgroupware.service;

import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.BroadcastForm;
import com.example.broadcastgroupware.domain.BroadcastWeekday;
import com.example.broadcastgroupware.domain.VacationForm;
import com.example.broadcastgroupware.dto.ApprovalDocumentDto;
import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.VacationFormDto;
import com.example.broadcastgroupware.mapper.ApprovalMapper;

@Service
public class ApprovalDocumentService {
	private final ApprovalMapper approvalMapper;

    public ApprovalDocumentService(ApprovalMapper approvalMapper) {
        this.approvalMapper = approvalMapper;
    }

    // 공통(일반) 문서 작성
    @Transactional
    public int createCommonDocument(ApprovalDocumentDto request, boolean draft) {
        request.setApprovalDocumentSave(draft ? "Y" : "N");  // 버튼에 따라 저장 상태 확정
        return saveDocumentWithLines(request);
    }

    // 휴가 문서 작성
    @Transactional
    public int createVacationDocument(ApprovalDocumentDto request, boolean draft) {
    	request.setApprovalDocumentSave(draft ? "Y" : "N");
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
    	request.setApprovalDocumentSave(draft ? "Y" : "N");
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

    
    private int saveDocumentWithLines(ApprovalDocumentDto request) {
        ApprovalDocument document = toEntity(request);
        if (document.getApprovalDocumentSave() == null) {
            document.setApprovalDocumentSave("N"); // 안전 보정
        }
        approvalMapper.insertApprovalDocument(document);
        return document.getApprovalDocumentId();
    }

/*
    // 공통 로직: 문서 + 결재선 + 참조선 
    private int saveDocumentWithLines(ApprovalDocumentDto request) {
        // 1) 문서 저장
    	Integer existingId = request.getApprovalDocumentId();
        int docId;
        if (existingId != null && existingId > 0) {
            docId = existingId;
        } else {
            ApprovalDocument document = toEntity(request);
            // request.setApprovalDocumentSave(...)가 안 되어 있으면 기본값 보정
            if (document.getApprovalDocumentSave() == null) {
                document.setApprovalDocumentSave("N"); // 기본: 제출
            }
            approvalMapper.insertApprovalDocument(document);
            docId = document.getApprovalDocumentId();
            request.setApprovalDocumentId(docId);
        }

        // 2) 결재선 저장 (1명 ~ 3명, 순서 중복/범위 체크, 상태=대기)
        List<ApprovalLineDto> approvalLineRequests = request.getApprovalLines();
        if (approvalLineRequests != null && !approvalLineRequests.isEmpty()) {
            List<ApprovalLine> approvalLineEntities = new ArrayList<>();
            Set<Integer> usedSequences = new HashSet<>();

            for (ApprovalLineDto lineRequest : approvalLineRequests) {
                if (lineRequest == null) continue;

                Integer seq = lineRequest.getApprovalLineSequence();
                if (seq == null || seq < 1 || seq > 3 || !usedSequences.add(seq)) {
                    throw new IllegalArgumentException("Invalid approvalLineSequence: " + seq);
                }

                ApprovalLine line = new ApprovalLine();
                line.setApprovalDocumentId(docId);
                line.setUserId(lineRequest.getUserId() == null ? 0 : lineRequest.getUserId());
                line.setApprovalLineSequence(seq);
                line.setApprovalLineStatus(ApprovalStatus.PENDING.getLabel());  // 결재선 생성 시 상태는 항상 "대기"로 초기화
                line.setApprovalLineComment(lineRequest.getApprovalLineComment());
                approvalLineEntities.add(line);
            }
            if (!approvalLineEntities.isEmpty()) {
                approvalMapper.insertApprovalLines(approvalLineEntities);
            }
        }

        // 3) 참조선 저장 (userId 중복 제거)
        List<ReferenceLineDto> referenceLineRequests = request.getReferenceLines();
        if (referenceLineRequests != null && !referenceLineRequests.isEmpty()) {
            List<ReferenceLine> referenceLineEntities = new ArrayList<>();
            Set<Integer> seenReferenceUserIds = new HashSet<>();

            for (ReferenceLineDto refRequest : referenceLineRequests) {
                if (refRequest == null || refRequest.getUserId() == null) continue;
                if (!seenReferenceUserIds.add(refRequest.getUserId())) continue;  // 중복 제거

                ReferenceLine ref = new ReferenceLine();
                ref.setApprovalDocumentId(docId);
                ref.setUserId(refRequest.getUserId());
                referenceLineEntities.add(ref);
            }
            if (!referenceLineEntities.isEmpty()) {
                approvalMapper.insertReferenceLines(referenceLineEntities);
            }
        }
        return docId;
    }
*/
    
    // DTO -> 엔터티 매핑
    private ApprovalDocument toEntity(ApprovalDocumentDto request) {
        ApprovalDocument entity = new ApprovalDocument();
        entity.setUserId(request.getUserId() == null ? 0 : request.getUserId());
        entity.setApprovalDocumentTitle(request.getApprovalDocumentTitle());
        entity.setApprovalDocumentContent(request.getApprovalDocumentContent());
        entity.setApprovalDocumentSave(request.getApprovalDocumentSave());
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
