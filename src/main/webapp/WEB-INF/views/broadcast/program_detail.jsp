<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Program Detail</title>
</head>
<body>
<div>
    <jsp:include page="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- 페이지 타이틀 -->
            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">방송편성 상세</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item"><a href="javascript:void(0);">방송편성</a></li>
                                <li class="breadcrumb-item active">상세</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 상세 카드 -->
			<div class="card">
			    <div class="card-body">
			    
			        <div class="d-flex justify-content-between align-items-start mb-3">
			            <h5 class="mb-1">
			                <c:out value="${program.broadcastFormName}"/> 상세 정보
			            </h5>
			            <a href="${pageContext.request.contextPath}/broadcast/list"
			               class="btn btn-sm btn-outline-secondary">
			                목록
			            </a>
			        </div>
			
			        <div class="table-responsive">
			            <table class="table table-bordered align-middle mb-0">
			                <colgroup>
			                    <col style="width:22%;">
			                    <col>
			                </colgroup>
			                <tbody>
			                    <tr>
			                        <th class="bg-light text-center">프로그램명</th>
			                        <td><c:out value="${program.broadcastFormName}"/></td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">방영 기간</th>
			                        <td>
			                            <c:out value="${fn:substring(program.broadcastFormStartDate,0,10)}"/> ~
			                            <c:out value="${fn:substring(program.broadcastFormEndDate,0,10)}"/>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">방영 요일</th>
			                        <td>
			                            <c:out value="${empty program.broadcastDaysText ? '-' : program.broadcastDaysText}"/>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">방영 시간</th>
			                        <td>
			                            <c:out value="${fn:substring(program.broadcastFormStartTime,0,5)}"/> ~
			                            <c:out value="${fn:substring(program.broadcastFormEndTime,0,5)}"/>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">회차</th>
			                        <td class="d-flex justify-content-between align-items-center">
			                            <span>
			                                <c:out value="${empty program.episodesCount ? '-' : program.episodesCount}"/>
			                            </span>
			                            <a href="${pageContext.request.contextPath}/broadcast/episodes?formId=${program.broadcastFormId}">
			                                회차 상세 보기
			                            </a>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">대표자</th>
			                        <td class="d-flex justify-content-between align-items-center">
			                            <span>
			                                <c:out value="${empty program.fullName ? '-' : program.fullName}"/>
			                                <span class="text-muted ms-2">(담당 인원: <c:out value="${program.broadcastFormCapacity}"/>명)</span>
			                            </span>
			                            <a href="#team-card" class="link-primary" id="btnOpenTeam">팀원 보기</a>
			                        </td>
			                    </tr>
			                </tbody>
			            </table>
			        </div>
			    </div>
			</div>
			
			<!-- 팀원 카드 -->
			<div class="card mt-3 d-none" id="team-card" data-loaded="0"
			     data-schedule-id="${program.broadcastScheduleId}">
			    <div class="card-body">
			    	<!-- 헤더: 제목 + (사용자가 대표자인 경우) 등록/삭제 -->
			        <div class="d-flex justify-content-between align-items-center mb-2">
			            <div class="d-flex align-items-center gap-3">
			                <h5 class="mb-0">프로그램 팀원 목록</h5>
			            </div>
			            <div class="d-flex gap-2">
			                <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.userId == program.userId}">
							    <button type="button" class="btn btn-sm btn-outline-success"
							            data-bs-toggle="modal" data-bs-target="#teamAddModal">등록</button>
							    <button type="button" class="btn btn-sm btn-outline-danger" id="btnDeleteChecked" disabled>삭제</button>
							</c:if>
			            </div>
			        </div>
			
					<!-- 본문: 테이블 -->
			        <div class="table-responsive">
			            <table class="table table-hover align-middle mb-0">
			                <colgroup>
			                    <col style="width:56px;">
			                    <col style="width:80px;">
			                    <col style="width:20%;">
			                    <col style="width:16%;">
			                    <col style="width:22%;">
			                    <col style="width:22%;">
			                </colgroup>
			                <thead>
			                    <tr class="text-center">
			                        <th>선택</th>
			                        <th>번호</th>
			                        <th>팀원 명</th>
			                        <th>직급</th>
			                        <th>소속 부서</th>
			                        <th>소속 팀</th>
			                    </tr>
			                </thead>
			                <tbody id="teamBody">
			                    <tr></tr>
			                </tbody>
			            </table>
			        </div>
			
			        <div class="d-flex justify-content-center mt-3">
			            <ul id="teamPaging" class="pagination pagination-sm mb-0"></ul>
			        </div>
			    </div>
			</div>
			
			<!-- 팀원 등록 모달 -->
			<div class="modal fade" id="teamAddModal" tabindex="-1" aria-hidden="true">
			    <div class="modal-dialog modal-md">
			        <div class="modal-content">
			            <div class="modal-header">
			                <h5 class="modal-title">팀원 등록</h5>
			                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
			            </div>
			            <div class="modal-body">
			                <form id="teamAddForm">
			                    <input type="hidden" name="formId" value="${program.broadcastFormId}"/>
			                    <div class="mb-2">
			                        <label class="form-label small">소속 부서</label>
			                        <select class="form-select" id="deptSelect"></select>
			                    </div>
			                    <div class="mb-2">
			                        <label class="form-label small">소속 팀</label>
			                        <select class="form-select" id="teamSelect"></select>
			                    </div>
			                    <div class="mb-2">
			                        <label class="form-label small">이름</label>
			                        <select class="form-select" id="userSelect"></select>
			                    </div>
			                    <div class="mb-2">
			                        <label class="form-label small">직급</label>
			                        <input type="text" class="form-control" id="rankInput"/>
			                    </div>
			                </form>
			                <div class="small text-muted">부서/팀 선택 후 이름을 선택하세요.</div>
			            </div>
			            <div class="modal-footer">
			                <button class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
			                <button class="btn btn-outline-success" id="btnTeamSave">확인</button>
			            </div>
			        </div>
			    </div>
			</div>
	        
        </div>
    </div>
