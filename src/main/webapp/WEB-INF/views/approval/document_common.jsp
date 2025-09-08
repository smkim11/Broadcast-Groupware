<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Document Common</title>
<link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
</head>
<body>
<div>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
	<div class="page-content">
		<div class="container-fluid">

		    <!-- 페이지 타이틀 + 상단 액션 -->
		    <div class="row align-items-center mb-2">
		        <div class="col">
		            <h4 class="mb-0">일반 문서 작성</h4>
		        </div>
		        <div class="col-auto d-flex gap-2">
		            <a href="${pageContext.request.contextPath}/approval/line/input" class="btn btn-outline-primary">결재선</a>
				    <a href="${pageContext.request.contextPath}/approval/reference/input" class="btn btn-outline-primary">참조선</a>
				    <button id="btnSubmit" type="button" class="btn btn-outline-success">상신</button>
				    <button id="btnDraft" type="button" class="btn btn-outline-success">임시저장</button>
				    <button id="btnCancel" type="button" class="btn btn-outline-secondary">취소</button>
		        </div>
		    </div>
		
		    <!-- 본문 폼 -->
		    <form id="commonDocForm" method="post" action="${pageContext.request.contextPath}/approval/common/new">
		        <input type="hidden" name="documentType" value="COMMON">
		
				<!-- 선택 결과(JSON) -->
			    <input type="hidden" id="approvalLineJson" name="approvalLineJson" value="[]">
			    <input type="hidden" id="referenceLineJson" name="referenceLineJson" value="[]">
		
				<!-- 공통 정보 표 -->
		        <div class="card">
		            <div class="card-body p-0">
		                <table class="table table-bordered mb-0 align-middle">
		                    <colgroup>
		                        <col style="width: 20%;">
		                        <col style="width: 30%;">
		                        <col style="width: 20%;">
		                        <col style="width: 30%;">
		                    </colgroup>
		                    <tbody>
		                        <tr>
			                        <th class="bg-light text-center">소속 부서</th>
			                        <td>
			                            <input type="text" class="form-control" value="${sessionScope.loginUser.departmentName}" readonly>
			                            <input type="hidden" name="departmentId" value="${sessionScope.loginUser.departmentId}">
			                        </td>
			                        <th class="bg-light text-center">소속 팀</th>
			                        <td>
			                            <input type="text" class="form-control" value="${sessionScope.loginUser.teamName}" readonly>
			                            <input type="hidden" name="teamId" value="${sessionScope.loginUser.teamId}">
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">작성자</th>
			                        <td>
			                            <input type="text" class="form-control" value="${sessionScope.loginUser.fullName}" readonly>
			                            <input type="hidden" name="userId" value="${sessionScope.loginUser.userId}">
			                        </td>
			                        <th class="bg-light text-center">직급</th>
			                        <td>
			                            <input type="text" class="form-control" value="${sessionScope.loginUser.userRank}" readonly>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">제목</th>
			                        <td colspan="3">
			                            <input type="text" id="docTitle" name="approvalDocumentTitle" class="form-control" placeholder="OOO에 관한 보고서입니다.">
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">내용</th>
			                        <td colspan="3">
			                            <textarea name="approvalDocumentContent" rows="10" class="form-control" placeholder="내용을 입력하세요"></textarea>
			                        </td>
			                    </tr>
		                    </tbody>
		                </table>
		            </div>
		        </div>
		        
		        <!-- 결재선 / 참조선 상세 (기본 접힘) -->
				<div class="accordion mt-3" id="lineAccordion">
				    <div class="accordion-item">
				        <h2 class="accordion-header" id="headingLines">
				            <button class="accordion-button collapsed fw-semibold text-dark" type="button" data-bs-toggle="collapse"
				                    data-bs-target="#collapseLines" aria-expanded="false" aria-controls="collapseLines">
				                결재선 / 참조선
				            </button>
				        </h2>
				        <div id="collapseLines" class="accordion-collapse collapse" aria-labelledby="headingLines" data-bs-parent="#lineAccordion">
				            <div class="accordion-body">
				                <div class="row g-3">
				                    <!-- 좌측: 결재선 -->
				                    <div class="col-6">
				                        <div class="card h-100">
				                            <div class="card-header bg-light py-2">
				                                <strong class="mb-0">결재선</strong>
				                            </div>
				                            <div class="card-body p-2" style="max-height:260px; overflow:auto;">
				                                <table class="table table-sm table-bordered mb-0">
				                                    <thead class="table-light">
				                                        <tr>
				                                            <th style="width:20px;" class="text-center">차수</th>
				                                            <th style="width:50px;" class="text-center">결재자</th>
				                                            <th style="width:30px;" class="text-center">소속</th>
				                                        </tr>
				                                    </thead>
				                                    <tbody id="applinePreviewBody"><!-- JS-RENDER: 결재선 목록 동적 삽입 --></tbody>
				                                </table>
				                            </div>
				                        </div>
				                    </div>
				
				                    <!-- 우측: 참조선 -->
				                    <div class="col-6">
				                        <div class="card h-100">
				                            <div class="card-header bg-light py-2 d-flex align-items-center">
				                                <strong class="mb-0">참조선</strong>
				                            </div>
				                            <div class="card-body p-2" style="max-height:260px; overflow:auto;">
				                                <div id="reflinesPreview" class="d-flex flex-wrap gap-2"><!-- JS-RENDER: 참조선 배지 동적 삽입 --></div>
				                            </div>
				                        </div>
				                    </div>
				                </div>
				            </div>
				        </div>
				    </div>
				</div>
				
		    </form>
		
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
	    const form = document.getElementById('commonDocForm');
	    const btnSubmit = document.getElementById('btnSubmit');
	    const btnDraft = document.getElementById('btnDraft');
	    const btnCancel = document.getElementById('btnCancel');
	    const base = '${pageContext.request.contextPath}';  // JSP EL로 컨텍스트 경로 주입
	    
	    // 결재선/참조선 페이지로 이동할 땐 플로우 유지
	    const linkApv = document.querySelector('a[href$="/approval/line/input"]');
	    const linkRef = document.querySelector('a[href$="/approval/reference/input"]');
	    [linkApv, linkRef].forEach(a => a && a.addEventListener('click', () => {
	        sessionStorage.setItem('flowKeep', '1');
	    }));
	
	 	// 결재선 / 참조선 미리보기 영역 및 폼 히든 필드
	    const apvTbody = document.getElementById('applinePreviewBody');   // 결재선 표 tbody (JS로 채움)
	    const refWrap = document.getElementById('reflinesPreview');		  // 참조선 배지 영역 (JS로 채움)
	    const hiddenLines = document.getElementById('approvalLineJson');  // 서버 전송 대비 히든 JSON(결재선)
	    const hiddenRefs = document.getElementById('referenceLineJson');  // 서버 전송 대비 히든 JSON(참조선)
	
		// JSON 파서 (깨지면 fallback)
		function safeParse(json, fb){
		    if (typeof json !== 'string' || !json.trim()) return fb;
		    try { return JSON.parse(json); } catch { return fb; }
	    }
		    
	    
	    // ===== 결제선 / 참조선 렌더 =====
	
	 	// 결재선(JSON 문자열) 배열로 변환
	    function getApprovalLines() {
	        const raw = hiddenLines ? hiddenLines.value : '[]';
	        return safeParse(raw, []);
	    }
	 	
	 	// 참조선(JSON 문자열)을 배열로 변환
	    function getReferenceLines() {
	        const raw = hiddenRefs ? hiddenRefs.value : '[]';
	        return safeParse(raw, []);
	    }
	
	 	// 결재자 이름/직급/부서/팀 표시
	    function formatUserDisplay(u){
	    	var name = (u.name || u.userName || '');
	        var rank = u.userRank ? ' (' + u.userRank + ')' : '';
	        var deptTeamArr = [];
	        if (u.dept) deptTeamArr.push(u.dept);
	        if (u.team) deptTeamArr.push(u.team);
	        var deptTeam = deptTeamArr.join(' / ');
	        return name + rank + (deptTeam ? ' - ' + deptTeam : '');
	    }
	
	    // 결재선 렌더
	    function renderApvDetail(){
	        if (!apvTbody) return;
	        const arr = getApprovalLines();
	        apvTbody.innerHTML = '';
	        arr
	     		// sequence 기준 정렬
	          	.sort((a,b) => (a.approvalLineSequence || a.sequence || 999) - (b.approvalLineSequence || b.sequence || 999))
	            .forEach((it, idx) => {
	                const tr = document.createElement('tr');
		            tr.innerHTML =
	            	    '<td class="text-center">' +
	            	        (it.approvalLineSequence || it.sequence || (idx + 1)) +
	            	    '</td>' +
	            	    '<td class="text-center">' +
	            	        ( (it.name || it.userName || '') + (it.userRank ? ' (' + it.userRank + ')' : '') ) +
	            	    '</td>' +
	            	    '<td class="text-center">' +
	            	        ( [it.dept, it.team].filter(Boolean).join(' / ') || '-' ) +
	            	    '</td>';
	            	    
	            	apvTbody.appendChild(tr);
	          });
	    }
	
	    // 참조선 렌더 (DB에는 개인으로 저장)
	    function renderRefDetail(){
	        if (!refWrap) return;
	        const arr = getReferenceLines();
	        refWrap.innerHTML = '';
	        
	        arr.forEach(it=>{
	            const badge = document.createElement('span');
	            badge.className = 'badge bg-light fs-6 px-5 py-2';
	            if (it.teamId != null && it.userId == null){
	                badge.textContent = '👥 팀: ' + (it.name || '팀') + (it.dept ? ' (' + it.dept + ')' : '');
	            } else {
	                badge.textContent = '👤 ' + (formatUserDisplay(it) || ('ID: ' + (it.userId == null ? '' : it.userId)));
	            }
	
	            refWrap.appendChild(badge);
	        });
	    }
	    
	    // 값의 유무에 따라 결재선/참조선 영역 접힘/펼침 상태 동기화
	    function expandLinesIfHasData() {
		    try {
		        const hasApv = getApprovalLines().length > 0;
		        const hasRef = getReferenceLines().length > 0;
		        const hasAny = hasApv || hasRef;
		
		        const collapseEl = document.getElementById('collapseLines');
		        if (!collapseEl) return;
		
		        // API로 show/hide (Bootstrap 5)
		        const inst = bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false });
		        hasAny ? inst.show() : inst.hide();
		    } catch (e) {
		        console.warn('expandLinesIfHasData error', e);
		    }
		}
	    
	 	// 초기 렌더 (필요한 요소가 있을 때만 호출)
	    function syncLinesPreview() {
	    	// sessionStorage -> 히든 필드 주입
	        try {
	            if (hiddenLines) hiddenLines.value = sessionStorage.getItem('approvalLines') || '[]';
	            if (hiddenRefs)  hiddenRefs.value  = sessionStorage.getItem('referenceLines') || '[]';
	        } catch (e) {}
	
	        try { renderApvDetail(); } catch (e) {}		  // 차수/결재자/소속 테이블 갱신
	        try { renderRefDetail(); } catch (e) {}		  // 참조선 배지 리스트 갱신
	        try { expandLinesIfHasData(); } catch (e) {}  // 접힘/펼침 상태 동기화
	    }
	    
	    syncLinesPreview();  // 최초 1회: 페이지 로드 직후 동기화
	    
	 	// 새로고침 없이도 최신 반영
	    window.addEventListener('pageshow', syncLinesPreview);
	    window.addEventListener('focus', syncLinesPreview);
	    document.addEventListener('visibilitychange', function () {
	        if (!document.hidden) syncLinesPreview();
	    });
	    
	    // 페이지 이탈 시 선택값 초기화
	    window.addEventListener('pagehide', () => {
	    	// 결재선/참조선 페이지로 이동하는 경우 값 유지
	        const keep = sessionStorage.getItem('flowKeep') == '1';
	        // 다음 이동을 위해 항상 플래그 초기화
	        sessionStorage.setItem('flowKeep', '0');
	        if (keep) return;  // 유지 플로우면 정리 생략

	     	// 유지 플로우가 아니면 임시 선택값 제거
	        sessionStorage.removeItem('approvalLines');
	        sessionStorage.removeItem('referenceLines');
	    });
	    
		
	    // ===== 문서 저장 (상신/임시저장) =====
	    function submitDocument(isDraft){
	        if (!form) return;
	        
	     	// 상신일 때만 최소 필수값 검증
	        if (!isDraft) {
	            const title = (form.querySelector('[name="approvalDocumentTitle"]')?.value || '').trim();
	            const content = (form.querySelector('[name="approvalDocumentContent"]')?.value || '').trim();
	            const apvLines = getApprovalLines();

	            if (!title || !content || apvLines.length === 0) {
	                Swal.fire({
	                    title: "저장에 실패했습니다.",
	                    text: "작성하지 않은 부분이 있습니다. 다시 확인해 주세요.",
	                    icon: "error",
	                    confirmButtonText: "확인",
	                    confirmButtonColor: "#34c38f"
	                });
	                return;
	            }
	        }
	        
	     	// 입력값 수집
	        const title = (form.querySelector('[name="approvalDocumentTitle"]')?.value || '').trim();
	        const content = (form.querySelector('[name="approvalDocumentContent"]')?.value || '').trim();
	        const userId = parseInt(form.querySelector('[name="userId"]')?.value || '0', 10) || 0;
	
	        // 결재선 / 참조선
	        const apvLines = getApprovalLines();
	        const refLines = getReferenceLines();
	        
	        // 폼 fallback 대비해서 히든필드도 항상 최신화
	        if (hiddenLines) hiddenLines.value = JSON.stringify(apvLines);
	        if (hiddenRefs) hiddenRefs.value = JSON.stringify(refLines);
	
	        
	     	// 서버 전송 DTO
	        const dto = {
	            userId,
	            approvalDocumentTitle: title,
	            approvalDocumentContent: content,
	            approvalLines: apvLines.map((it, idx)=>({
	                userId: it.userId,
	                approvalLineSequence: (it.approvalLineSequence || it.sequence || (idx+1))
	            })),
	            referenceLines: refLines.map(it=>{
	                if (it.teamId) return { teamId: it.teamId };
	                if (it.userId) return { userId: it.userId };
	                return null;
	            }).filter(Boolean)  // falsy(null/undefined/false/0/NaN/"") 제거
	        };
	
	     	// 요청 헤더 (필수: JSON)
	        const headers = { 'Content-Type':'application/json' };
	     	
	     	// 요청 중 버튼 잠금 (중복 클릭 방지)
	        if (btnSubmit) btnSubmit.disabled = true;
	        if (btnDraft) btnDraft.disabled = true;
	        if (btnCancel) btnCancel.disabled = true;
	
	     	// 서버 전송
	        fetch(base + '/approval/common/new?draft=' + (isDraft ? 'true' : 'false'), {
	            method: 'POST',
	            headers,
	            body: JSON.stringify(dto)
	        })
	        .then(function (resp) {
	            if (resp.status == 401) {
	                window.location.href = base + '/login';
	                throw new Error('401 Unauthorized');
	            }
	            if (!resp.ok) {
	                return resp.text().then(function (t) {
	                    throw new Error(t || ('HTTP ' + resp.status));
	                });
	            }
	            return resp.json();  // 생성된 문서 ID 반환
	        })
	        .then(function (docId) {
	            console.log('일반 문서 저장 완료:', docId, isDraft ? '(임시저장)' : '(상신)');
	            
	        	// 저장 후 선택값 초기화
	            sessionStorage.removeItem('approvalLines');
	            sessionStorage.removeItem('referenceLines');
	            
	            Swal.fire({
	                title: (isDraft ? "임시저장되었습니다." : "상신되었습니다."),
	                icon: "success",
	                confirmButtonText: "확인",
	                confirmButtonColor: "#34c38f"
	            }).then(function(r){
	                if (r.isConfirmed) {
	                    window.location.href = base + '/approval/document/main';
	                }
	            });
	        })
	        .catch(function (e) {
	            console.error('일반 문서 저장 오류:', e);
	            Swal.fire({
	                title: "저장에 실패했습니다.",
	                text: "작성하지 않은 부분이 있습니다. 다시 확인해 주세요.",
	                icon: "error",
	                confirmButtonText: "확인",
	                confirmButtonColor: "#34c38f"
	            });
	        })
	        .finally(function () {
	        	// 버튼 잠금 해제
	        	if (btnSubmit) btnSubmit.disabled = false;
	            if (btnDraft) btnDraft.disabled = false;
	            if (btnCancel) btnCancel.disabled = false;
	        });
	    }
	
	    // 이벤트 바인딩
	    if (btnSubmit) btnSubmit.addEventListener('click', function (e) {
		    e.preventDefault();
		    e.stopPropagation();
		    Swal.fire({
		        title: "상신하시겠습니까?",
		        icon: "question",
		        showCancelButton: true,
		        confirmButtonColor: "#34c38f",
		        cancelButtonColor: "#f46a6a",
		        confirmButtonText: "예",
		        cancelButtonText: "아니요"
		    }).then(function(result) {
		        if (result.value) {
		            submitDocument(false);  // 실제 상신 실행
		        }
		    });
		});
	    
	    if (btnDraft) btnDraft.addEventListener('click', function (e) {
	        e.preventDefault();
	        e.stopPropagation();
	        Swal.fire({
	            title: "임시저장하시겠습니까?",
	            icon: "question",
	            showCancelButton: true,
	            confirmButtonColor: "#34c38f",
	            cancelButtonColor: "#f46a6a",
	            confirmButtonText: "예",
	            cancelButtonText: "아니요"
	        }).then(function(result) {
	            if (result.value) {
	                submitDocument(true);  // 실제 임시저장 실행
	            }
	        });
	    });
	    
	    if (btnCancel) btnCancel.addEventListener('click', function (e) {
	        e.preventDefault();   // 폼 전송 방지
	        e.stopPropagation();  // 상위로 이벤트 전파 방지

	        Swal.fire({
	            title: "작성 중인 내용을 취소하시겠습니까?",
	            icon: "warning",
	            showCancelButton: true,
	            confirmButtonColor: "#34c38f",
	            cancelButtonColor: "#f46a6a",
	            confirmButtonText: "예",
	            cancelButtonText: "아니요"
	        }).then(function(result) {
	            if (result.value) {
	                // 확인 시: 값 초기화 후 '취소되었습니다' 알림 -> 뒤로가기
	                sessionStorage.removeItem('approvalLines');
	                sessionStorage.removeItem('referenceLines');

	                Swal.fire({
	                    title: "취소되었습니다.",
	                    icon: "success",
	                    confirmButtonText: "확인",
	                    confirmButtonColor: "#34c38f"
	                }).then(function(r2){
	                    if (r2.isConfirmed) {
	                        history.back();  // 뒤로가기
	                    }
	                });
	            }
	        });
	    });
	})();
</script>

</body>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
</html>