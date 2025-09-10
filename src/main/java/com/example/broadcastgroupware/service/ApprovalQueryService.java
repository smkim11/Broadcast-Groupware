package com.example.broadcastgroupware.service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
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

    // 진행 중 문서 목록 조회
    public List<ApprovalDocumentDto> findInProgressDocuments(int userId) {
        return approvalQueryMapper.selectInProgressDocuments(userId);
    }

    // 종료 문서 목록 조회
    public List<ApprovalDocumentDto> findCompletedDocuments(int userId, String status) {
        return approvalQueryMapper.selectCompletedDocuments(userId, status);
    }

    // 임시저장 문서 목록 조회
    public List<ApprovalDocumentDto> findDraftDocuments(int userId) {
        return approvalQueryMapper.selectDraftDocuments(userId);
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

        // 결재선의 서명 경로를 화면용으로 정리
        prepareSignatureUrls(approvalDocumentId, approvalLines);
        
        // 참조: 팀 전원 포함 시 팀 배지로, 나머지는 개인 배지로 분리
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
    
    
    // 파일 시스템 기준 루트/사본 폴더 (표시용 URL 산출에만 사용)
    // private static final String FINAL_STORAGE_PATH = "C:/final"; 기존경로
    private static final String FINAL_STORAGE_PATH = "/home/ubuntu/upload/";
    private static final String SIGNATURE_STORAGE_PATH = FINAL_STORAGE_PATH + "/signatures/approvals";
    
    // 결재선의 서명 경로를 화면 표시용으로 가공
    private void prepareSignatureUrls(int documentId, List<Map<String, Object>> lines) {
        if (lines == null) return;

        for (Map<String, Object> al : lines) {
            Object uidObj = al.get("userId");
            Object stObj = al.get("approvalLineStatus");
            
            // 승인된 결재자 -> 문서별 사본 경로 우선 노출
            if (uidObj != null && stObj != null) {
                int uid = (uidObj instanceof Number) ? ((Number) uidObj).intValue()
                                                     : Integer.parseInt(uidObj.toString());
                String st = stObj.toString();

                if ("승인".equals(st)) {
                    String approvalUrl = findApprovalSignatureUrl(documentId, uid);
                    if (approvalUrl != null) {
                        al.put("approvalSignatureUrl", approvalUrl);
                    }
                }
            }

            // 개인 서명 원본 경로 -> 표시용 URL로 치환
            Object sig = al.get("signatureUrl");
            if (sig instanceof String s && !s.isBlank()) {
                String publicUrl = toPublicUrlFromPath(s);
                if (publicUrl != null) {
                    al.put("signatureUrl", publicUrl);
                }
            }
        }
    }

    // 파일 시스템 경로(C:\final\..., file:///C:/final/...)를 
    // 정적 리소스 매핑(/final/**)에 맞춘 웹 경로(/final/...)로 변환
    private String toPublicUrlFromPath(String fullFsPath) {
        if (fullFsPath == null || fullFsPath.isBlank()) return null;

        String norm = fullFsPath.trim();

        // file:/// 접두 제거
        if (norm.regionMatches(true, 0, "file:///", 0, "file:///".length())) {
            norm = norm.substring("file:///".length());
        }

        // 슬래시 정규화
        norm = norm.replace("\\", "/").replaceAll("/{2,}", "/");

        // C:/final/ 하위만 /final/... 로 노출
        String lower = norm.toLowerCase();
        // String root = "c:/final/"; 로컬경로
        String root = "/home/ubuntu/upload/";
        if (lower.startsWith(root)) {
            String tail = norm.substring(root.length()).replaceAll("^/+", "");
            // return "/final/" + tail; 로컬경로
            return "/home/ubuntu/upload/" + tail;
        }
        return null;
    }

    // 문서별 서명 사본 URL 찾기
    private String findApprovalSignatureUrl(int documentId, int userId) {
        String base = SIGNATURE_STORAGE_PATH + "/" + documentId;
        String[] exts = {"png", "jpg", "jpeg", "webp"};
        for (String ext : exts) {
            Path cand = Paths.get(base, userId + "." + ext);
            if (Files.exists(cand)) {
            	// return "/final/signatures/approvals/" + documentId + "/" + userId + "." + ext; 로컬경로
                return "/home/ubuntu/upload/" + documentId + "/" + userId + "." + ext;
            }
        }
        return null;
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
    
    
    // 문서 결재 가능 여부 판정
    @Transactional(readOnly = true)
    public boolean canApprove(int documentId, int userId) {
    	// 현재 '대기' 차수 조회
        Integer cur = approvalQueryMapper.selectCurrentPendingSequence(documentId);
        
        // 사용자의 결재선 정보 조회 (차수/상태)
        Map<String,Object> my = approvalQueryMapper.selectUserApprovalLine(documentId, userId);
        
        if (cur == null || my == null) return false;
        Integer mySeq = (Integer) my.get("approvalLineSequence");
        String myStatus = (String) my.get("approvalLineStatus");
        
        // 사용자가 현재 대기 차수 & 상태 '대기'라면 결재 가능
        return "대기".equals(myStatus) && cur.equals(mySeq);
    }
    

    // 사용자가 현재 '대기'인 문서 목록 조회
    public List<ApprovalDocumentDto> findMyPendingApprovals(int userId) {
        return approvalQueryMapper.selectMyPendingApprovals(userId);
    }
    
    // 사용자는 '승인' + 문서는 아직 진행 중인 목록 조회
    public List<ApprovalDocumentDto> findMyInProgressApprovals(int userId) {
        return approvalQueryMapper.selectMyInProgressApprovals(userId);
    }
    
    // 종료 (최종 승인/반려) 문서 목록 조회 + 필터
    public List<ApprovalDocumentDto> findMyCompletedApprovals(int userId, String status) {
        return approvalQueryMapper.selectMyCompletedApprovals(userId, status);
    }

    // 사용자가 참조된 문서 목록 조회
    public List<ApprovalDocumentDto> findReferencedDocuments(int userId) {
        return approvalQueryMapper.selectReferencedDocuments(userId);
    }
    
}
