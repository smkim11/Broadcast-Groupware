package com.example.broadcastgroupware.service;

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

    @Transactional
    public void decide(int documentId, int userId, String decision, String comment) {
        // 1) 현재 대기 차수 & 내 결재선
        Integer currentSeq = approvalQueryMapper.selectCurrentPendingSequence(documentId);
        Map<String, Object> myLine = approvalQueryMapper.selectUserApprovalLine(documentId, userId);
        if (currentSeq == null || myLine == null) throw new IllegalStateException("결재할 수 있는 상태가 아닙니다.");

        Integer mySeq = (Integer) myLine.get("approvalLineSequence");
        String myStatus = (String) myLine.get("approvalLineStatus");
        if (!"대기".equals(myStatus) || !currentSeq.equals(mySeq)) {
            throw new IllegalStateException("현재 결재 차수가 아닙니다.");
        }

        // 2) 내 결재 상태 반영
        String targetStatus = switch (decision.toUpperCase()) {
            case "APPROVE" -> "승인";
            case "REJECT" -> "반려";
            default -> throw new IllegalArgumentException("invalid decision");
        };

        int updated = approvalMapper.updateMyApprovalLineDecision(documentId, userId, targetStatus, comment);
        if (updated == 0) throw new IllegalStateException("결재 업데이트에 실패했습니다.");

        // 3) 다음 차수/문서 상태
        if ("승인".equals(targetStatus)) {
            Integer nextSeq = approvalQueryMapper.selectNextSequenceToActivate(documentId);  // 다음 NULL 차수
            if (nextSeq != null) {
                approvalMapper.activateNextApprover(documentId, nextSeq);
                approvalMapper.updateDocumentStatus(documentId, "진행 중");
            } else {
                approvalMapper.updateDocumentStatus(documentId, "승인");
            }
        } else {
            approvalMapper.updateDocumentStatus(documentId, "반려");
        }
    }
}
