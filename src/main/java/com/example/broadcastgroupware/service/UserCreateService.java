package com.example.broadcastgroupware.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.example.broadcastgroupware.dto.UserCreateDto;
import com.example.broadcastgroupware.mapper.UserCreateMapper;

@Service
public class UserCreateService {
		private final UserCreateMapper userCreateMapper;
		private final PasswordEncoder passwordEncoder;	// 현재 NoOp평문, 추후 BCypt 전환
		
		public UserCreateService(UserCreateMapper userCreateMapper,
								 PasswordEncoder passwordEncoder) {
			this.userCreateMapper = userCreateMapper;
			this.passwordEncoder = passwordEncoder;
		}
		
		/*
		 * 직원 생성 흐름(UserCreateDto 사용)
		 * 1. 입력 검증 (teamId, 이름, 입사일 등)
		 * 2. deptId 확보 (화면이 주면 사용, 아니면 teamId로 역조회)
		 * 3. username = 입사연도(yyyy) + 부서Id(2자리 0패딩) + 일련(3자리 0패딩)
		 * 4. 초기비밀번호 = 생년월일 (Y Y M M D D + 세대구분) -> yyyyMMdd (실패시 임시)
		 * 5. user insert 
		 * 6. deployment_history insert (user_id, team_id)*/
		
		
		
		
		@Transactional
		public String userCreate(UserCreateDto dto) {
		    // 0) 입력값 최소 검증
		    if (dto.getTeamId() <= 0) throw new IllegalArgumentException("팀을 선택하세요.");
		    if (dto.getFullName() == null || dto.getFullName().isBlank())
		        throw new IllegalArgumentException("이름을 입력하세요.");

		    // 1) 팀의 실제 부서ID 역조회 → DTO 보정
		    Integer realDeptId = userCreateMapper.selectDepartmentIdByTeamId(dto.getTeamId());
		    if (realDeptId == null) {
		        throw new IllegalArgumentException("선택한 팀이 존재하지 않습니다. (teamId=" + dto.getTeamId() + ")");
		    }

		    // 화면에서 온 deptId가 0이거나 다른 경우, DB 것을 신뢰하여 덮어씌움
		    if (dto.getDeptId() <= 0 || dto.getDeptId() != realDeptId) {
		        System.out.printf("[UserCreate] deptId 보정: req=%d -> db=%d (teamId=%d)%n",
		                dto.getDeptId(), realDeptId, dto.getTeamId());
		        dto.setDeptId(realDeptId);
		    }

		    // 2) 최종 검증(이제 반드시 1이 나와야 정상)
		    int cnt = userCreateMapper.countTeamInDept(dto.getTeamId(), dto.getDeptId());
		    if (cnt == 0) {
		        // 디버그를 돕는 상세 메시지 (문제 재발 시 로그로 바로 확인)
		        throw new IllegalArgumentException(
		            "선택한 팀은 해당 부서에 속하지 않습니다. (teamId=" + dto.getTeamId() +
		            ", reqDeptId=" + dto.getDeptId() + ", realDeptId=" + realDeptId + ")"
		        );
		    }

		    // ---- 이하 기존 로직(아이디 prefix/username 생성, 초기비번 자동 생성, insert, 배치이력) 그대로 ----
		    // username prefix
		    String yy     = LocalDate.now().format(DateTimeFormatter.ofPattern("yy"));
		    String dept02 = String.format("%02d", dto.getDeptId());
		    String prefix = yy + dept02; // 언더스코어 제거

		    // 초기 비밀번호 자동 생성 (너가 쓰던 규칙)
		    String sn1 = dto.getUserSn1() == null ? "" : dto.getUserSn1().replaceAll("\\D", "");
		    String sn2 = dto.getUserSn2() == null ? "" : dto.getUserSn2().replaceAll("\\D", "");
		    String toStorePassword;
		    if (sn1.length() == 8) {
		        toStorePassword = sn1;
		    } else if (sn1.length() == 6 && sn2.length() >= 1) {
		        char f = sn2.charAt(0);
		        if ("1256".indexOf(f) >= 0)      toStorePassword = "19" + sn1;
		        else if ("3478".indexOf(f) >= 0) toStorePassword = "20" + sn1;
		        else                              toStorePassword = "Temp1234!";
		    } else {
		        toStorePassword = "Temp1234!";
		    }
		    // [암호화 주입] 전환 시 한 줄만 해제
		    // toStorePassword = passwordEncoder.encode(toStorePassword);
		    dto.setPassword(toStorePassword);

		    // username 생성 & insert(경합 재시도)
		    String finalUsername = null;
		    int attempts = 0;
		    while (attempts++ < 3) {
		        Integer next = userCreateMapper.selectNextSeqByPrefix(prefix);
		        if (next == null || next <= 0) next = 1;
		        String candidate = prefix + String.format("%03d", next);
		        dto.setUsername(candidate);
		        try {
		            userCreateMapper.insertUser(dto); // useGeneratedKeys 로 userId 세팅
		            finalUsername = candidate;
		            break;
		        } catch (org.springframework.dao.DuplicateKeyException e) {
		            if (attempts >= 3) throw e;
		        }
		    }
		    if (dto.getUserId() <= 0 || finalUsername == null) {
		        throw new IllegalStateException("사용자 생성에 실패했습니다.");
		    }

		    userCreateMapper.insertDeploymentHistory(dto.getUserId(), dto.getTeamId());
		    return finalUsername;
		}
}
