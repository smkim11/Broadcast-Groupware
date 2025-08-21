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

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.domain.VehicleReservation;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.CarToggle;
import com.example.broadcastgroupware.dto.PageDto;
import com.example.broadcastgroupware.dto.ReservationPeriod;
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
	    PageDto pageDto = new PageDto(page, size, totalCount);

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
