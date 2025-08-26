<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Document Broadcast</title>
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
		            <h4 class="mb-0">방송 문서 작성</h4>
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
		    <form id="broadcastDocForm" method="post" action="${pageContext.request.contextPath}/approval/broadcast">
		        <input type="hidden" name="documentType" value="BROADCAST">
		
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
								        <input type="hidden" name="authorId" value="${sessionScope.loginUser.userId}">
								    </td>
								    <th class="bg-light text-center">직급</th>
								    <td>
								        <input type="text" class="form-control" value="${sessionScope.loginUser.userRank}" readonly>
								    </td>
		                        </tr>
		                        <tr>
		                            <th class="bg-light text-center">제목</th>
		                            <td colspan="3">
		                                <input type="text" id="docTitle" name="title" class="form-control" value="방송 편성에 대한 요청 건입니다.">
		                            </td>
		                        </tr>
		                    </tbody>
		                </table>
		            </div>
		        </div>
		
		        <!-- 방송 정보 표 -->
		        <div class="card mt-3">
		            <div class="card-header bg-light">
		                <h5 class="mb-0">방송 정보</h5>
		            </div>
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
		                            <th class="bg-light text-center">프로그램명</th>
		                            <td colspan="3">
		                                <input type="text" class="form-control" name="programName" placeholder="예) 뉴스와이드">
		                            </td>
		                        </tr>
		                        <tr>
		                            <th class="bg-light text-center">담당 총 인원</th>
		                            <td>
		                                <input type="number" class="form-control" name="staffCount" min="0" step="1" placeholder="숫자 입력">
		                            </td>
		                            <th class="bg-light text-center">방송 요일</th>
		                            <td>
		                                <div class="d-flex flex-wrap gap-2">
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Mon" name="broadcastDays" value="MON">
		                                        <label class="form-check-label" for="Mon">월</label>
		                                    </div>
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Tue" name="broadcastDays" value="TUE">
		                                        <label class="form-check-label" for="Tue">화</label>
		                                    </div>
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Wed" name="broadcastDays" value="WED">
		                                        <label class="form-check-label" for="Wed">수</label>
		                                    </div>
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Thu" name="broadcastDays" value="THU">
		                                        <label class="form-check-label" for="Thu">목</label>
		                                    </div>
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Fri" name="broadcastDays" value="FRI">
		                                        <label class="form-check-label" for="Fri">금</label>
		                                    </div>
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Sat" name="broadcastDays" value="SAT">
		                                        <label class="form-check-label" for="Sat">토</label>
		                                    </div>
		                                    <div class="form-check form-check-inline">
		                                        <input class="form-check-input" type="checkbox" id="Sun" name="broadcastDays" value="SUN">
		                                        <label class="form-check-label" for="Sun">일</label>
		                                    </div>
		                                </div>
		                            </td>
		                        </tr>
		                        <tr>
		                            <th class="bg-light text-center">방송 시작일</th>
		                            <td>
		                                <input type="date" class="form-control" name="broadcastStartDate">
		                            </td>
		                            <th class="bg-light text-center">방송 종료일</th>
		                            <td>
		                                <input type="date" class="form-control" name="broadcastEndDate">
		                            </td>
		                        </tr>
		                        <tr>
								    <th class="bg-light text-center">방송 시작 시간</th>
								    <td><input type="time" name="startTime" class="form-control"></td>
								    <th class="bg-light text-center">방송 종료 시간</th>
								    <td><input type="time" name="endTime" class="form-control"></td>
								</tr>
		                        <tr>
		                            <th class="bg-light text-center">내용</th>
		                            <td colspan="3">
		                                <textarea name="content" rows="10" class="form-control" placeholder="내용을 입력하세요"></textarea>
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
				                결재선 / 참조선 상세
				            </button>
				        </h2>
				        <div id="collapseLines" class="accordion-collapse collapse" aria-labelledby="headingLines" data-bs-parent="#lineAccordion">
				            <div class="accordion-body">
				                <div class="row g-3">
				                    <!-- 왼쪽: 결재선 -->
				                    <div class="col-6">
				                        <div class="card h-100">
				                            <div class="card-header bg-light py-2">
				                                <strong class="mb-0">결재선</strong>
				                            </div>
				                            <div class="card-body p-2" style="max-height:260px; overflow:auto;">
				                                <table class="table table-sm table-bordered mb-0">
				                                    <thead class="table-light">
				                                        <tr>
				                                            <th style="width:60px;" class="text-center">순서</th>
				                                            <th style="width:120px;" class="text-center">결재자</th>
				                                        </tr>
				                                    </thead>
				                                    <tbody id="applinePreviewBody"><!-- JS-RENDER: 결재선 목록 동적 삽입 --></tbody>
				                                </table>
				                            </div>
				                        </div>
				                    </div>
				
				                    <!-- 오른쪽: 참조선 -->
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
		
		        <!-- 파일 첨부 영역 -->
		        <div class="card mt-3">
		            <div class="card-body">
		                <label class="form-label d-block mb-2">파일 첨부</label>
		                <div class="alert alert-info mb-0">
		                    파일 첨부 기능 아직 미구현
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
        const form = document.getElementById('broadcastDocForm');
        const btnSubmit = document.getElementById('btnSubmit');
        const btnDraft = document.getElementById('btnDraft');
        const btnCancel = document.getElementById('btnCancel');
        const base = '${pageContext.request.contextPath}';  // JSP EL로 컨텍스트 경로 주입
        
     	// 결재선/참조선 상세 영역 / 폼 히든 필드
        const apvTbody = document.getElementById('applinePreviewBody');   // 결재선 표 tbody (JS로 채움)
        const refWrap = document.getElementById('reflinesPreview');		  // 참조선 배지 영역 (JS로 채움)
        const hiddenLines = document.getElementById('approvalLineJson');  // 서버 전송 대비 히든 JSON(결재선)
        const hiddenRefs = document.getElementById('referenceLineJson');  // 서버 전송 대비 히든 JSON(참조선)

        
		/* ==== 접힘 상세(본문) 렌더 ==== */
        
        // 안전한 JSON 파서 (정상 JSON이면 객체/배열로 파싱)
        function safeParse(json, fallback) {
	        try { return JSON.parse(json); } catch (e) { return fallback; }
	    }
        
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
	 	
	 	// 사람 이름 표시 유틸	    
	 	
	    
		// === 결재선 상세 렌더링 ===
		function renderApvDetail()
	    
	    
	 	// === 참조선 상세 렌더링 ===
	 	function renderRefDetail()
	    
	    // 초기 렌더
	    renderApvDetail();
	    renderRefDetail();
        
	    
	 	// ===== 문서 저장 (isDraft=true -> 임시저장, false -> 진행 중) =====
        function submitDocument(isDraft) {
            if (!form) return;

            // 입력값 수집
            const titleEl = form.querySelector('[name="title"]');  	   // 공통 제목
            const contentEl = form.querySelector('[name="content"]');  // 공통 내용
            const userIdEl = form.querySelector('[name="userId"],[name="authorId"]');

            const title = (titleEl ? titleEl.value : '').trim();
            const content = (contentEl ? contentEl.value : '').trim();
            const userId = parseInt(userIdEl ? userIdEl.value : '0', 10) || 0;
            
            const apvLines = getApprovalLines();
            const refLines = getReferenceLines();

            // 방송 폼 필드
            const programName = (form.querySelector('[name="programName"]') || {}).value || '';
            const staffCount = (form.querySelector('[name="staffCount"]') || {}).value || '';
            const sDate = (form.querySelector('[name="broadcastStartDate"]') || {}).value || '';
            const eDate = (form.querySelector('[name="broadcastEndDate"]') || {}).value || '';
            const sTime = (form.querySelector('[name="startTime"]') || {}).value || '';
            const eTime = (form.querySelector('[name="endTime"]') || {}).value || '';

            // 체크된 요일 수집 (value는 'MON'..'SUN')
            const dayNodes = form.querySelectorAll('input[name="broadcastDays"]:checked');
            const days = Array.prototype.map.call(dayNodes, function (n) { return n.value; });
            
            // 전송 DTO
            const dto = {
                userId: userId,
                approvalDocumentTitle: title,
                approvalDocumentContent: content,
                approvalLines: apvLines.map(function (it, idx) {
                    return {
                        userId: it.userId,
                        approvalLineSequence: (it.approvalLineSequence || it.sequence || (idx + 1))
                    };
                }),
                referenceLines: refLines.map(function (it) {
                    if (it.type == 'TEAM') return { teamId: it.teamId, type: 'TEAM' };
                    return { userId: it.userId, type: 'USER' };
                }),
                broadcastForm: {
                    broadcastFormName: programName,
                    broadcastFormCapacity: staffCount ? parseInt(staffCount, 10) || 0 : 0,
                    broadcastFormStartDate: sDate,
                    broadcastFormEndDate: eDate,
                    broadcastFormStartTime: sTime,
                    broadcastFormEndTime: eTime,
                    broadcastDays: days
                }
            };

            // 헤더 (필수: JSON)
            const headers = { 'Content-Type': 'application/json' };
          
            // 요청 중 버튼 잠금
            if (btnSubmit) btnSubmit.disabled = true;
            if (btnDraft) btnDraft.disabled = true;
            if (btnCancel) btnCancel.disabled = true;

            fetch(base + '/approval/broadcast?draft=' + (isDraft ? 'true' : 'false'), {
                method: 'POST',
                headers: headers,
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
                return resp.json();  // 생성된 문서 ID
            })
            .then(function (docId) {
                console.log('방송 문서 저장 완료:', docId, isDraft ? '(임시저장)' : '(상신)');
            	// 저장 후 문서 유형 선택 화면으로 이동
                window.location.href = base + '/approval/document/main';
            })
            .catch(function (e) {
                console.error('방송 문서 저장 오류:', e);
            })
            .finally(function () {
            	// 버튼 잠금 해제
                if (btnSubmit) btnSubmit.disabled = false;
                if (btnDraft) btnDraft.disabled = false;
                if (btnCancel) btnCancel.disabled = false;
            });
        }

        // 이벤트 바인딩
        if (btnSubmit) btnSubmit.addEventListener('click', function () { submitDocument(false); });
        if (btnDraft) btnDraft .addEventListener('click', function () { submitDocument(true); });
        if (btnCancel) btnCancel.addEventListener('click', function () { history.back(); });  // 뒤로가기
    })();
</script>

</body>
</html>