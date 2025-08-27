<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Approval Line</title>
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
                    <h4 class="mb-0">결재선 지정</h4>
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
									    <ul class="list-unstyled" id="orgTree">
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
									                                <c:forEach var="user" items="${team.users}">
									                                    <li class="form-check">
									                                        <input class="form-check-input user-chk"
							                                               		type="checkbox"
								                                               	id="u${user.id}"
								                                               	data-user-id="${user.id}"
								                                               	data-user-name="${user.name}"
								                                               	data-user-pos="${user.userRank}"
								                                              	data-user-dept="${dept.name}"
																				data-user-team="${team.name}">
									                                        <label class="form-check-label" for="u${user.id}">
									                                            👤 ${user.name} <span class="text-muted">(${user.userRank})</span>
									                                        </label>
									                                    </li>
									                                </c:forEach>
									                            </ul>
									                            
									                        </li>
									                    </c:forEach>
									                </ul>
									                
									            </li>
									        </c:forEach>
									    </ul>
									</div>
						
						            <!-- 검색 -->
						            <!--
						            <div id="tab-search" class="tab-pane fade">
						                <div class="input-group">
						                    <input type="text" class="form-control" id="keyword" placeholder="이름/부서 검색">
						                    <button class="btn btn-primary" type="button" id="btnSearch">검색</button>
						                </div>
						                <ul class="list-unstyled mt-2" id="searchResults"></ul>
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
										        <th style="width:8%;">순서</th>
										        <th style="width:10%;">유형</th>   <!-- 결재 -->
										        <th style="width:28%;">결재자</th>  <!-- 이름 (직급) -->
										        <th style="width:26%;">소속</th>   <!-- 부서 / 팀 -->
										        <th style="width:10%;">이동</th>
						                    </tr>
						                </thead>
						                <!-- tbody는 JavaScript에서 동적으로 행(tr) 추가 -->
						                <tbody>
						                	<!-- JS addSelectedRefs() 실행 시 여기에 행이 추가됨 -->
						                </tbody>
						            </table>
						        </div>
						        <small class="text-muted d-block mt-2">※ 순서는 ▲/▼ 버튼으로 조정합니다.</small>
						        <small class="text-muted d-block mt-2">※ 결재선은 최대 3명까지 선택 가능합니다.</small>
						    </div>						    
						</div>

                    <!-- 하단 버튼 -->
                    <div class="d-flex justify-content-end gap-2 mt-3">
                        <a href="#" id="btnClose" class="btn btn-outline-secondary">닫기</a>
                        <button type="button" id="btnApply" class="btn btn-outline-success">적용</button>
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
   
        
     	// ===== 결재선 목록 업데이트 로직 =====
        const tblBody = document.querySelector('#tblLines tbody');
        const addBtn = document.getElementById('btnAdd');
        const removeBtn = document.getElementById('btnRemove');
        const resetBtn = document.getElementById('btnReset');
        const applyBtn = document.getElementById('btnApply');
        const closeBtn = document.getElementById('btnClose');
        
        const MAX_APPROVERS = 3;  // 최대 3명
        
        // 해당 페이지에서 벗어나면 초기화 (기본값)
        sessionStorage.setItem('flowKeep', '0');

        
     	// 현재 표시 순서대로 결재 순서 재할당
        function refreshOrder() {
            const rows = tblBody.querySelectorAll('tr');
            rows.forEach((tr, idx) => tr.querySelector('.seq').innerText = (idx + 1));
        }
        
     	// 추가 버튼 상태 (3명 선택 시 비활성화)
        function updateAddBtnState() {
            const count = tblBody.querySelectorAll('tr').length;
            addBtn.disabled = (count >= MAX_APPROVERS);
        }
     	
     	
     	// 공통: 우측 표에 행 추가
        function appendRow(uid, name, pos, dept, team) {
            if (tblBody.querySelector('tr[data-user-id="' + uid + '"]')) return;  // 중복 방지
            
            const tr = document.createElement('tr');
            tr.setAttribute('data-user-id', uid);
            tr.setAttribute('data-user-name', name || '');
            tr.setAttribute('data-user-pos',  pos  || '');
            tr.setAttribute('data-user-dept', dept || '');
            tr.setAttribute('data-user-team', team || '');
            
            tr.innerHTML =
                '<td class="text-center"><input type="checkbox" class="row-chk"></td>' +
                '<td class="text-center seq"></td>' +
                '<td class="text-center">결재</td>' +
                '<td>' + (name || '') + (pos ? ' <span class="text-muted">(' + pos + ')</span>' : '') + '</td>' +
                '<td class="text-center">' +
                    '<span class="small text-muted d-inline-block text-truncate" style="max-width: 220px;">' +
                        (dept || '') + ' / ' + (team || '') +
                    '</span>' +
                '</td>' +
                '<td class="text-center">' +
                    '<div class="btn-group btn-group-sm" role="group">' +
                        '<button type="button" class="btn btn-outline-primary btn-up" style="font-size:0.53rem;">▲</button>' +
                        '<button type="button" class="btn btn-outline-primary btn-down" style="font-size:0.55rem;">▼</button>' +
                    '</div>' +
                '</td>';
                
            tblBody.appendChild(tr);
            refreshOrder();
            updateAddBtnState();  // 인원 제한 버튼 상태 즉시 반영
        }
        
        // 복원: sessionStorage -> 우측표 & 좌측 체크박스
        function restoreFromStorage() {
            const saved = JSON.parse(sessionStorage.getItem('approvalLines') || '[]');

            if (!Array.isArray(saved) || saved.length === 0) {
                updateAddBtnState();
                return;
            }

            const sliced = saved
	            .slice()  // 원본 보존
	            .sort((a, b) => (a.approvalLineSequence || 999) - (b.approvalLineSequence || 999))
	            .slice(0, MAX_APPROVERS);
	
	        sliced.forEach(it => {
	            const uid  = it.userId;
	            const name = it.name || '';
	            const pos  = it.userRank || '';
	            const dept = it.dept || '';
	            const team = it.team || '';
	
	            // 좌측 체크박스 체크
	            const leftChk = document.querySelector('.user-chk[data-user-id="' + uid + '"]');
	            if (leftChk) leftChk.checked = true;
	
	            // 우측 표 행 추가
	            appendRow(uid, name, pos, dept, team);
	        });
	        
	        refreshOrder();
	        updateAddBtnState();
	    }
        
     	
     	// 좌측에서 선택된 사용자들을 우측 테이블에 추가 (중복 방지 + 3명 제한)
        function addSelectedUsers() {
            const checked = Array.from(document.querySelectorAll('.user-chk:checked'));
            if (!checked.length) return;

            const existing = tblBody.querySelectorAll('tr').length;
            const remaining = MAX_APPROVERS - existing;

            if (remaining <= 0) {
                alert('결재선은 최대 3명까지만 추가할 수 있습니다.');
                checked.forEach(chk => (chk.checked = false));
                return;
            }

            let added = 0;
            let blockedByLimit = false;  // 최대 인원 초과로 추가하지 못한 결재자 존재 여부
            
         	// for...of 반복문: 배열(checked)을 순회하며 요소를 하나씩 처리
            for (const chk of checked) {
                const uid  = chk.getAttribute('data-user-id');
                const name = chk.getAttribute('data-user-name');
                const pos = chk.getAttribute('data-user-pos');
                const dept = chk.getAttribute('data-user-dept') || '';
                const team = chk.getAttribute('data-user-team') || '';

                // 중복 확인: 이미 추가된 결재자면 패스
                if (tblBody.querySelector('tr[data-user-id="' + uid + '"]')) {
                    chk.checked = false;
                    continue;
                }

             	// 최대 인원 미만일 때만 추가
                if (added < remaining) {
                	appendRow(uid, name, pos, dept, team);
                    added++;
                } else {
                    blockedByLimit = true;  // 정원 초과로 추가 누락(중복 제외)
                }

                // 좌측 체크 해제
                chk.checked = false;
            }
            
            if (blockedByLimit) {
                alert('결재선은 최대 3명까지만 추가할 수 있습니다.');
            }
            
            refreshOrder();
            updateAddBtnState();
        }

     	
     	// 체크된 결재자 행 삭제
        function removeSelectedRows() {
            const rows = Array.from(tblBody.querySelectorAll('input.row-chk:checked'))
            .map(chk => chk.closest('tr'));

	        rows.forEach(tr => {
	            const uid = tr.getAttribute('data-user-id');
	            // 좌측 체크박스도 해제
	            const leftChk = document.querySelector('.user-chk[data-user-id="' + uid + '"]');
	            if (leftChk) leftChk.checked = false;
	            tr.remove();
        	});

	        refreshOrder();
	        updateAddBtnState();
	    }

        // 결재자 전체 초기화
        function resetAll() {
            tblBody.innerHTML = '';
            document.querySelectorAll('.user-chk:checked').forEach(chk => chk.checked = false);
            refreshOrder();
            updateAddBtnState();
        }

        // 체크 시 행 강조
		tblBody.addEventListener('change', function (e) {
		    if (!e.target.classList.contains('row-chk')) return;
		    const tr = e.target.closest('tr');
		    if (!tr) return;
		    tr.classList.toggle('table-active', e.target.checked);
		});

        // 순서 위/아래 이동
        tblBody.addEventListener('click', function (e) {
            if (e.target.classList.contains('btn-up')) {
                const tr = e.target.closest('tr');
                if (tr.previousElementSibling) {
                    tblBody.insertBefore(tr, tr.previousElementSibling);
                    refreshOrder();
                }
            }
            if (e.target.classList.contains('btn-down')) {
                const tr = e.target.closest('tr');
                if (tr.nextElementSibling) {
                    tblBody.insertBefore(tr.nextElementSibling, tr);
                    refreshOrder();
                }
            }
        });

        
     	// 선택한 결재선 저장 후 이전 페이지로 이동
        function applySelection() {
        	// 현재 테이블의 모든 행 수집
            const rows = tblBody.querySelectorAll('tr');
            
            if (rows.length == 0) {
           		alert('결재선을 최소 1명 이상 선택해 주세요.');
                return;
          	}
            
       	  	if (rows.length > MAX_APPROVERS) {
       	       	alert('결재선은 최대 3명까지 선택 가능합니다.');
       	      	return;
       	   	}
            	
       		// 선택된 행들을 전송/저장용 데이터로 변환
            const list = Array.from(rows).map((tr, idx) => ({
            	userId: parseInt(tr.getAttribute('data-user-id'), 10),  // 선택 사용자 ID
		        approvalLineSequence: idx + 1,							// 현재 행의 순서 (1부터 시작)
		        name: tr.getAttribute('data-user-name') || '',
		        userRank: tr.getAttribute('data-user-pos') || '',
		        dept: tr.getAttribute('data-user-dept') || '',
		        team: tr.getAttribute('data-user-team') || ''
		    }));
            
         	// 작성 페이지에서 읽을 sessionStorage에 저장
           	sessionStorage.setItem('approvalLines', JSON.stringify(list));
    		sessionStorage.setItem('flowKeep', '1');  // 작성 페이지로 돌아갈 경우 유지
            
         	// 뒤로가기
            history.back();
        }

        // 버튼 바인딩
        addBtn.addEventListener('click', addSelectedUsers);
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
            if (keep) return;  // 작성 페이지로 복귀 -> 유지

            // 플로우 이탈 -> 초기화
            sessionStorage.removeItem('approvalLines');
            sessionStorage.removeItem('referenceLines');
        });
        
     	// sessionStorage 값 복원
        restoreFromStorage();
    })();
</script>

</body>
</html>