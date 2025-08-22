<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Document Common</title>
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
		    <form id="commonDocForm" method="post" action="${pageContext.request.contextPath}/approval/common">
		        <input type="hidden" name="documentType" value="COMMON">
		        
		        <!-- 제출: 'N' / 임시저장: 'Y' -->
    			<input type="hidden" id="saveFlag" name="approvalDocumentSave" value="N">
		
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
			                            <input type="text" id="docTitle" name="approvalDocumentTitle" class="form-control" placeholder="제목을 입력하세요">
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

<script>
    (function () {
        const form = document.getElementById('commonDocForm');
        const btnSubmit = document.getElementById('btnSubmit');
        const btnDraft = document.getElementById('btnDraft');
        const btnCancel = document.getElementById('btnCancel');
        const base = '${pageContext.request.contextPath}';  // JSP EL로 컨텍스트 경로 주입

        // 상신/임시저장 공통 처리 (isDraft=true -> 임시저장, false -> 상신)
        function submitDocument(isDraft) {
            if (!form) return;

            // 입력값 수집
            const titleEl = form.querySelector('[name="approvalDocumentTitle"]');
            const contentEl = form.querySelector('[name="approvalDocumentContent"]');
            const userIdEl  = form.querySelector('[name="userId"]');
            
            const title   = (titleEl ? titleEl.value : '').trim();
            const content = (contentEl ? contentEl.value : '').trim();
            const userId  = parseInt(userIdEl ? userIdEl.value : '0', 10) || 0;
            
            // 전송 DTO (결재선/참조선은 추후 연결)
            const dto = {
                userId: userId,
                approvalDocumentTitle: title,
                approvalDocumentContent: content,
                approvalLines: [],
                referenceLines: []
            };
            
         	// 헤더 (필수: JSON)
            const headers = { 'Content-Type': 'application/json' };
            
            // 요청 중 버튼 잠금
            if (btnSubmit) btnSubmit.disabled = true;
            if (btnDraft) btnDraft.disabled = true;
            if (btnCancel) btnCancel.disabled = true;
            
            fetch(base + '/approval/common?draft=' + (isDraft ? 'true' : 'false'), {
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
                console.log('일반 문서 저장 완료:', docId, isDraft ? '(임시저장)' : '(상신)');
            	// 저장 후 문서 유형 선택 화면으로 이동
                window.location.href = base + '/approval/document/main';
            })
            .catch(function (e) {
                console.error('저장 오류:', e);
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
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
</html>