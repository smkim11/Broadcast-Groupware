package com.example.broadcastgroupware.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.ApprovalDocument;
import com.example.broadcastgroupware.domain.BroadcastForm;
import com.example.broadcastgroupware.domain.VacationForm;
import com.example.broadcastgroupware.dto.BroadcastDocumentRequestDto;
import com.example.broadcastgroupware.dto.CommonDocumentRequestDto;
import com.example.broadcastgroupware.dto.VacationDocumentRequestDto;
import com.example.broadcastgroupware.mapper.ApprovalMapper;

@Service
public class ApprovalDocumentService {
	private final ApprovalMapper approvalMapper;

    public ApprovalDocumentService(ApprovalMapper approvalMapper) {
        this.approvalMapper = approvalMapper;
    }

    @Transactional
    public int createCommonDocument(CommonDocumentRequestDto dto) {
        ApprovalDocument doc = dto.getApprovalDocument();
        approvalMapper.insertApprovalDocument(doc);
        return doc.getApprovalDocumentId();
    }

    @Transactional
    public int createVacationDocument(VacationDocumentRequestDto dto) {
        ApprovalDocument doc = dto.getApprovalDocument();
        approvalMapper.insertApprovalDocument(doc);
        int docId = doc.getApprovalDocumentId();

        VacationForm vf = dto.getVacationForm();
        if (vf != null) {
            vf.setApprovalDocumentId(docId);
            approvalMapper.insertVacationForm(vf);
        }
        return docId;
    }

    @Transactional
    public int createBroadcastDocument(BroadcastDocumentRequestDto dto) {
        ApprovalDocument doc = dto.getApprovalDocument();
        approvalMapper.insertApprovalDocument(doc);
        int docId = doc.getApprovalDocumentId();

        BroadcastForm bf = dto.getBroadcastForm();
        if (bf != null) {
            bf.setApprovalDocumentId(docId);
            approvalMapper.insertBroadcastForm(bf);
        }
        return docId;
    }
}
