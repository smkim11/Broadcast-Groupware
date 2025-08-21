package com.example.broadcastgroupware.rest;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.PageDto;
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
	public Map<String, Object> carList(HttpSession sesstion,
									   @RequestParam(value = "page", defaultValue = "1") int page,
									   @RequestParam(value = "size", defaultValue = "10") int size,
									   @RequestParam(value = "date", required = false) String date,
								        @RequestParam(value = "time", required = false) String time) {

		UserSessionDto loginUser = (UserSessionDto) sesstion.getAttribute("loginUser");

		Map<String, Object> response = new HashMap<>();

		if (loginUser != null) {
			response.put("username", loginUser.getUsername());
			response.put("role", loginUser.getRole());
			response.put("userId", loginUser.getUserId());
		}
		
		java.time.LocalDate today = java.time.LocalDate.now();
	    String todayStr = today.toString();

	    // 오늘 날짜 기준 전체 예약 조회
	    PageDto pageDto = new PageDto(page, size, reservationService.getTotalCountByDate(todayStr));
	    List<CarReservationDto> carReservationList = reservationService.getCarReservationListByDate(todayStr, pageDto);

	    response.put("carReservationList", carReservationList);
	    response.put("pageDto", pageDto);

		return response;
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

	    log.info("=== Ajax로 전달된 차량 정보(차량예약) ===");
	    log.info("userId: {}", vehicleReservation.getUserId());
	    log.info("vehicleId: {}", vehicleReservation.getVehicleId());
	    log.info("vehicleReservationStartTime: {}", vehicleReservation.getVehicleReservationStartTime());
	    log.info("vehicleReservationEndTime: {}", vehicleReservation.getVehicleReservationEndTime());

	    boolean success = reservationService.carReservation(vehicleReservation);

	    if(!success) {
	        return "선택한 시간과 기존 예약이 겹칩니다.";
	    }

	    return "예약 성공";
	}

	
}
