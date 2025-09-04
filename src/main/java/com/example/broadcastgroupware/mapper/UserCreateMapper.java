package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.dto.UserCreateDto;

@Mapper
public interface UserCreateMapper {
		// username 시퀀스(yyyy + 부서번호 2자리)
		Integer selectNextSeqByPrefix(@Param("prefix") String prefix);
		
		 // 팀 → 부서ID 역조회 (team.department_id)
	    int selectDepartmentIdByTeamId(@Param("teamId") int teamId);
		
		// 저장
		int insertUser(@Param("u") UserCreateDto user);
		
		// 부서/팀 조인 결과 (대표 제외)
	    List<Map<String, Object>> selectDeptTeamJoined();

	    // user 테이블에서 사용 중인 직급 목록 DISTINCT
	    List<String> selectRanksFromUsers();

		// 팀이 해당 부서 소속인지 검증
		int countTeamInDept(@Param("teamId") int teamId,
							@Param("deptId") int deptId);
		
		// 배치 이력 저장
		int insertDeploymentHistory(@Param("userId") int userId,
									@Param("teamId") int teamId);
		
		
}
