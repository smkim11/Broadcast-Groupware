package com.example.broadcastgroupware.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.broadcastgroupware.domain.Room;
import com.example.broadcastgroupware.domain.RoomReservation;
import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.AddIssueToRoom;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.MeetingroomReservationDto;
import com.example.broadcastgroupware.dto.MyReservationDto;
import com.example.broadcastgroupware.dto.MyReservationRoom;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.RoomDetailDto;
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
	    // log.info("중복 시간 예약: {}", count);

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
	
	// 이슈기간 종료 차량 활성화
	@Transactional
	public int modifyCarStatus() {
		List<Integer> vehicleStatusNList = reservationMapper.StatusNList();
		
		if (vehicleStatusNList == null || vehicleStatusNList.isEmpty()) {
			return 0; 
		}
		
		return reservationMapper.modifyCarStatus(vehicleStatusNList);
		
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

	// 회의실 리스트
	public List<Room> meetingroomList() {
		return reservationMapper.meetingroomList();
	}

	// 회의실 예약 리스트
	public List<RoomReservation> meetingroomReservations(int roomId) {
		return reservationMapper.meetingroomReservations(roomId);
	}

	// 회의실 예약
	@Transactional
	public boolean meetingroomReservation(List<MeetingroomReservationDto> reservations, int userId) {

	    for(MeetingroomReservationDto dto : reservations) {
	        /*
	    	log.info("서비스단 DTO 확인: roomId={}, reason={}, start={}, end={}",
	            dto.getRoomId(), dto.getRoomReservationReason(),
	            dto.getRoomReservationStartTime(), dto.getRoomReservationEndTime());
	            */

	        int count = reservationMapper.checkReservationsRoom(dto, userId);
	        if(count > 0) {
	            //log.info("중복 예약 있음: roomId={}, start={}, end={}", dto.getRoomId(), dto.getRoomReservationStartTime(), dto.getRoomReservationEndTime());
	            return false; // 하나라도 중복 있으면 실패
	        }
	    }

	    // 중복 없으면 복수건 삽입
	    reservationMapper.meetingroomReservation(reservations, userId);
	    return true;
	}

	// 예약내역 상세보기
	public RoomDetailDto roomDetail(int reservationId) {
		return reservationMapper.roomDetail(reservationId);
	}

	// 예약 취소
	public int roomCancel(int reservationId) {
		return reservationMapper.roomCancel(reservationId);
	}

	// 내 예약 조회
	public List<MyReservationRoom> myReservation(int userId) {
		return reservationMapper.myReservation(userId);
	}


	
	
	// ====== 편집실 ========
	
	// 편집실 등록
	public boolean addCuttingRoom(Room room) {
		return reservationMapper.addCuttingRoom(room);
	}

	// 관리자- 편집실 리스트
	public List<Room> cuttingroomAdminList() {
		return reservationMapper.cuttingroomAdminList();
	}

	// 편집실 리스트
	public List<Room> cuttingroomList() {
		return reservationMapper.cuttingroomList();
	}

	// 내 편집실 예약 조회
	public List<MyReservationRoom> myCuttingroomReservation(int userId) {
		return reservationMapper.myCuttingroomReservation(userId);
	}

	// 이슈기간 종료 회의실, 편집실 활성화
	@Transactional
	public int modifyRoomStatus() {
		List<Integer> roomStatusNList = reservationMapper.RoomStatusNList();
		
		if (roomStatusNList == null || roomStatusNList.isEmpty()) {
			return 0; 
		}
		
		return reservationMapper.modifyRoomStatusToY(roomStatusNList);	
	}
	

	
	
}
