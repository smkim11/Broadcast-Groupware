package com.example.broadcastgroupware.rest;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.broadcastgroupware.dto.UserCreateDto;
import com.example.broadcastgroupware.mapper.UserCreateMapper;
import com.example.broadcastgroupware.service.UserCreateService;

@RestController
@RequestMapping("/api")
public class UserCreateRestController {
		private final UserCreateMapper userCreateMapper;	// 부서/팀 조회
		private final UserCreateService userCreateService;
		
		public UserCreateRestController(UserCreateMapper userCreateMapper,
											   UserCreateService userCreateService) {
			
			this.userCreateMapper = userCreateMapper;
			this.userCreateService = userCreateService;
		}
		
		// 드롭다운으로 부서 보여주는 용도
		 @GetMapping("/dept-teams")
		    public List<Map<String,Object>> deptTeams() {
		        return userCreateMapper.selectDeptTeamJoined();
		    }
		
		 /** 직급: user 테이블에서 DISTINCT (없으면 기본값으로 대체) */
		    @GetMapping("/ranks")
		    public List<String> ranks() {
		        List<String> list = userCreateMapper.selectRanksFromUsers();
		        if (list == null || list.isEmpty()) {
		            // 사용자 데이터가 아직 없을 때를 대비한 fallback
		            return Arrays.asList("사원","대리","과장","팀장","부서장");
		        }
		        return list;
		    }
		
		// 직원 등록
		@PostMapping("/users")
		public ResponseEntity<Map<String,Object>> createUser(@RequestBody @Validated UserCreateDto dto) {
			// 서비스 로직 수행
			String username = userCreateService.userCreate(dto);
			
			// dto에는 userGeneratedkeys로 userId가 채워져 있음
			Map<String,Object> body = new HashMap<>();
			body.put("userId", dto.getUserId());
			body.put("username", username);
			
			return ResponseEntity.ok(body);
		}
}



















