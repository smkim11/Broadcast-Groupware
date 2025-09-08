<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Program Detail</title>
<link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
<style>
    .episodes-table th,
    .episodes-table td {
        vertical-align: middle;
        text-align: center;
    }
</style>

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
			                        <td>
									    <div class="d-flex justify-content-between align-items-center">
									        <span>
									            <c:out value="${empty program.episodesCount ? '-' : program.episodesCount}"/>회
									        </span>
									        <a href="#" class="link-primary" id="btnEpisodesToggle" data-schedule-id="${program.broadcastScheduleId}"
									           data-bs-toggle="collapse" data-bs-target="#episodesPanel" aria-expanded="false" aria-controls="episodesPanel">
									            회차 상세 보기
									        </a>
									    </div>
									
									    <!-- 접이식 회차 패널 -->
									    <div id="episodesPanel" class="collapse mt-2" data-loaded="0">
									        <div class="card border">
									            <div class="card-body p-2">
									                <div class="table-responsive">
									                    <table class="table table-sm table-bordered align-middle mb-2 episodes-table">
														    <colgroup>
														        <col style="width:80px;">
														        <col style="width:120px;">
														        <col style="width:100px;">
														        <col>
														        <col style="width:100px;">
														    </colgroup>
														    <thead class="table-light">
														        <tr class="text-center">
														            <th>회차</th>
														            <th>방영일</th>
														            <th>방영 요일</th>
														            <th>소제목 / 회차 설명</th>
														            <th>작업</th>
														        </tr>
														    </thead>
														    <tbody id="episodesBody">
														        <tr>
														            <td colspan="5" class="text-center text-muted py-3">불러오는 중…</td>
														        </tr>
														    </tbody>
														</table>
									                </div>
									                <div class="d-flex justify-content-center">
									                    <ul id="episodesPaging" class="pagination pagination-sm mb-0"></ul>
									                </div>
									            </div>
									        </div>
									    </div>
									</td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">대표자</th>
			                        <td class="d-flex justify-content-between align-items-center">
			                            <span>
			                                <c:out value="${empty program.fullName ? '-' : program.fullName}"/>
			                                <span class="text-muted ms-2">(담당 인원: <c:out value="${program.broadcastFormCapacity}"/>명)</span>
			                            </span>
			                            <a href="#teamCollapse" class="link-primary" id="btnOpenTeam" data-bs-toggle="collapse"
			                               data-bs-target="#teamCollapse" aria-expanded="false" aria-controls="teamCollapse">
			                            	팀원 보기
			                            </a>
			                        </td>
			                    </tr>
			                </tbody>
			            </table>
			        </div>
			    </div>
			</div>
			
			<!-- 팀원 카드 -->
			<div class="card mt-3 collapse" id="teamCollapse" data-loaded="0"
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
			                    <col style="width:100px;">
			                    <col style="width:16%;">
			                    <col style="width:16%;">
			                    <col style="width:16%;">
			                    <col style="width:18%;">
			                </colgroup>
			                <thead class="table-light">
			                    <tr class="text-center">
			                        <th>선택</th>
			                        <th>사원번호</th>
			                        <th>이름</th>
			                        <th>직급</th>
			                        <th>소속 부서</th>
			                        <th>소속 팀</th>
			                        <th>이메일</th>
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
			
			<!-- 회차 소제목 수정 모달 -->
			<div class="modal fade" id="epCommentModal" tabindex="-1" aria-hidden="true">
			    <div class="modal-dialog modal-md">
			        <div class="modal-content">
			            <div class="modal-header">
			                <h5 class="modal-title">소제목 / 회차 설명 수정</h5>
			                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
			            </div>
			            <div class="modal-body">
			                <form id="epCommentForm">
			                    <input type="hidden" id="epIdInput">
			                    <div class="mb-2">
			                        <label class="form-label small">회차</label>
			                        <input type="text" class="form-control" id="epNoInput" readonly>
			                    </div>
			                    <div class="mb-2">
			                        <label class="form-label small">소제목 / 회차 설명</label>
			                        <textarea class="form-control" id="epCommentInput" rows="3" placeholder="소제목 혹은 회차 설명을 입력하세요"></textarea>
			                    </div>
			                </form>
			                <div class="alert alert-warning d-none" id="epCommentAlert"></div>
			            </div>
			            <div class="modal-footer">
			                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
			                <button type="button" class="btn btn-outline-success" id="btnEpSave">수정</button>
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
    	// ===== 팀원 목록 =====
        const ctx = '${pageContext.request.contextPath}';  		       // 컨텍스트 경로
        const teamCollapse = document.getElementById('teamCollapse');  // 팀원 섹션(접기/펼치기)
        const btnOpen = document.getElementById('btnOpenTeam');    	   // "팀원 보기" 토글
        const tbody = document.getElementById('teamBody'); 		       // 팀원 목록 tbody
        const pagingEl = document.getElementById('teamPaging');        // 페이징 영역(ul)
        const btnDeleteChecked = document.getElementById('btnDeleteChecked');  // 팀원 삭제 버튼

        const scheduleId = teamCollapse ? teamCollapse.getAttribute('data-schedule-id') : null;
        let currentPage = 1;
        const pageSize = 10;
        let totalCount = 0;
        
        
		// 공통 페이징 (팀원/회차 공용)
		function renderPagingGeneric(total, page, size, containerEl, onMovePage) {
		    const totalPage = Math.max(1, Math.ceil(total / size));  // 총 페이지 수 계산
		
		    // 페이징 항목 HTML 생성
		    function item(p, t, dis, act) {
		        return '' +
		            '<li class="page-item ' + (dis ? 'disabled ' : '') + (act ? 'active' : '') + '">' +
		                '<a class="page-link" href="#" data-page="' + p + '">' + t + '</a>' +
		            '</li>';
		    }
		
		    const start = Math.max(1, page - 2);         // 시작 페이지
		    const end = Math.min(totalPage, start + 4);  // 끝 페이지
		
		    let html = '';
		    html += item(Math.max(1, page - 1), '‹', page == 1, false);  // 이전
		    for (let p = start; p <= end; p++) {
		        html += item(p, String(p), false, p == page);            // 중간 번호
		    }
		    html += item(Math.min(totalPage, page + 1), '›', page == totalPage, false);  // 다음
		
		    containerEl.innerHTML = html;
		
		    // 각 페이지 버튼 클릭 이벤트 등록
		    Array.prototype.forEach.call(containerEl.querySelectorAll('a.page-link'), function (a) {
		        a.addEventListener('click', function (e) {
		            e.preventDefault();
		            const target = Number(a.getAttribute('data-page'));
		            if (target && target !== page) onMovePage(target);
		        });
		    });
		}

        
     	// 팀원 섹션: collapse 토글 시 최초 로드 + 버튼 텍스트 토글
        if (teamCollapse) {

        	// 펼칠 때 이벤트
            teamCollapse.addEventListener('show.bs.collapse', function () {
                if (teamCollapse.getAttribute('data-loaded') !== '1') {
                    loadTeamPage(1);
                    teamCollapse.setAttribute('data-loaded', '1');
                }
                if (btnOpen) btnOpen.textContent = '팀원 닫기';  // 버튼 라벨 변경
            });
        	
         	// 접을 때 이벤트
            teamCollapse.addEventListener('hide.bs.collapse', function () {
                if (btnOpen) btnOpen.textContent = '팀원 보기';  // 버튼 라벨 복구
            });
        }
     	
        // 팀원 목록 로드
        function loadTeamPage(page) {
            currentPage = page;
            // 로딩 상태 표시
            tbody.innerHTML =
                '<tr>' +
                    '<td colspan="7" class="text-center text-muted py-4">불러오는 중…</td>' +
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
                            '<td colspan="7" class="text-center text-muted py-4">목록을 불러오지 못했습니다</td>' +
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
                        '<td colspan="7" class="text-center text-muted py-4">등록된 팀원이 없습니다</td>' +
                    '</tr>';
                return;
            }

            // rows를 <tr>로 변환
            var html = rows.map(function (r) {
                var rowId = safe(r.broadcastTeamId);

                return '' +
	                '<tr data-id="' + rowId + '">' +
	                    '<td class="text-center"><input type="checkbox" class="row-check" /></td>' +
	                    '<td class="text-center">' + esc(r.username || '-') + '</td>' +
	                    '<td class="text-center">' + esc(r.fullName) + '</td>' +
	                    '<td class="text-center">' + esc(r.userRank || '-') + '</td>' +
	                    '<td class="text-center">' + esc(r.departmentName || '-') + '</td>' +
	                    '<td class="text-center">' + esc(r.teamName || '-') + '</td>' +
	                    '<td class="text-center">' + esc(r.email || '-') + '</td>' +
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
		    return renderPagingGeneric(total, page, size, pagingEl, loadTeamPage);
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

            Swal.fire({
                title: "선택한 " + ids.length + "명을 삭제하시겠습니까?",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#f46a6a",
                cancelButtonColor: "#74788d",
                confirmButtonText: "삭제",
                cancelButtonText: "취소"
            }).then(function (r) {
                if (!r.isConfirmed) return;

	            // 삭제 요청 전송
	            fetch(ctx + '/broadcast/team/delete', {
	                method: 'POST',
	                headers: { 'Content-Type': 'application/json' },
	                body: JSON.stringify({ ids: ids })
	            })
	            .then(function (res) {
	                if (!res.ok) throw new Error('삭제 실패');
	                var lastPage = Math.max(1, Math.ceil((totalCount - ids.length) / pageSize));
	                return loadTeamPage(Math.min(currentPage, lastPage));  // 현재 페이지 또는 마지막 페이지 로드
	            })
	            .then(function () {
	                Swal.fire({
	                    title: "삭제되었습니다.",
	                    icon: "success",
	                    confirmButtonText: "확인",
	                    confirmButtonColor: "#34c38f"
	                });
	            })
	            .catch(function () {
	                Swal.fire({
	                    title: "삭제 중 오류가 발생했습니다.",
	                    icon: "error",
	                    confirmButtonText: "확인",
	                    confirmButtonColor: "#34c38f"
	                });
	            });
	        });
	    });
        
        
        // ===== 회차 목록(행 내부) =====
        const episodesPanel = document.getElementById('episodesPanel'); 	 	 // 회차 섹션
        const episodesBody = document.getElementById('episodesBody');   	 	 // 회차 목록 tbody
        const episodesPaging = document.getElementById('episodesPaging');        // 회차 페이징 영역
        const btnEpisodesToggle = document.getElementById('btnEpisodesToggle');  // 회차 토글 버튼

        let episodesCurrentPage = 1;
        const episodesPageSize = 8;
        let episodesTotalCount = 0;
        const episodesScheduleId = btnEpisodesToggle ? btnEpisodesToggle.getAttribute('data-schedule-id') : null;

     	// 회차 섹션: collapse 토글 시 최초 로드 + 버튼 텍스트 토글
        if (episodesPanel) {

        	// 펼칠 때 이벤트
            episodesPanel.addEventListener('show.bs.collapse', function () {
                if (episodesPanel.getAttribute('data-loaded') !== '1') {
                    loadEpisodesPage(1);
                    episodesPanel.setAttribute('data-loaded', '1');
                }
                if (btnEpisodesToggle) btnEpisodesToggle.textContent = '회차 닫기';  // 버튼 라벨 변경
            });
            
         	// 접을 때 이벤트
            episodesPanel.addEventListener('hide.bs.collapse', function () {
                if (btnEpisodesToggle) btnEpisodesToggle.textContent = '회차 상세 보기';  // 버튼 라벨 복구
            });
        }

     	// 회차 목록 로드
        function loadEpisodesPage(page) {
            episodesCurrentPage = page;
            episodesBody.innerHTML =
                '<tr>' +
                    '<td colspan="5" class="text-center text-muted py-3">불러오는 중…</td>' +
                '</tr>';

            const url = ctx + '/broadcast/episodes/list'
                        + '?scheduleId=' + encodeURIComponent(episodesScheduleId)
                        + '&page=' + page
                        + '&size=' + episodesPageSize;

            fetch(url, { headers: { 'Accept': 'application/json' } })
                .then(function (res) {
                    if (!res.ok) throw new Error('통신 오류');
                    return res.json();  // JSON 파싱
                })
                .then(function (data) {
                    episodesTotalCount = data.totalCount || 0;  // 전체 개수 저장
                    renderEpisodesRows(data.rows || []);		// 행 렌더링
                 	// 페이징 렌더링
                    renderEpisodesPaging(episodesTotalCount, data.page || 1, data.size || episodesPageSize);
                })
                .catch(function (e) {
                    console.error(e);
                    episodesBody.innerHTML =
                        '<tr>' +
                            '<td colspan="5" class="text-center text-muted py-3">회차를 불러오지 못했습니다</td>' +
                        '</tr>';
                });
        }

     	// 회차 목록 행 렌더링
        function renderEpisodesRows(rows) {
            if (!rows.length) {
                episodesBody.innerHTML =
                    '<tr><td colspan="5" class="text-center text-muted py-3">등록된 회차가 없습니다</td></tr>';
                return;
            }

            const html = rows.map(function (r) {
                const weekday = (r.broadcastEpisodeWeekday || '').trim() || '-';
                const hasComment = !!(r.broadcastEpisodeComment && r.broadcastEpisodeComment.trim().length > 0);
                const commentHtml = hasComment
                    ? '<span class="ep-comment-label">' + esc(r.broadcastEpisodeComment) + '</span>'
                    : '<span class="text-muted">-</span>';

                return '' +
                    '<tr>' +
                        '<td>' + safe(r.broadcastEpisodeNo) + '</td>' +
                        '<td>' + esc(r.broadcastEpisodeDate || '') + '</td>' +
                        '<td>' + esc(weekday) + '</td>' +
                        '<td class="ep-comment">' + commentHtml + '</td>' +
                        '<td>' +
                            '<button type="button" class="btn btn-sm btn-outline-success btn-ep-edit"' +
                            ' data-episode-id="' + safe(r.broadcastEpisodeId) + '"' +
                            ' data-episode-no="' + safe(r.broadcastEpisodeNo) + '"' +
                            ' data-episode-comment="' + esc(r.broadcastEpisodeComment || '') + '"' +
                            '>수정</button>' +
                        '</td>' +
                    '</tr>';
            }).join('');

            episodesBody.innerHTML = html;
        }

     	
     	// 페이징 렌더링
        function renderEpisodesPaging(total, page, size) {
        	return renderPagingGeneric(total, page, size, episodesPaging, loadEpisodesPage);
        }
        
     	// 경고 메시지 유틸
		function showEpAlert(msg, type) {
            var el = document.getElementById('epCommentAlert');
            el.className = 'alert alert-' + (type || 'warning');
            el.textContent = msg;
            el.classList.remove('d-none');
        }

     	
     	// 수정 버튼 클릭 -> 모달 오픈
        episodesBody.addEventListener('click', function (e) {
            const btn = e.target.closest('.btn-ep-edit');
            if (!btn) return;

            document.getElementById('epIdInput').value = btn.getAttribute('data-episode-id');
            document.getElementById('epNoInput').value = btn.getAttribute('data-episode-no');
            document.getElementById('epCommentInput').value = btn.getAttribute('data-episode-comment') || '';

            new bootstrap.Modal(document.getElementById('epCommentModal')).show();
        });

     	
     	// 모달 수정 버튼 클릭 -> 소제목 / 회차 설명 업데이트
        document.getElementById('btnEpSave').addEventListener('click', function () {
            const id = document.getElementById('epIdInput').value;
            const comment = document.getElementById('epCommentInput').value;

            fetch(ctx + '/broadcast/episodes/comment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ episodeId: Number(id), comment: comment })
            })
            .then(function (res) {
                if (!res.ok) throw new Error('수정 실패');
                return res.json();
            })
            .then(function (data) {
                if (!data || data.updated !== 1) throw new Error('수정 실패');

                // 해당 행만 부분 갱신
                const btn = episodesBody.querySelector('.btn-ep-edit[data-episode-id="' + id + '"]');
                if (!btn) return;
                const row = btn.closest('tr');
                const commentTd = row.children[3];  // 0:회차, 1:날짜, 2:요일, 3:소제목 / 회차 설명, 4:작업
                const hasComment = !!(comment && comment.trim().length > 0);
                commentTd.innerHTML = hasComment
                    ? '<span class="ep-comment-label">' + esc(comment) + '</span>'
                    : '<span class="text-muted">-</span>';

                // 버튼 data 속성 최신화
                btn.setAttribute('data-episode-comment', comment || '');

                bootstrap.Modal.getInstance(document.getElementById('epCommentModal')).hide();
            })
            .catch(function (e) {
                console.error(e);
                const alertEl = document.getElementById('epCommentAlert');
                alertEl.textContent = '저장 중 오류가 발생했습니다.';
                alertEl.classList.remove('d-none');
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
        
        
        // ===== 팀원 등록 (드롭다운) =====
        const teamAddModalEl = document.getElementById('teamAddModal');
        const deptSel = document.getElementById('deptSelect');
        const teamSel = document.getElementById('teamSelect');
        const userSel = document.getElementById('userSelect');
        const btnTeamSave = document.getElementById('btnTeamSave');

        // 드롭다운 항목 유틸
        function opt(v, t) {
            const o = document.createElement('option');
            o.value = v;
            o.textContent = t;
            return o;
        }
        
     	// 선택 목록 초기화 유틸
        function clearSelect(sel, placeholder) {
            sel.innerHTML = '';
            sel.appendChild(opt('', placeholder || '선택하세요'));
        }

        // 부서 목록 로드
        function loadDepartments() {
            clearSelect(deptSel, '부서를 선택하세요');
            clearSelect(teamSel, '팀을 선택하세요');
            clearSelect(userSel, '이름을 선택하세요');

            fetch(ctx + '/broadcast/departments', { headers: { 'Accept': 'application/json' } })
                .then(r => r.json())
                .then(list => {
                	// 결과가 배열이 아니거나 비었으면 placeholder만 유지
                    if (!Array.isArray(list) || list.length == 0) {
                        deptSel.appendChild(opt('', '(부서 없음)'));
                        return;
                    }
                 	// 부서 id/name을 옵션 태그로 추가
                    list.forEach(d => {
                        deptSel.appendChild(opt(d.departmentId, d.departmentName));
                    });
                })
                .catch(() => {});
        }

        // 팀 목록 로드
        function loadTeams(departmentId) {
            clearSelect(teamSel, '팀을 선택하세요');
            clearSelect(userSel, '이름을 선택하세요');
            if (!departmentId) return;

            fetch(
            	ctx + '/broadcast/teams?departmentId=' + encodeURIComponent(departmentId),
                { headers: { 'Accept': 'application/json' } }
            )
                .then(r => r.json())
                .then(list => {
                    if (!Array.isArray(list) || list.length == 0) {
                        teamSel.appendChild(opt('', '(팀 없음)'));
                        return;
                    }
                    list.forEach(t => {
                        teamSel.appendChild(opt(t.teamId, t.teamName));
                    });
                })
                .catch(() => {});
        }

        // 등록 가능 사용자 목록 로드
        function loadAssignableUsers(teamId) {
            clearSelect(userSel, '이름을 선택하세요');
            if (!teamId) return;

        	// scheduleId(현재 프로그램)와 teamId(선택 팀)를 함께 전달
            const url = ctx + '/broadcast/assignable-users?scheduleId='
                + encodeURIComponent(scheduleId) + '&teamId=' + encodeURIComponent(teamId);

            fetch(url, { headers: { 'Accept': 'application/json' } })
                .then(r => r.json())
                .then(list => {
                	// 선택 가능 인원이 없는 경우
                    if (!Array.isArray(list) || list.length == 0) {
                        userSel.appendChild(opt('', '(선택 가능한 인원이 없음)'));
                        return;
                    }
                    list.forEach(u => {
                    	const id   = u.userId != null ? u.userId : u.user_id;
                        const name = u.fullName != null ? u.fullName : u.full_name;
                        const rank = u.userRank != null ? u.userRank : u.user_rank;
                        const o = opt(id, (name || '') + ' (' + (rank || '-') + ')');  // 이름 (직급)
                        userSel.appendChild(o); 
                    });
                })
                .catch(() => {});
        }

        
        // 모달이 열릴 때 부서부터 로드
        teamAddModalEl && teamAddModalEl.addEventListener('show.bs.modal', function () {
            loadDepartments();
        });

     	// 부서 선택 -> 팀 목록 갱신
        deptSel && deptSel.addEventListener('change', function () {
            loadTeams(this.value);
        });
     	
     	// 팀 선택 -> 등록 가능 사용자 목록 갱신
        teamSel && teamSel.addEventListener('change', function () {
            loadAssignableUsers(this.value);
        });

        
     	// 저장 버튼 -> 선택한 사용자를 현재 프로그램 팀에 등록
        btnTeamSave && btnTeamSave.addEventListener('click', function () {
            const uid = Number(userSel.value || 0);
            if (!uid) {
                Swal.fire({
                    title: '등록할 인원을 선택해주세요.',
                    icon: 'warning',
                    confirmButtonText: '확인',
                    confirmButtonColor: '#34c38f'
                });
                return;
            }
            
            fetch(ctx + '/broadcast/team/add', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
                body: JSON.stringify({ scheduleId: Number(scheduleId), userId: uid })
            })
            .then(r => r.json())
            .then(res => {
                if (res.status == 200 && res.result == 1) {
                    bootstrap.Modal.getInstance(teamAddModalEl).hide();  // 모달 닫기
                    
                    if (typeof loadTeamPage == 'function') {
                        loadTeamPage(1);  // 목록 갱신
                    }
                    Swal.fire({
                        title: '등록되었습니다.',
                        icon: 'success',
                        confirmButtonText: '확인',
                        confirmButtonColor: '#34c38f'
                    });
                } else {
                	Swal.fire({
                        title: res.message || '등록에 실패했습니다.',
                        icon: 'error',
                        confirmButtonText: '확인',
                        confirmButtonColor: '#34c38f'
                    });
                }
            })
            .catch(() => {
                Swal.fire({
                    title: '통신 오류가 발생했습니다.',
                    icon: 'error',
                    confirmButtonText: '확인',
                    confirmButtonColor: '#34c38f'
                });
            });
        });        
    })();
</script>

</body>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
</html>