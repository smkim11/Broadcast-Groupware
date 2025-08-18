package com.example.broadcastgroupware.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.example.broadcastgroupware.domain.Vehicle;
import com.example.broadcastgroupware.dto.CarReservationDto;
import com.example.broadcastgroupware.dto.PageDto;

@Mapper
public interface ReservationMapper {

	List<CarReservationDto> getCarReservationList(PageDto pageDto);

	int getTotalCount();

	void addCar(Vehicle vehicle);

}
