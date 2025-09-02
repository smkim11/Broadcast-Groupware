package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface VacationMapper {
	// 재직중인 직원조회
	List<Integer> selectJoinUser();
	// 전년도에 일한 개월수 만큼 연차 추가
	void updateVacation(int userId);
	// 결재 승인된 휴가 반영
	void updateUseVacation();
}
