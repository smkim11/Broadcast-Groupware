package com.example.broadcastgroupware.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Attendance;
import com.example.broadcastgroupware.dto.AttendanceListDto;
import com.example.broadcastgroupware.mapper.AttendanceMapper;

@Service
@Transactional
public class AttendanceService {
	private AttendanceMapper attendanceMapper;
	public AttendanceService(AttendanceMapper attendanceMapper) {
		this.attendanceMapper = attendanceMapper;
	}
	
	// 오늘날짜로 본인 근태기록 조회
	public Attendance selectUserAttendance(int userId) {
		return attendanceMapper.selectUserAttendance(userId);
	}
	
	// 직책별 팀,부서,전체 근태조회
	public List<HashMap<String,Object>> selectAttendanceListByRank(AttendanceListDto attendanceListDto){
		return attendanceMapper.selectAttendanceListByRank(attendanceListDto);
	}
	
	// 로그인한 사용자의 근태기록 조회
	public List<HashMap<String,Object>> selectAttendanceList(int userId){
		return attendanceMapper.selectAttendanceList(userId);
	}
	
	// 이번주 근무시간
	public String selectWeekWorkHours(int userId) {
		return attendanceMapper.selectWeekWorkHours(userId);
	}
	
	// 입사후 총 근무일
	public String selectTotalWorkDay(int userId) {
		return attendanceMapper.selectTotalWorkDay(userId);
	}
	
	// 잔여휴가
	public Double selectRemainVacation(int userId) {
		return attendanceMapper.selectRemainVacation(userId);
	}
	
	// 출근후 퇴근 안누른 사람 목록
	public List<Integer> selectNotOutUser(){
		return attendanceMapper.selectNotOutUser();
	}
	
	// 로그인한 직원의 휴가기록 조회
	public List<HashMap<String,Object>> selectVacationList(int userId){
		return attendanceMapper.selectVacationList(userId);
	}
		
	// 출근 기록
	public void insertAttendanceIn(Attendance attendance) {
		attendanceMapper.insertAttendanceIn(attendance);
	}
	
	// 퇴근 기록
	public void updateAttendanceOut(Attendance attendance) {
		// 외근하고 복귀를 안누르고 퇴근을 누르면 외근복귀에도 퇴근과 같은시간 저장
		Attendance ad = attendanceMapper.selectUserAttendance(attendance.getUserId());
		if(ad.getAttendanceOutside() != null && ad.getAttendanceInside() == null) {
			attendanceMapper.updateAttendanceInside(attendance);
		}
		attendanceMapper.updateAttendanceOut(attendance);
	}
	
	// 외근 기록
	public void updateAttendanceOutside(Attendance attendance) {
		// 출근을 안찍고 외근을 찍으면 출근에도 외근과 동일한 시간 저장
		if(attendanceMapper.selectUserAttendance(attendance.getUserId()) == null) {
			attendanceMapper.insertAttendanceIn(attendance);
		}
		attendanceMapper.updateAttendanceOutside(attendance);
	}
	
	// 외근복귀 기록
	public void updateAttendanceInside(Attendance attendance) {
		attendanceMapper.updateAttendanceInside(attendance);
	}
	
	// 퇴근 안누른 사람 정시퇴근 처리
	public void updateNotOutUser(int userId) {
		attendanceMapper.updateNotOutUser(userId);
	}
}
