package com.example.broadcastgroupware.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.VacationHistory;
import com.example.broadcastgroupware.mapper.VacationMapper;

@Service
@Transactional
public class VacationService {
	private VacationMapper vacationMapper;
	public VacationService(VacationMapper vacationMapper) {
		this.vacationMapper = vacationMapper;
	}
	
	// 근무중인 직원 userId
	public List<Integer> selectJoinUser(){
		return vacationMapper.selectJoinUser();
	}
	
	// 전년도에 일한 개월수 만큼 연차 추가
	public void updateVacation(int userId) {
		vacationMapper.updateVacation(userId);
	}
	
	// 휴가결재 승인되면 휴가테이블에 사용한 휴가일 수 반영
	public void updateUseVacation() {
		vacationMapper.updateUseVacation();
	}
	
	// 최종 승인된 휴가 반영
	@Transactional
    public void applyApprovedVacation(int approvalDocumentId, int approvalLineId, double dayCount) {
        // 휴가 이력 저장
        VacationHistory history = new VacationHistory();
        history.setApprovalLineId(approvalLineId);
        history.setVacationHistoryDay(dayCount);
        vacationMapper.insertVacationHistory(history);

        // 사용일수 누적
        vacationMapper.addUsedVacationDaysByDoc(approvalDocumentId, dayCount);
    }
}
