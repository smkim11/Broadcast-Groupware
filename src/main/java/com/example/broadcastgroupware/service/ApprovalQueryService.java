package com.example.broadcastgroupware.service;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.mapper.ApprovalQueryMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ApprovalQueryService {
    private final ApprovalQueryMapper approvalQueryMapper;

    public ApprovalQueryService(ApprovalQueryMapper approvalQueryMapper) {
        this.approvalQueryMapper = approvalQueryMapper;
    }

    // 진행 중 문서 리스트 조회
    public List<ApprovalDocument> findInProgressDocuments(int userId) {
        return approvalQueryMapper.selectInProgressDocuments(userId);
    }

    // 결재 완료 문서 리스트 조회
    public List<ApprovalDocument> findCompletedDocuments(int userId) {
        return approvalQueryMapper.selectCompletedDocuments(userId);
    }

    // 임시저장 문서 리스트 조회
    public List<ApprovalDocument> findDraftDocuments(int userId) {
        return approvalQueryMapper.selectDraftDocuments(userId);
    }

    // 내가 참조된 문서 리스트 조회
    public List<ApprovalDocument> findReferencedDocuments(int userId) {
        return approvalQueryMapper.selectReferencedDocuments(userId);
    }
}
