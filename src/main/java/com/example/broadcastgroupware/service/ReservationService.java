package com.example.broadcastgroupware.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Room;
import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.AddIssueToRoom;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.MyReservationDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.mapper.ReservationMapper;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class ReservationService {
	private final ReservationMapper reservationMapper;

	public ReservationService(ReservationMapper reservationMapper) {
		this.reservationMapper = reservationMapper;
	}
	
	// 예약 리스트 조회
	public List<CarReservationDto> getCarReservationListByDate(String todayStart, PageDto pageDto) {
	    Map<String, Object> param = new HashMap<>();
	    param.put("todayStart", todayStart);
	    param.put("beginRow", pageDto.getBeginRow());
	    param.put("rowPerPage", pageDto.getRowPerPage());

	    return reservationMapper.getCarReservationListByDate(param);
	}


	public int getTotalCountByDate(String today) {
	    return reservationMapper.getTotalCountByDate(today);
	}

	// 차량등록
	public void addCar(Vehicle vehicle) {
		reservationMapper.addCar(vehicle);	
	}

	// 관리자용 차량 리스트
	public List<Vehicle> adminCarList() {

		return reservationMapper.adminCarList();
	}

	// 차량 수정
	public void modifyCar(Vehicle vehicle) {
		reservationMapper.modifyCar(vehicle);	
	}

	// 차량 비활성 <-> 활성화
	@Transactional
	public void carToggle(CarToggle carToggle) {
		reservationMapper.modifyVehicleStatus(carToggle); // 스테이터스 'Y' -> 'N'으로 변경
		reservationMapper.insertVehicleReason(carToggle); // reason테이블에 추가
	}

	// 차량예약
	public boolean carReservation(VehicleReservation vehicleReservation) {

	    // 1) 시작/종료 시간 null 체크
	    if(vehicleReservation.getVehicleReservationStartTime() == null || vehicleReservation.getVehicleReservationEndTime() == null) {
	        throw new IllegalArgumentException("예약 시작/종료 시간이 필요합니다.");
	    }

	    // 2) 겹치는 예약이 있는지 확인
	    int count = reservationMapper.checkReservations(vehicleReservation);
	    log.info("중복 시간 예약: {}", count);

	    if(count > 0) {
	        return false; // 겹치는 예약 있음
	    } else {
	        // 3) 겹치지 않으면 예약 저장
	        reservationMapper.carReservation(vehicleReservation);
	        return true;
	    }
	}

	// 본인 차량 예약조회
	public List<MyReservationDto> myReservationList(int userId) {
		
		return reservationMapper.myReservationList(userId);
	}

	// 차량 예약 취소 
	public boolean cancelReservation(int vehicleReservationId) {
		
		int cancel = reservationMapper.cancelReservation(vehicleReservationId);
		
		return cancel > 0;
	}
	
	// === 회의실 ===
	// 관리자-회의실 등록
	public boolean addMeetingRoom(Room room) {
		
		int count = reservationMapper.addMeetingRoom(room);
		
		return count > 0;
		
	}

	// 관리자용 회의실 리스트
	public List<Room> meetingroomAdminList() {
		
		return reservationMapper.meetingroomAdminList();
	}

	// 관리자-회의실 이슈등록
	@Transactional
	public boolean meetingroomAdminModify(AddIssueToRoom addIssueToRoom, int userId) {
		try {
		
		// 상태값 변경
		reservationMapper.modifyRoomStatus(addIssueToRoom);
		// 회의실 예약
		reservationMapper.adminMeetingroomReservation(addIssueToRoom, userId);
		// 이슈등록
		reservationMapper.meetingroomIssue(addIssueToRoom);
			return true;
		} catch(Exception e) {
			e.printStackTrace();
	        return false;
		}
		
	}

	
}
