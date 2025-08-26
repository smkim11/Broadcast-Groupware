package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.Room;
import com.example.broadcastgroupware.domain.RoomReservation;
import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.AddIssueToRoom;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.MeetingroomReservationDto;
import com.example.broadcastgroupware.dto.MyReservationDto;

@Mapper
public interface ReservationMapper {

	// 예약 리스트
	List<CarReservationDto> getCarReservationListByDate(Map<String, Object> param);

	int getTotalCountByDate(String todayStart);

	// 차량등록
	void addCar(Vehicle vehicle);

	// 관리자용 차량 리스트
	List<Vehicle> adminCarList();

	// 차량 수정
	void modifyCar(Vehicle vehicle);

	// 차량 비활성 <-> 활성화
	void modifyVehicleStatus(CarToggle carToggle);
	void insertVehicleReason(CarToggle carToggle);

	// 기존 예약이랑 겹치는지 확인
	int checkReservations(VehicleReservation vehicleReservation);
	
	// 차량 예약
	boolean carReservation(VehicleReservation vehicleReservation);

	// 본인차량 예약조회
	List<MyReservationDto> myReservationList(int userId);

	// 차량 예약 취소
	int cancelReservation(int vehicleReservationId);

	int addMeetingRoom(Room room);

	
	// === 회의실 ===
	// 관리자용 회의실 리스트
	List<Room> meetingroomAdminList();


	// 관리자-회의실 이슈등록
	int modifyRoomStatus(AddIssueToRoom addIssueToRoom);
	int adminMeetingroomReservation(@Param("addIssueToRoom") AddIssueToRoom addIssueToRoom,
            @Param("userId") int userId);
	int meetingroomIssue(@Param("addIssueToRoom") AddIssueToRoom addIssueToRoom);

	// 회의실 리스트
	List<Room> meetingroomList();

	// 회의실 예약 리스트
	List<RoomReservation> meetingroomReservations(int roomId);

	// 회의실 예약
	void meetingroomReservation(@Param("reservations") List<MeetingroomReservationDto> reservations, 
	                            @Param("userId") int userId);

	
}
