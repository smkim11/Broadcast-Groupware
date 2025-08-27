package com.example.broadcastgroupware.rest;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Room;
import com.example.broadcastgroupware.domain.RoomReservation;
import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.AddIssueToRoom;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.MeetingroomReservationDto;
import com.example.broadcastgroupware.dto.MyReservationDto;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.ReservationPeriod;
import com.example.broadcastgroupware.dto.RoomDetailDto;
import com.example.broadcastgroupware.dto.UserSessionDto;
import com.example.broadcastgroupware.service.ReservationService;

import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api")
@Slf4j
public class ReservationRestController {
	
	private final ReservationService reservationService;
	
	public ReservationRestController(ReservationService reservationService) {
		this.reservationService = reservationService;
	}

	// 차량 예약 리스트 조회 (페이징)
	@GetMapping("/user/car")
	@ResponseBody
	public Map<String, Object> carList(HttpSession session,
	                                   @RequestParam(value = "page", defaultValue = "1") int page,
	                                   @RequestParam(value = "size", defaultValue = "10") int size) {

	    UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");

	    Map<String, Object> response = new HashMap<>();

	    if (loginUser != null) {
	        response.put("username", loginUser.getUsername());
	        response.put("role", loginUser.getRole());
	        response.put("userId", loginUser.getUserId());
	    }

	    String todayStart = java.time.LocalDate.now() + " 00:00:00";

	    // 전체 예약 수
	    int totalCount = reservationService.getTotalCountByDate(todayStart);
	    int totalPage = (int) Math.ceil((double) totalCount / size);
	    PageDto pageDto = new PageDto(page, size, totalPage);
	    

	    // 차량별 예약 리스트 조회
	    List<CarReservationDto> rawList = reservationService.getCarReservationListByDate(todayStart, pageDto);
	    Map<Integer, CarReservationDto> mergedMap = new LinkedHashMap<>();

	    for (CarReservationDto c : rawList) {
	        ReservationPeriod period = null;
	        if (c.getReservationStart() != null && !c.getReservationStart().isEmpty()) {
	            period = new ReservationPeriod(c.getReservationStart(), c.getReservationEnd());
	        }

	        if (mergedMap.containsKey(c.getVehicleId())) {
	            // 기존 DTO가 있으면 reservationPeriods만 추가
	            if (period != null) {
	                mergedMap.get(c.getVehicleId()).getReservationPeriods().add(period);
	            }
	        } else {
	            // 새 DTO이면 periods 추가 후 put
	            if (period != null) {
	                c.getReservationPeriods().add(period);
	            }
	            mergedMap.put(c.getVehicleId(), c);
	        }
	    }

	    // 로그 출력 (확인용)
	    /*
	    mergedMap.values().forEach(c -> {
	        System.out.println("===== 차량 예약 확인 =====");
	        System.out.println("vehicleId: " + c.getVehicleId());
	        System.out.println("vehicleNo: " + c.getVehicleNo());
	        System.out.println("vehicleName: " + c.getVehicleName());
	        System.out.println("vehicleType: " + c.getVehicleType());
	        System.out.println("vehicleStatus: " + c.getVehicleStatus());
	        System.out.println("reservationPeriods: ");
	        for (ReservationPeriod p : c.getReservationPeriods()) {
	            System.out.println("    start: " + p.getReservationStart() + ", end: " + p.getReservationEnd());
	        }
	    });
	    */

	    response.put("carReservationList", new ArrayList<>(mergedMap.values()));
	    response.put("pageDto", pageDto);

	    return response;
	}
	
	// 예약 확인
	@GetMapping("/user/myReservationList")
	public Map<String, Object> myReservationList(HttpSession session) {
		
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		int userId = loginUser.getUserId();
		//log.info("userId: {}", userId);

		Map<String, Object> response = new HashMap<>();
		
		List<MyReservationDto> myReservationList = reservationService.myReservationList(userId);
		
		if (myReservationList == null || myReservationList.isEmpty()) {
	        //log.warn("myReservationList is empty or null for userId: {}", userId);
	    } else {
	        //log.info("myReservationList size: {}", myReservationList.size());
	        for (MyReservationDto r : myReservationList) {
	        	//log.info("Reservation: id={}, vehicleNo={}, rentDate={}, returnDate={}",
	        	         //r.getVehicleReservationId(), r.getVehicleNo(), r.getRentDate(), r.getReturnDate());

	        }
	    }
		
		response.put("myReservationList", myReservationList);
		
		return response;
	}

