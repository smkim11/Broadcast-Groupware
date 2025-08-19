package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.ApprovalLine;
import com.example.broadcastgroupware.domain.ApprovalStatus;
import com.example.broadcastgroupware.domain.BroadcastForm;
import com.example.broadcastgroupware.domain.ReferenceLine;
import com.example.broadcastgroupware.domain.VacationForm;
import com.example.broadcastgroupware.dto.ApprovalDocumentDto;
import com.example.broadcastgroupware.dto.ApprovalLineDto;
import com.example.broadcastgroupware.dto.BroadcastFormDto;
import com.example.broadcastgroupware.dto.ReferenceLineDto;
import com.example.broadcastgroupware.dto.VacationFormDto;
import com.example.broadcastgroupware.mapper.ApprovalMapper;

@Service
public class ApprovalDocumentService {
	private final ApprovalMapper approvalMapper;

    public ApprovalDocumentService(ApprovalMapper approvalMapper) {
        this.approvalMapper = approvalMapper;
    }

    @Transactional
    public int createCommonDocument(ApprovalDocumentDto request, boolean draft) {
    	// DTO → 엔티티 변환 및 임시저장 여부(Y/N) 설정
        ApprovalDocument doc = toEntity(request);
        doc.setApprovalDocumentSave(draft ? "Y" : "N");

        // DB에 문서 저장 후 PK 조회
        approvalMapper.insertApprovalDocument(doc);
        int docId = doc.getApprovalDocumentId();

        // 후속 처리: DTO에 ID 세팅 -> 결재선/참조선 저장
        request.setApprovalDocumentId(docId);
        saveDocumentWithLines(request);

        return docId;
    }

    @Transactional
    public int createVacationDocument(ApprovalDocumentDto request) {
    	int docId = saveDocumentWithLines(request);

        VacationFormDto vacationFormRequest = request.getVacationForm();  // 휴가 문서일 때만 값 존재
        if (vacationFormRequest != null) {
            VacationForm vacationForm = toEntity(vacationFormRequest);
            vacationForm.setApprovalDocumentId(docId);
            approvalMapper.insertVacationForm(vacationForm);
        }
        return docId;
    }

    @Transactional
    public int createBroadcastDocument(ApprovalDocumentDto request) {
        int docId = saveDocumentWithLines(request);

        BroadcastFormDto broadcastFormRequest = request.getBroadcastForm();  // 방송 문서일 때만 값 존재
        if (broadcastFormRequest != null) {
            BroadcastForm broadcastForm = toEntity(broadcastFormRequest);
            broadcastForm.setApprovalDocumentId(docId);
            approvalMapper.insertBroadcastForm(broadcastForm);
        }
        return docId;
    }
    
    
    // 공통 로직: 문서 + 결재선 + 참조선 
    private int saveDocumentWithLines(ApprovalDocumentDto request) {
        // 1) 문서 저장
        ApprovalDocument document = toEntity(request);
        approvalMapper.insertApprovalDocument(document);
        int docId = document.getApprovalDocumentId();

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
