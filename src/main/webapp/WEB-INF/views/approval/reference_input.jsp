<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reference Line</title>
</head>
<body>
<div>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- 페이지 타이틀 -->
            <div class="row align-items-center mb-2">
                <div class="col">
                    <h4 class="mb-0">참조선 지정</h4>
                </div>
            </div>

            <!-- 본문 -->
            <div class="card">
                <div class="card-body">

                    <!-- 상단 탭 -->
					<ul class="nav nav-tabs mb-3">
					    <li class="nav-item">
					        <a class="nav-link active" data-bs-toggle="tab" href="#tab-org">조직도</a>
					    </li>
					    <!--
					    <li class="nav-item">
					        <a class="nav-link" data-bs-toggle="tab" href="#tab-search">검색</a>
					    </li>
					    -->
					</ul>
					
						<div class="row">						
						    <!-- 조직도 / 검색 패널 -->
						    <div class="col-md-5">
						        <div class="tab-content border rounded p-2" style="height: 440px; overflow:auto;">
						        
						            <!-- 조직도 -->
						            <div id="tab-org" class="tab-pane fade show active">
									    <small class="text-muted d-block mb-2">조직도 (체크 후 ▶ 버튼)</small>
									    <ul class="list-unstyled" id="orgTreeBox">
									        <c:forEach var="dept" items="${orgTree}">
									            <li class="mb-2">
									                <a class="text-decoration-none d-inline-flex align-items-center org-toggle"
									                   data-bs-toggle="collapse"
									                   href="#dept-${dept.id}"
									                   role="button"
									                   aria-expanded="true"
									                   aria-controls="dept-${dept.id}">
									                    <span class="me-1 caret" style="display:inline-block; transition:.2s transform;">▾</span>
									                    <i class="uil uil-building me-1"></i> ${dept.name}
									                </a>
									                
									                <!-- 부서: 기본 펼침 -->
									                <ul class="list-unstyled ms-3 mt-1 collapse show" id="dept-${dept.id}">
									                	<%-- dept.users가 없을 때(forEach NPE) 방지 --%>
									                	<c:if test="${not empty dept.users}">
										                    <c:forEach var="team" items="${dept.users}">
										                        <li class="mt-2">
										                            <a class="text-decoration-none d-inline-flex align-items-center org-toggle"
										                               data-bs-toggle="collapse"
										                               href="#team-${dept.id}-${team.id}"
										                               role="button"
										                               aria-expanded="false"
										                               aria-controls="team-${dept.id}-${team.id}">
										                                <span class="me-1 caret" style="display:inline-block; transition:.2s transform;">▸</span>
										                                <i class="uil uil-sitemap me-1"></i> ${team.name}
										                            </a>
										                            
										                            <!-- 팀: 기본 접힘 -->
										                            <ul class="list-unstyled ms-3 mt-1 collapse" id="team-${dept.id}-${team.id}">
										                            	<!-- 팀 자체 참조용 체크박스 -->
										                            	<li class="form-check mb-1">
																	        <input class="form-check-input ref-chk team-chk"
																	               type="checkbox"
																	               id="t${team.id}"
																	               data-type="TEAM"
																	               data-id="${team.id}"
																	               data-team-id="${team.id}"
																	               data-name="${team.name}"
																	               data-dept="${dept.name}"
																	               data-team="${team.name}">
																	        <label class="form-check-label" for="t${team.id}">
																	            👥 팀 전체 참조: ${team.name}
																	        </label>
																	    </li>
										                            
										                                <!-- 팀 소속 사용자 목록 -->
																	    <c:forEach var="user" items="${team.users}">
																	        <li class="form-check">
																	            <input class="form-check-input ref-chk user-chk"
																	                   type="checkbox"
																	                   id="u${user.id}"
																	                   data-type="USER"
																	                   data-id="${user.id}"
																	                   data-team-id="${team.id}"
																	                   data-name="${user.name}"
																	                   data-rank="${user.userRank}"
																	                   data-dept="${dept.name}"
																	                   data-team="${team.name}">
																	            <label class="form-check-label" for="u${user.id}">
																	                👤 ${user.name} <span class="text-muted">(${user.userRank})</span>
																	            </label>
																	        </li>
																	    </c:forEach>
										                            </ul>
										                            
										                        </li>
										                    </c:forEach>
										                </c:if>
									                </ul>
									                
									            </li>
									        </c:forEach>
									    </ul>
									</div>
						
						            <!-- 검색 -->
						            <!--
						            <div id="tab-search" class="tab-pane fade">
						                <div class="input-group">
						                    <input type="text" class="form-control" id="keyword" placeholder="이름/부서/팀 검색">
						                    <button class="btn btn-primary" type="button" id="btnSearch">검색</button>
						                </div>
						                <div class="mt-2" id="searchResultsBox"></div>
						            </div>
						            -->
						            
						        </div>
						    </div>
						
						    <!-- 가운데 이동 버튼 -->
						    <div class="col-md-1 d-flex flex-column align-items-center justify-content-center gap-2">
						        <button type="button" id="btnAdd" class="btn btn-outline-primary">&gt;</button>
						        <button type="button" id="btnRemove" class="btn btn-outline-secondary">&lt;</button>
						        <button type="button" id="btnReset" class="btn btn-outline-danger">&#x21BA;</button>
						    </div>
						
						    <!-- 우측: 결재선 정보 -->
						    <div class="col-md-6">
						        <div class="border rounded p-2" style="height: 440px; overflow:auto;">
						            <table class="table table-sm table-hover align-middle text-center" id="tblLines">
						                <thead class="table-light">
						                    <tr>
						                        <th style="width:8%;">선택</th>
										        <th style="width:12%;">유형</th>  <!-- 개인 / 팀 -->
										        <th style="width:30%;">대상</th>  <!-- 이름 또는 팀명 -->
										        <th style="width:30%;">소속</th>  <!-- 부서 / 팀 (개인일 때만 표시) -->
						                    </tr>
						                </thead>
						                <!-- tbody는 JavaScript에서 동적으로 행(tr) 추가 -->
						                <tbody>
						                	<!-- JS addSelectedRefs() 실행 시 여기에 행이 추가됨 -->
						                </tbody>
						            </table>
						        </div>
						        <small class="text-muted d-block mt-1">※ 참조 대상은 팀 구성원을 포함해 총 50명까지 지정할 수 있습니다.</small>
						    </div>						    
						</div>

                    <!-- 하단 버튼 -->
                    <div class="d-flex justify-content-end gap-2 mt-3">
                        <a href="#" id="btnClose" class="btn btn-outline-secondary">닫기</a>
                        <button type="button" id="btnRefApply" class="btn btn-outline-success">적용</button>
                    </div>
                   
                </div>
            </div>

        </div>
    </div>
