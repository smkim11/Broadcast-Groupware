package com.example.broadcastgroupware.schedule;

import java.util.List;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.example.broadcastgroupware.service.AttendanceService;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class AttendanceSchedule {
	private AttendanceService attendanceService;
	public AttendanceSchedule(AttendanceService attendanceService) {
		this.attendanceService= attendanceService;
	}
	
	// 출근 후 퇴근을 안누르고간 직원들 정시퇴근처리
	@Scheduled(cron = "0 59 23 * * *")
	public void AttendanceOutSchedule() {
		List<Integer> userList = attendanceService.selectNotOutUser();
		for(int userId:userList) {
			attendanceService.updateNotOutUser(userId);
		}
	}
}
