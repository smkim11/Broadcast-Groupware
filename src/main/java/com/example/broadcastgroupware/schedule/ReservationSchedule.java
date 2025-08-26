package com.example.broadcastgroupware.schedule;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.example.broadcastgroupware.service.ReservationService;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class ReservationSchedule {
    private final ReservationService reservationService;

    public ReservationSchedule(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    @Scheduled(cron = "0 0 0 * * *")
    public void modifyCarStatus() {
        int count = reservationService.modifyCarStatus();
        log.info("차량 활성화 건수: {}", count);
    }
}