</div>

<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>

<script>
	(function () {
        function safeParse(json, fb) {
            if (typeof json !== 'string' || !json.trim()) return fb;
            try { return JSON.parse(json); } catch { return fb; }
        }

        function getTeamSize(teamId) {
            return document.querySelectorAll('.user-chk[data-team-id="' + teamId + '"]').length;
        }
        
        
	    // ===== 조직도(부서/팀) 접기/펼치기 =====
	    function setCaret(el, expanded) {
	        const caret = el.querySelector('.caret');
	        if (!caret) return;
	        caret.textContent = expanded ? '▾' : '▸';
	    }
	
	    // 초기 caret 상태 설정 (부서: 펼침, 팀: 접힘)
	    document.querySelectorAll('a.org-toggle').forEach(a => {
	        const target = document.querySelector(a.getAttribute('href'));
	        const expanded = target && target.classList.contains('show');
	        setCaret(a, expanded);
	    });
	
	    // collapse 이벤트에 맞춰 caret(▾/▸) 자동 전환
	    document.addEventListener('shown.bs.collapse', function (e) {
	        const id = e.target.id;
	        // aria-controls 또는 href로 해당 id를 가리키는 토글 앵커 선택
	        const selector = `a.org-toggle[aria-controls="${id}"], a.org-toggle[href="#${id}"]`;
	        const toggle = document.querySelector(selector);
	        if (!toggle) return;
	        setCaret(toggle, true);
	    });
	
	    document.addEventListener('hidden.bs.collapse', function (e) {
	        const id = e.target.id;
	        const selector = `a.org-toggle[aria-controls="${id}"], a.org-toggle[href="#${id}"]`;
	        const toggle = document.querySelector(selector);
	        if (!toggle) return;
	        setCaret(toggle, false);
	    });

        
        // ===== 참조선 목록 업데이트 로직 =====
        const tblBody = document.querySelector('#tblLines tbody');
        const addBtn = document.getElementById('btnAdd');
        const removeBtn = document.getElementById('btnRemove');
        const resetBtn = document.getElementById('btnReset');
        const applyBtn = document.getElementById('btnRefApply');
        const closeBtn = document.getElementById('btnClose');

        const MAX_TOTAL = 50;  // 총합 50 (팀+개인)
        
     	// 해당 페이지에서 벗어나면 초기화 (기본값)
        sessionStorage.setItem('flowKeep', '0');
        
     	// 전개 기준 총 인원 (선택된 개인 + 선택된 팀의 구성원 수) 계산
        function getExpandedTotalCount() {
            const selectedUsers = tblBody.querySelectorAll('tr[data-type="USER"]').length;
            let teamExpanded = 0;
            tblBody.querySelectorAll('tr[data-type="TEAM"]').forEach(function (tr) {
                const tid = tr.getAttribute('data-id');
                teamExpanded += getTeamSize(tid);
            });
            return selectedUsers + teamExpanded;
        }

        // 추가 버튼 상태 (전개 후 총 인원 기준 50개 선택 시 비활성화)
        function updateAddBtnState() {
		    addBtn.disabled = (getExpandedTotalCount() >= MAX_TOTAL);
		}
        
    	// 팀 선택 시 소속 개인 체크박스 비활성화
        function setTeamUsersDisabled(teamId, disabled) {
            document.querySelectorAll('.user-chk[data-team-id="' + teamId + '"]').forEach(function(chk) {
                if (disabled) chk.checked = false;
                chk.disabled = disabled;
                const label = chk.closest('li.form-check')?.querySelector('label');  // 라벨 흐리게
                if (label) label.classList.toggle('text-muted', disabled);
            });
        }

    	// 해당 팀이 체크된 상태면 개인 선택 불가
        document.addEventListener('change', function(e) {
            if (e.target.classList.contains('team-chk')) {
                const teamId = e.target.dataset.teamId;
                setTeamUsersDisabled(teamId, e.target.checked);
            }
            if (e.target.classList.contains('user-chk')) {
                const teamId = e.target.dataset.teamId;
                const teamChk = document.querySelector('.team-chk[data-team-id="' + teamId + '"]');
                if (teamChk && teamChk.checked) {
                    e.target.checked = false;
                }
            }
        });
    	
     	// 행 추가 (USER / TEAM 공용)
        function appendRow(type, data) {
            // 중복 방지
            if (tblBody.querySelector('tr[data-type="' + type + '"][data-id="' + data.id + '"]')) return;

            const tr = document.createElement('tr');
            tr.setAttribute('data-type', type);        // 'USER' or 'TEAM'
            tr.setAttribute('data-id',   data.id);     // 숫자 ID
            if (data.teamId != null) tr.setAttribute('data-team-id', data.teamId);
            tr.setAttribute('data-name', data.name || '');

            if (type == 'USER') {
                tr.setAttribute('data-rank', data.rank || '');
                tr.setAttribute('data-dept', data.dept || '');
                tr.setAttribute('data-team', data.team || '');
            } else { // TEAM
                tr.setAttribute('data-dept', data.dept || '');
            }

            tr.innerHTML =
                '<td class="text-center"><input type="checkbox" class="row-chk"></td>' +
                '<td class="text-center">' + (type == 'USER' ? '개인' : '팀') + '</td>' +
                '<td class="text-center">' + (type == 'USER'
                    ? (data.name || '') + (data.rank ? ' (' + data.rank + ')' : '')
                    : (data.name || '')
                ) + '</td>' +
                '<td class="text-center"><span class="small text-muted d-inline-block text-truncate" style="max-width: 220px;">' +
                    (data.dept || '') + ((data.dept && data.team) ? ' / ' : '') + (data.team || '') +
                '</span></td>';

            tblBody.appendChild(tr);
            updateAddBtnState();
        }

        // 복원: sessionStorage -> 우측 표 & 좌측 체크박스 복원
        function restoreFromStorage() {
        	const saved = safeParse(sessionStorage.getItem('referenceLines'), []);
            if (!Array.isArray(saved) || saved.length == 0) {
                updateAddBtnState();
                return;
            }
            
            const teams = saved.filter(it => it.teamId != null);
            const users = saved.filter(it => it.userId != null);

            // 팀 먼저 복원
            teams.forEach(function (it) {
                const teamId = String(it.teamId);
                const leftTeam = document.querySelector('.team-chk[data-id="' + teamId + '"]');
                if (leftTeam) {
                    leftTeam.checked = true;
                    setTeamUsersDisabled(teamId, true);  // 팀 체크 시 개인 비활성
                }

                appendRow('TEAM', {
                    id: Number(teamId),
                    name: it.name || '',
                    dept: it.dept || '',
                    teamId: Number(teamId)
                });
            });
            
            // 개인 복원 (팀이 이미 선택된 경우는 패스)
            users.forEach(function (it) {
            	const userId = String(it.userId);
                const leftUser = document.querySelector('.user-chk[data-id="' + userId + '"]');
                    
             	// 소속 팀ID는 좌측 체크박스의 data-team-id에서 읽어 옴
                const teamId = leftUser ? (leftUser.dataset.teamId || '') : '';
                
                // 팀이 이미 체크돼 있으면 개인은 비활성/해제
                if (teamId && tblBody.querySelector('tr[data-type="TEAM"][data-id="' + teamId + '"]')) {
	                if (leftUser) {
	                    leftUser.checked = false;
	                    leftUser.disabled = true;
	                }
	                return;
             	}
	
                if (leftUser) leftUser.checked = true;

                appendRow('USER', {
                    id: Number(userId),
                    name: it.name || '',
                    rank: it.userRank || '',
                    dept: it.dept || '',
                    team: it.team || '',
                    teamId: teamId ? Number(teamId) : undefined  // 삭제/제한용 (우측 tr에만 보관) | 저장(JSON) 제외
                });
            });

            updateAddBtnState();
        }
        
        // 좌측에서 선택된 참조 대상들을 우측 테이블에 추가 (중복 방지 + 상한 제한)
        function addSelectedRefs() {
            const checked = Array.from(document.querySelectorAll('.ref-chk:checked'));
            if (!checked.length) return;
            
            // 현재 전개 기준 총 인원
            let baseExpanded = getExpandedTotalCount();

            let totalAtLimit = false;  		// 전개 기준 상한 초과
            let userBlockedByTeam = false;  // 팀 선택 시 개인 추가 차단

            for (const chk of checked) {
                const type = chk.dataset.type;  // USER | TEAM
                const id = chk.dataset.id;
                const name = chk.dataset.name || '';
                const rank = chk.dataset.rank || '';
                const dept = chk.dataset.dept || '';
                const team = chk.dataset.team || '';
                const teamId = chk.dataset.teamId || '';

                // 중복 확인: 이미 추가된 참조자면 패스
                if (tblBody.querySelector('tr[data-type="' + type + '"][data-id="' + id + '"]')) {
                    chk.checked = false;
                    continue;
                }
                
             	// 팀이 이미 선택된 경우 개인 선택 불가
                if (type == 'USER' && teamId) {
                    const existsTeamRow = tblBody.querySelector('tr[data-type="TEAM"][data-id="' + teamId + '"]');
                    if (existsTeamRow) {
                        chk.checked = false;
                        if (!userBlockedByTeam) {
                            alert('해당 팀이 참조로 추가되어 개인을 별도로 선택할 수 없습니다.');
                            userBlockedByTeam = true;
                        }
                        continue;
                    }
                }
             	
             	// 전개 기준 상한 계산
                let wouldBeExpanded = baseExpanded;
             	
                if (type == 'USER') {
                    wouldBeExpanded = baseExpanded + 1;  // 개인 1명 추가
                } else if (type == 'TEAM' && teamId) {
                    // 팀 참조 추가 시 해당 팀 개인 참조 제거 -> 그 수만큼 제외 후 팀 전체 인원 추가
                    const currentTeamUsersSelected =
                        tblBody.querySelectorAll('tr[data-type="USER"][data-team-id="' + teamId + '"]').length;

                    const teamSize = getTeamSize(teamId);
                    wouldBeExpanded = baseExpanded - currentTeamUsersSelected + teamSize;
                }

                if (wouldBeExpanded > MAX_TOTAL) {
                    totalAtLimit = true;
                    chk.checked = false;
                    continue;
                }
             	
             	// 팀 추가 시 개인 제거 -> 좌측 체크 해제/비활성
                if (type == 'TEAM' && teamId) {
                    const currentTeamUsersSelected =
                        tblBody.querySelectorAll('tr[data-type="USER"][data-team-id="' + teamId + '"]').length;

                    tblBody.querySelectorAll('tr[data-type="USER"][data-team-id="' + teamId + '"]').forEach(tr => tr.remove());
                    document.querySelectorAll('.user-chk[data-team-id="' + teamId + '"]').forEach(chkUser => chkUser.checked = false);
                    setTeamUsersDisabled(teamId, true);

                    // base 업데이트
                    baseExpanded -= currentTeamUsersSelected;
                    baseExpanded += getTeamSize(teamId);
                } else if (type == 'USER') {
                    baseExpanded += 1;
                }
             
                // 행 추가
                appendRow(type, {
                    id: Number(id),
                    name,
                    rank,
                    dept,
                    team,
                    teamId: teamId ? Number(teamId) : undefined
                });

                // 좌측 체크 해제
                chk.checked = false;
            }

            if (totalAtLimit) alert('참조 대상은 팀 구성원을 포함해 총 ' + MAX_TOTAL + '명을 초과할 수 없습니다.');

            updateAddBtnState();
        }
        
        
        // 체크된 참조자 행 삭제
        function removeSelectedRows() {
            const rows = Array.from(tblBody.querySelectorAll('input.row-chk:checked'))
                .map(chk => chk.closest('tr'));

            rows.forEach(tr => {
                const type = tr.getAttribute('data-type');
                const id   = tr.getAttribute('data-id');
                
             	// 좌측 체크박스도 해제
                if (type == 'TEAM') {
                    const leftTeam = document.querySelector('.team-chk[data-id="' + id + '"]');
                    if (leftTeam) {
                        leftTeam.checked = false;
                        setTeamUsersDisabled(id, false);  // 개인 다시 활성화
                    }
                } else {  // USER
                    const leftUser = document.querySelector('.user-chk[data-id="' + id + '"]');
                    if (leftUser) leftUser.checked = false;
                }

                tr.remove();
            });

            updateAddBtnState();
        }

        
        // 참조자 전체 초기화
        function resetAll() {
            tblBody.innerHTML = '';
            document.querySelectorAll('.ref-chk:checked').forEach(function(chk){ chk.checked = false; });
            document.querySelectorAll('.team-chk').forEach(function(teamChk) {
                setTeamUsersDisabled(teamChk.dataset.teamId, false);
            });
            updateAddBtnState();
        }

        // 체크 시 행 강조
        tblBody.addEventListener('change', function (e) {
            if (!e.target.classList.contains('row-chk')) return;
            const tr = e.target.closest('tr');
            if (!tr) return;
            tr.classList.toggle('table-active', e.target.checked);
        });

        
        // 선택한 참조선 저장 후 이전 페이지로 이동
        function applySelection() {
            // 현재 테이블의 모든 행 수집
            const rows = tblBody.querySelectorAll('tr');
            
            if (rows.length == 0) {
                alert('참조 대상을 최소 1개 이상 선택해 주세요.');
                return;
            }
            
            // 최종 검증
            const expanded = getExpandedTotalCount();
            if (expanded > MAX_TOTAL) {
                alert('참조 대상은 팀 구성원을 포함해 총 ' + MAX_TOTAL + '명을 초과할 수 없습니다.');
                return;
            }
                
            // 선택된 행들을 전송/저장용 데이터로 변환
            const list = Array.from(rows).map(function(tr){
		        const type = tr.getAttribute('data-type');  // USER or TEAM
		        const id = parseInt(tr.getAttribute('data-id'), 10);
		        const teamId = tr.getAttribute('data-team-id');
		
		        if (type == 'USER') {
		        	return {
                        userId: id,
                        name: tr.getAttribute('data-name') || '',
                        userRank: tr.getAttribute('data-rank') || '',
                        dept: tr.getAttribute('data-dept') || '',
                        team: tr.getAttribute('data-team') || ''
                    };
                }
		        
		        if (type == 'TEAM') {
		            return {
		                teamId: id,
		                name: tr.getAttribute('data-name') || '',
		                dept: tr.getAttribute('data-dept') || ''
		            };
		        }
		        return null;  	 // 방어코드
		    }).filter(Boolean);  // falsy(null/undefined/false/0/NaN/"") 제거
            
            // 작성 페이지에서 읽을 sessionStorage에 저장
           	sessionStorage.setItem('referenceLines', JSON.stringify(list));
    		sessionStorage.setItem('flowKeep', '1');  // 작성 페이지로 돌아갈 경우 유지
            
            // 뒤로가기
            history.back();
        }

        // 버튼 바인딩
        addBtn.addEventListener('click', addSelectedRefs);
        removeBtn.addEventListener('click', removeSelectedRows);
        resetBtn.addEventListener('click', resetAll);
        applyBtn.addEventListener('click', applySelection);
        
        closeBtn.addEventListener('click', function (e) {
            e.preventDefault();
            sessionStorage.setItem('flowKeep', '1');  // 작성 페이지로 돌아갈 경우 유지
            history.back();  // 뒤로가기
        });
        
     	// 작성 페이지로 돌아가는 경우가 아니면 선택값 초기화
        window.addEventListener('pagehide', () => {
            const keep = sessionStorage.getItem('flowKeep') == '1';
            sessionStorage.setItem('flowKeep', '0');
            if (keep) return;  // 작성 페이지 복귀 -> 유지

            // 플로우 이탈 -> 초기화
            sessionStorage.removeItem('approvalLines');
            sessionStorage.removeItem('referenceLines');
        });
        
        updateAddBtnState();   // 초기 로드 시 추가 버튼 상태 초기화
        restoreFromStorage();  // sessionStorage 값 복원
    })();
</script>

</body>
</html>