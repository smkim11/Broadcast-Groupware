package com.example.broadcastgroupware.schedule;

import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.example.broadcastgroupware.service.VacationService;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class VacationSchedule {
	private VacationService vacationService;
	public VacationSchedule(VacationService vacationService) {
		this.vacationService = vacationService;
	}
	
	// 매년 1월1일에 전년도에 일한 개월수 만큼 연차 추가
	@Scheduled(cron = "0 0 0 1 1 *")
	public void HolidaySchedule() {
		List<Integer> userList = vacationService.selectJoinUser();
		for(int userId:userList) {
			vacationService.updateVacation(userId);
		}
		log.info("연차 추가 완료");
	}
}
