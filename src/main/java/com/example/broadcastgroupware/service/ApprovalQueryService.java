package com.example.broadcastgroupware.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.dto.ApprovalDocumentDto;
import com.example.broadcastgroupware.mapper.ApprovalQueryMapper;

@Service
public class ApprovalQueryService {
    private final ApprovalQueryMapper approvalQueryMapper;

    public ApprovalQueryService(ApprovalQueryMapper approvalQueryMapper) {
        this.approvalQueryMapper = approvalQueryMapper;
    }

    // 진행 중 문서 리스트 조회
    public List<ApprovalDocumentDto> findInProgressDocuments(int userId) {
        return approvalQueryMapper.selectInProgressDocuments(userId);
    }

    // 결재 완료 문서 리스트 조회
    public List<ApprovalDocumentDto> findCompletedDocuments(int userId) {
        return approvalQueryMapper.selectCompletedDocuments(userId);
    }

    // 임시저장 문서 리스트 조회
    public List<ApprovalDocumentDto> findDraftDocuments(int userId) {
        return approvalQueryMapper.selectDraftDocuments(userId);
    }

    // 내가 참조된 문서 리스트 조회
    public List<ApprovalDocumentDto> findReferencedDocuments(int userId) {
        return approvalQueryMapper.selectReferencedDocuments(userId);
    }
    
    
    // 상세 페이지용 번들 조회 (문서 + 결재선 + 참조선 + 방송폼 + 휴가폼)
    @Transactional(readOnly = true)
    public Map<String, Object> getDocumentDetailBundle(int approvalDocumentId) {
        Map<String, Object> doc = approvalQueryMapper.selectDocumentDetail(approvalDocumentId);
        if (doc == null || doc.isEmpty()) {
            return null;
        }

        List<Map<String, Object>> approvalLines = approvalQueryMapper.selectApprovalLinesByDocumentId(approvalDocumentId);
        // 개인 참조 원본(팀/부서 포함)
        List<Map<String, Object>> referenceLines = approvalQueryMapper.selectReferenceLinesByDocumentId(approvalDocumentId);
        Map<String, Object> broadcastForm = approvalQueryMapper.selectBroadcastFormDetail(approvalDocumentId);
        Map<String, Object> vacationForm = approvalQueryMapper.selectVacationFormDetail(approvalDocumentId);

        // 모든 인원 수 선택된 팀은 팀 배지로 표시, 그 팀 구성원은 개인 배지에서 제외
        Map<String, List<Map<String, Object>>> collapsed = collapseReferences(referenceLines);
        
        Map<String, Object> bundle = new HashMap<>();
        bundle.put("document", doc);
        bundle.put("approvalLines", approvalLines);
        bundle.put("referenceLines", referenceLines);  // 원본 참조선 (개인)
        bundle.put("referenceTeams", collapsed.get("referenceTeams"));              // 팀 전원 포함된 팀 목록
        bundle.put("referenceIndividuals", collapsed.get("referenceIndividuals"));  // 팀으로 포함되지 않은 개인 목록
        bundle.put("broadcastForm", broadcastForm);
        bundle.put("vacationForm", vacationForm);
        return bundle;
    }
    
    
    // 문서 상세 화면용 뷰모델 조립 및 편집 가능 여부 판정
    @Transactional(readOnly = true)
    public Map<String, Object> getDetailPageModel(int approvalDocumentId, int loginUserId) {
        // 1) 기존 번들 재사용
        Map<String, Object> bundle = getDocumentDetailBundle(approvalDocumentId);
        if (bundle == null) return null;  // 문서 없음

        Map<String, Object> doc = (Map<String, Object>) bundle.get("document");
        String status = (String) doc.get("approvalDocumentStatus");

        // 2) 문서 상태 판정
        String docType =
            bundle.get("broadcastForm") != null ? "BROADCAST" :
            bundle.get("vacationForm") != null ? "VACATION" : "COMMON";

        // 3) 권한/편집 가능 여부
        Integer drafterUserId = approvalQueryMapper.selectDrafterIdByDocumentId(approvalDocumentId);
        String firstStatus = approvalQueryMapper.selectFirstApproverStatus(approvalDocumentId);
        
        boolean isDrafter = (drafterUserId != null && drafterUserId == loginUserId);  // 본인 문서
        boolean firstApproved = "승인".equals(firstStatus);				   			  // 최초 결재자: '승인' 전
        boolean isEditable = isDrafter && !firstApproved &&
                ("임시저장".equals(status) || "진행 중".equals(status));	   			  // 문서 상태: '임시저장' or '진행 중'

        // 4) 뷰에서 바로 쓸 수 있도록 플래그/타입을 번들에 주입해 반환
        bundle.put("docType", docType);
        bundle.put("isDrafter", isDrafter);
        bundle.put("firstApproved", firstApproved);
        bundle.put("isEditable", isEditable);
        return bundle;
    }

    
    // 개인 참조를 팀 기준으로 집계하여 팀 목록과 나머지 개인 목록으로 분류
    private Map<String, List<Map<String, Object>>> collapseReferences(List<Map<String, Object>> referenceLines) {
        Map<String, List<Map<String, Object>>> result = new HashMap<>();
        if (referenceLines == null || referenceLines.isEmpty()) {
            result.put("referenceTeams", List.of());
            result.put("referenceIndividuals", List.of());
            return result;
        }

        // teamId별 그룹핑
        Map<Integer, List<Map<String, Object>>> byTeam = referenceLines.stream()
            .collect(Collectors.groupingBy(
                m -> (Integer) m.get("teamId"),
                LinkedHashMap::new,
                Collectors.toList()
            ));

        // 조회 대상 teamIds (null 제외)
        List<Integer> teamIds = byTeam.keySet().stream()
            .filter(Objects::nonNull)
            .collect(Collectors.toCollection(ArrayList::new));

        // 팀 현재 인원 수 조회
        Map<Integer, Integer> teamCount = teamIds.isEmpty()
            ? Map.of()
            : approvalQueryMapper.selectTeamMemberCountsByIds(teamIds).stream()
                .collect(Collectors.toMap(
                    r -> (Integer) r.get("teamId"),
                    r -> ((Number) r.get("memberCount")).intValue()
                ));
        
        // 팀 참조: 참조 인원수 == 현재 팀 인원수
        Set<Integer> fullTeams = byTeam.entrySet().stream()
            .filter(e -> e.getKey() != null)
            .filter(e -> Objects.equals(e.getValue().size(), teamCount.get(e.getKey())))
            .map(Map.Entry::getKey)
            .collect(Collectors.toCollection(LinkedHashSet::new));

        // 팀 배지
        List<Map<String, Object>> referenceTeams = fullTeams.stream()
            .map(tid -> {
                Map<String, Object> any = byTeam.get(tid).get(0);
                Map<String, Object> m = new HashMap<>();
                m.put("teamId", tid);
                m.put("teamName", any.get("teamName"));
                m.put("departmentName", any.get("departmentName"));
                return m;
            })
            .collect(Collectors.toList());

        // 개인 배지: 팀으로 참조된 구성원 제외
        List<Map<String, Object>> referenceIndividuals = referenceLines.stream()
            .filter(m -> {
                Integer tid = (Integer) m.get("teamId");
                return tid == null || !fullTeams.contains(tid);
            })
            .collect(Collectors.toList());

        result.put("referenceTeams", referenceTeams);
        result.put("referenceIndividuals", referenceIndividuals);
        return result;
    }
    
}