	// 예약 취소
	@PostMapping("/user/cancelMyReservation")
	 public Map<String, Object> cancelReservation(@RequestParam  int vehicleReservation) {
		Map<String, Object> result = new HashMap<>();
		
        try {

            //log.info("vehicleReservationId: {}", vehicleReservation);

            boolean success = reservationService.cancelReservation(vehicleReservation);
            result.put("success", success);
            if (!success) result.put("message", "취소 실패");
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "서버 오류");
        }
        return result;
    }
	

	// 차량 등록
	@PostMapping("/car/addCar")
	public String car(Vehicle vehicle) {
		
		reservationService.addCar(vehicle);
		
		return "success";
	}
	
	// 차량 수정
	@PostMapping("/car/modifyCar")
	public String modifyCar(Vehicle vehicle) {
		
		/*
		log.info("=== Ajax로 전달된 차량 정보 ===", "");
		log.info("vehicleId: {}", vehicle.getVehicleId());
		log.info("vehicleNo: {}", vehicle.getVehicleNo());
		log.info("vehicleName: {}", vehicle.getVehicleName());
		log.info("vehicleType: {}", vehicle.getVehicleType());
		*/
		
		reservationService.modifyCar(vehicle);
		
		return "success";
	}
	
	// 차량 비활성 <-> 활성화
	@PostMapping("/car/carToggle")
	public String carToggle(CarToggle carToggle) {
		
		/*
		log.info("=== Ajax로 전달된 차량 정보(이슈등록) ===", "");
		log.info("vehicleId: {}", carToggle.getVehicleId());
		log.info("reasonContent: {}", carToggle.getVehicleUseReasonContent());
		log.info("reasonStartDate: {}", carToggle.getVehicleUseReasonStartDate());
		log.info("reasonEndDate: {}", carToggle.getVehicleUseReasonEndDate());
		log.info("vehicleStatus: {}", carToggle.getVehicleStatus());
		*/
		
		reservationService.carToggle(carToggle);
		
		return "success";
	}
	
	// 관리자용 차량리스트
	@GetMapping("/car/adminCarList")
	public List<Vehicle> adminCarList() {
		return reservationService.adminCarList();
	}
	
	// 차량예약
	@PostMapping("/car/CarReservation")
	@ResponseBody
	public String CarReservation(@RequestBody VehicleReservation vehicleReservation) {

		/*
	    log.info("=== Ajax로 전달된 차량 정보(차량예약) ===");
	    log.info("userId: {}", vehicleReservation.getUserId());
	    log.info("vehicleId: {}", vehicleReservation.getVehicleId());
	    log.info("vehicleReservationStartTime: {}", vehicleReservation.getVehicleReservationStartTime());
	    log.info("vehicleReservationEndTime: {}", vehicleReservation.getVehicleReservationEndTime());
	    */

	    boolean success = reservationService.carReservation(vehicleReservation);

	    if(!success) {
	        return "선택한 시간과 기존 예약이 겹칩니다.";
	    }

	    return "예약 성공";
	}
	
	
	// ====== 회의실 ========
	
	// 회의실 등록
	@PostMapping("meetingroom/addRoom")
	public String addMeetingRoom(Room room) {
		
		log.info("=== Ajax로 전달된 회의실등록 ===");
		log.info("roomName: {}", room.getRoomName());
		log.info("roomLocation: {}", room.getRoomLocation());
		log.info("roomCapaticy: {}", room.getRoomCapacity());

		boolean success = reservationService.addMeetingRoom(room);
		
		if(!success) {
			return "등록에 실패했습니다";
		}
		
		return "success";
	}

	// 관리자용 회의실 리스트
	@GetMapping("meetingroom/adminList")
	public List<Room> meetingroomAdminList() {
		
		return reservationService.meetingroomAdminList();
	}
	
	// 관리자- 회의실 이슈등록
	@PostMapping("/meetingroom/adminIssue")
	public String meetingroomAdminModify(AddIssueToRoom addIssueToRoom, HttpSession session) {
		UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
		int userId = loginUser.getUserId();
		
		//log.info("roomId: {}", addIssueToRoom.getRoomId());
		//log.info("roomStatus: {}", addIssueToRoom.getRoomStatus());
		//log.info("roomUseReasonStartDate: {}", addIssueToRoom.getRoomUseReasonStartDate());
		//log.info("roomUseReasonEndDate: {}", addIssueToRoom.getRoomUseReasonEndDate());
		//log.info("roomUseReasonContent: {}", addIssueToRoom.getRoomUseReasonContent());
		
		boolean success = reservationService.meetingroomAdminModify(addIssueToRoom, userId);
		
		if(!success) {
			return "등록에 실패했습니다";
		}
		return "success";
	}
	
	// 회의실 리스트
	@GetMapping("/meetingroom/roomlist")
	public List<Room> meetingroomList() {
		return reservationService.meetingroomList();
	}
	
	// 회의실 예약 내역
	@GetMapping("/meetingroom/reservations")
	public List<RoomReservation> meetingroomReservations(@RequestParam int roomId) {
		//log.info("roomId: {}", roomId);
		return reservationService.meetingroomReservations(roomId);
	}
	
	// 회의실 예약
	@PostMapping("/meetingroom/reservation")
	public String meetingroomReservation(@RequestBody List<MeetingroomReservationDto> reservations, HttpSession session) {
	    UserSessionDto loginUser = (UserSessionDto) session.getAttribute("loginUser");
	    int userId = loginUser.getUserId();

	    // 단일 예약이면 size가 1, 복합 예약이면 size > 1
	    if(reservations == null || reservations.isEmpty()) {
	        return "예약 정보가 없습니다.";
	    }

	    // 로그 확인
	    /*
	    for(MeetingroomReservationDto r : reservations) {
	        log.info("컨트롤러 DTO: roomId={}, reason={}, start={}, end={}",
	            r.getRoomId(), r.getRoomReservationReason(),
	            r.getRoomReservationStartTime(), r.getRoomReservationEndTime());
	    }
	    */

	    boolean success = reservationService.meetingroomReservation(reservations, userId);

	    return success ? "success" : "등록에 실패했습니다";
	}

	// 예약내역 상세보기
	@GetMapping("/room/detail")
	public RoomDetailDto roomDetail(@RequestParam("roomReservationId") int reservationId) {
		return reservationService.roomDetail(reservationId);
	}
	
	// 예약 취소
	@PostMapping("/room/cancel")
	public String roomCancel(@RequestParam int reservationId) {
		
		// log.info("reservationId: {}", reservationId);
		
		int result = reservationService.roomCancel(reservationId);
		
		if(result > 0) {
	        return "success";
	    } else {
	        return "fail";
	    }
	}
	
}
