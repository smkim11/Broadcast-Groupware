package com.example.broadcastgroupware.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.broadcastgroupware.domain.User;

@Mapper
public interface UserCreateMapper {
		// username 시퀀스(yyyy + 부서번호 2자리)
		Integer selectNextSeqByPrefix(@Param("prefix") String prefix);
		
		// 저장
		int isert(@Param("u") User user);
		
		// 모달 셀렉트 박스: 부서/팀
		List<Map<String,Object>> selectDepartments();
		List<Map<String,Object>> slectTeamsByDept(@Param("deptId") int deptId);

		// 팀이 해당 부서 소속인지 검증
		int countTeamInDept(@Param("deptId") int deptId,
							@Param("teamId") int teamId);
		
		// 배치 이력 저장
		int insertDeploymentHistory(@Param("userId") int userId,
									@Param("teamId") int teamId);
		
		
}