</div>

<div>
    <jsp:include page="../nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page="../nav/javascript.jsp"></jsp:include>
</div>

<script>
    (function () {
        const ctx = '${pageContext.request.contextPath}';  		 // 컨텍스트 경로
        const teamCard = document.getElementById('team-card'); 	 // 팀원 카드 (토글 대상)
        const btnOpen = document.getElementById('btnOpenTeam');  // "팀원 보기" 링크
        const tbody = document.getElementById('teamBody'); 		 // 팀원 목록 tbody
        const pagingEl = document.getElementById('teamPaging');  // 페이징 영역(ul)
        const btnDeleteChecked = document.getElementById('btnDeleteChecked');  // 팀원 삭제 버튼

        const scheduleId = teamCard ? teamCard.getAttribute('data-schedule-id') : null;
        let currentPage = 1;
        const pageSize = 10;
        let totalCount = 0;

        // 팀원 보기 버튼
        btnOpen && btnOpen.addEventListener('click', function (e) {
            e.preventDefault();  // 기본 링크 동작 막기
            if (teamCard.classList.contains('d-none')) {
                teamCard.classList.remove('d-none');  // 카드 표시
            }
            if (teamCard.getAttribute('data-loaded') !== '1') {
                loadTeamPage(1);  // 최초 1회 목록 로드
                teamCard.setAttribute('data-loaded', '1');
            }
            setTimeout(function () {
                teamCard.scrollIntoView({ behavior: 'smooth', block: 'start' });  // 스크롤 이동
            }, 0);
        });

        // 팀원 목록 로드
        function loadTeamPage(page) {
            currentPage = page;
            // 로딩 상태 표시
            tbody.innerHTML =
                '<tr>' +
                    '<td colspan="6" class="text-center text-muted py-4">불러오는 중…</td>' +
                '</tr>';

            // 서버 호출 URL
            var url = ctx + '/broadcast/team/list?scheduleId=' + encodeURIComponent(scheduleId)
                    + '&page=' + page + '&size=' + pageSize;

            fetch(url, { headers: { 'Accept': 'application/json' } })
                .then(function (res) {
                    if (!res.ok) throw new Error('통신 오류');
                    return res.json();  // JSON 파싱
                })
                .then(function (data) {
                    totalCount = data.totalCount || 0;  			  // 전체 개수 저장
                    renderRows(data.rows || [], data.beginRow || 1);  // 행 렌더링
                    renderPaging(totalCount, page, pageSize);		  // 페이징 렌더링
                    toggleDeleteSelectedButton(); 					  // 삭제 버튼 상태 토글
                })
                .catch(function (e) {
                    // 실패 시 에러 메시지 표시
                    tbody.innerHTML =
                        '<tr>' +
                            '<td colspan="6" class="text-center text-muted py-4">목록을 불러오지 못했습니다</td>' +
                        '</tr>';
                    console.error(e);
                });
        }

        // 팀원 목록 행 렌더링
        function renderRows(rows, beginRow) {
            if (!rows.length) {
                // 팀원이 없을 때 메시지 표시
                tbody.innerHTML =
                    '<tr>' +
                        '<td colspan="6" class="text-center text-muted py-4">등록된 팀원이 없습니다</td>' +
                    '</tr>';
                return;
            }

            // rows를 <tr>로 변환
            var html = rows.map(function (r, idx) {
                var no = beginRow + idx;
                var rowId = safe(r.broadcastTeamId);

                return '' +
	                '<tr data-id="' + rowId + '">' +
	                    '<td class="text-center"><input type="checkbox" class="row-check" /></td>' +
	                    '<td class="text-center">' + no + '</td>' +
	                    '<td class="text-center">' + esc(r.fullName) + '</td>' +
	                    '<td class="text-center">' + esc(r.userRank || '-') + '</td>' +
	                    '<td class="text-center">' + esc(r.departmentName || '-') + '</td>' +
	                    '<td class="text-center">' + esc(r.teamName || '-') + '</td>' +
	                '</tr>';
            }).join('');

            tbody.innerHTML = html;

            // 각 체크박스 이벤트 등록
            Array.prototype.forEach.call(tbody.querySelectorAll('.row-check'), function (chk) {
                chk.addEventListener('change', function () {
                	toggleDeleteSelectedButton();  // 체크 변경 시 삭제 버튼 상태 갱신
                });
            });
        }

        // 페이징 렌더링
        function renderPaging(total, page, size) {
            var totalPage = Math.max(1, Math.ceil(total / size));  // 총 페이지 수 계산

            // 페이징 항목 HTML 생성
            function item(p, t, dis, act) {
                return '' +
                    '<li class="page-item ' + (dis ? 'disabled ' : '') + (act ? 'active' : '') + '">' +
                        '<a class="page-link" href="#" data-page="' + p + '">' + t + '</a>' +
                    '</li>';
            }

            var start = Math.max(1, page - 2); 		   // 시작 페이지
            var end = Math.min(totalPage, start + 4);  // 끝 페이지

            var html = '';
            html += item(Math.max(1, page - 1), '‹', page == 1, false);  // 이전
            for (var p = start; p <= end; p++) {
                html += item(p, String(p), false, p == page);  // 중간 번호
            }
            html += item(Math.min(totalPage, page + 1), '›', page == totalPage, false);  // 다음

            pagingEl.innerHTML = html;

            // 각 페이지 버튼 클릭 이벤트 등록
            Array.prototype.forEach.call(pagingEl.querySelectorAll('a.page-link'), function (a) {
                a.addEventListener('click', function (e) {
                    e.preventDefault();
                    var p = Number(a.getAttribute('data-page'));
                    if (p && p !== page) loadTeamPage(p);
                });
            });
        }

        // 체크된 행들의 ID 배열 반환
        function selectedIds() {
            return Array.prototype.map.call(
                tbody.querySelectorAll('.row-check:checked'),
                function (c) {
                    var tr = c.closest('tr');
                    return tr ? tr.getAttribute('data-id') : null;
                }
            ).filter(Boolean);
        }

        // 삭제 버튼 활성/비활성 토글
        function toggleDeleteSelectedButton() {
            if (!btnDeleteChecked) return;
            btnDeleteChecked.disabled = selectedIds().length == 0;  // 체크된 게 없으면 비활성
        }

        // 삭제 실행
        btnDeleteChecked && btnDeleteChecked.addEventListener('click', function () {
            var ids = selectedIds();
            if (ids.length == 0) return;

            if (!confirm('선택한 ' + ids.length + '명을 삭제하시겠습니까?')) return;

            // 삭제 요청 전송
            fetch(ctx + '/broadcast/team/delete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ids: ids })
            }).then(function (res) {
                if (!res.ok) throw new Error('삭제 실패');
                var lastPage = Math.max(1, Math.ceil((totalCount - ids.length) / pageSize));
                return loadTeamPage(Math.min(currentPage, lastPage));  // 현재 페이지 또는 마지막 페이지 로드
            }).then(function () {
                alert('삭제되었습니다.');
            }).catch(function (e) {
                console.error(e);
                alert('삭제 중 오류가 발생했습니다.');
            });
        });

        // HTML 이스케이프 유틸
        function esc(s) {
            if (s == null) return '';
            return String(s)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        // null-safe 문자열 변환
        function safe(s) { return s == null ? '' : String(s); }
    })();
</script>

</body>
</html>