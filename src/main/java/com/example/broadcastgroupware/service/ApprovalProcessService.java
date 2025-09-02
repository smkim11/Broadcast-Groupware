package com.example.broadcastgroupware.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.mapper.ApprovalMapper;
import com.example.broadcastgroupware.mapper.ApprovalQueryMapper;

@Service
public class ApprovalProcessService {
    private final ApprovalMapper approvalMapper;
    private final ApprovalQueryMapper approvalQueryMapper;

    public ApprovalProcessService(ApprovalMapper approvalMapper, ApprovalQueryMapper approvalQueryMapper) {
        this.approvalMapper = approvalMapper;
        this.approvalQueryMapper = approvalQueryMapper;
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
            }
        } else {
            approvalMapper.updateDocumentStatus(documentId, "반려");
        }
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
