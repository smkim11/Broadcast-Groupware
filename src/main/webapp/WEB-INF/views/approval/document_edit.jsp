<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- 날짜 포맷 -->
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>		<!-- 문서번호 포맷 -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Document Edit</title>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<link href="${ctx}/resources/css/custom-approval.css?v=20250903" rel="stylesheet" type="text/css" />
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
                <h4>
                    <c:choose>
				        <c:when test="${docType eq 'BROADCAST'}">방송 문서 수정</c:when>
				        <c:when test="${docType eq 'VACATION'}">휴가 문서 수정</c:when>
				        <c:otherwise>일반 문서 수정</c:otherwise>
				    </c:choose>
				    </h4>
                </div>
                <div class="col-auto d-flex gap-2">
                    <a href="${ctx}/approval/line/input?mode=edit&docId=${document.approvalDocumentId}" class="btn btn-outline-primary">결재선</a>
                    <a href="${ctx}/approval/reference/input?mode=edit&docId=${document.approvalDocumentId}" class="btn btn-outline-primary">참조선</a>
                    <button id="btnUpdate" type="button" class="btn btn-outline-success">수정</button>
                    <a href="${ctx}/approval/document/detail/${document.approvalDocumentId}" class="btn btn-outline-secondary">취소</a>
                </div>
            </div>

            <!-- 본문 폼 -->
            <form id="commonDocForm" method="post">
                <input type="hidden" name="documentType" value="COMMON">

                <!-- 선택 결과(JSON) - 미리보기/전송 동기화용 -->
                <input type="hidden" id="approvalLineJson" name="approvalLineJson" value="[]">
                <input type="hidden" id="referenceLineJson" name="referenceLineJson" value="[]">

                <!-- 공통 정보 표 -->
			    <div class="card">
				    <div class="card-body p-0">
				        <table class="table table-bordered mb-0 align-middle">
				            <tbody>
				                <tr>
				                    <th class="bg-light text-center">문서 번호</th>
				                    <td>
				                        <fmt:formatNumber value="${document.approvalDocumentId}"
				                                          type="number" minIntegerDigits="6" groupingUsed="false" />
				                    </td>
				                    <th class="bg-light text-center">기안일</th>
				                    <td>
				                        <c:choose>
				                            <c:when test="${not empty document.createDate}">
				                                ${fn:substring(document.createDate, 0, 10)}
				                            </c:when>
				                            <c:otherwise>-</c:otherwise>
				                        </c:choose>
				                    </td>
				                </tr>
				                <tr>
				                    <th class="bg-light text-center">소속</th>
				                    <td>
				                        <c:out value="${document.departmentName}"/> / <c:out value="${document.teamName}"/>
				                    </td>
				                    <th class="bg-light text-center">기안자</th>
				                    <td>
				                        <c:out value="${document.fullName}"/> (<c:out value="${document.userRank}"/>)
				                    </td>
				                </tr>
				                <tr>
				                    <th class="bg-light text-center">제목</th>
				                    <td colspan="3">
				                        <input type="text"
				                               name="approvalDocumentTitle"
				                               class="form-control"
				                               value="${document.approvalDocumentTitle}"
				                               placeholder="제목을 입력하세요">
				                    </td>
				                </tr>
				
				                <%-- 타입별 폼 --%>
				                <c:choose>
				                    <%-- 휴가 폼 (편집용) --%>
				                    <c:when test="${docType eq 'VACATION'}">
				                        <tr>
				                            <th class="bg-light text-center">휴가 종류</th>
				                            <td>
				                                <div class="d-flex align-items-center gap-3">
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="radio"
				                                               name="vacationFormType" value="연차"
				                                               <c:if test="${vacationForm.vacationFormType eq '연차'}">checked</c:if>> 연차
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="radio"
				                                               name="vacationFormType" value="반차"
				                                               <c:if test="${vacationForm.vacationFormType eq '반차'}">checked</c:if>> 반차
				                                    </label>
				                                </div>
				                            </td>
				                            <th class="bg-light text-center">반차 시간</th>
				                            <td>
				                                <div class="d-flex align-items-center gap-3" id="halfTimeGroup">
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="radio"
				                                               name="vacationFormHalfType" value="오전"
				                                               <c:if test="${vacationForm.vacationFormHalfType eq '오전'}">checked</c:if>> 오전
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="radio"
				                                               name="vacationFormHalfType" value="오후"
				                                               <c:if test="${vacationForm.vacationFormHalfType eq '오후'}">checked</c:if>> 오후
				                                    </label>
				                                </div>
				                            </td>
				                        </tr>
				                        <tr>
				                            <th class="bg-light text-center">휴가 시작일</th>
				                            <td>
				                                <input type="date" class="form-control"
				                                       name="vacationFormStartDate"
				                                       value="${fn:substring(vacationForm.vacationFormStartDate,0,10)}">
				                            </td>
				                            <th class="bg-light text-center">휴가 종료일</th>
				                            <td>
				                                <input type="date" class="form-control"
				                                       name="vacationFormEndDate"
				                                       value="${fn:substring(vacationForm.vacationFormEndDate,0,10)}">
				                            </td>
				                        </tr>
				                    </c:when>
				
				                    <%-- 방송 폼 (편집용) --%>
				                    <c:when test="${docType eq 'BROADCAST'}">
				                        <tr>
				                            <th class="bg-light text-center">프로그램명</th>
				                            <td colspan="3">
				                                <input type="text" class="form-control"
				                                       name="broadcastFormName"
				                                       value="<c:out value='${broadcastForm.broadcastFormName}'/>"
				                                       placeholder="예) 뉴스와이드">
				                            </td>
				                        </tr>
				                        <tr>
				                            <th class="bg-light text-center">담당 총 인원</th>
				                            <td>
				                                <input type="number" class="form-control" min="0" step="1"
				                                       name="broadcastFormCapacity"
				                                       value="<c:out value='${broadcastForm.broadcastFormCapacity}'/>">
				                            </td>
				                            <th class="bg-light text-center">방송 요일</th>
				                            <td>
				                                <div class="d-flex flex-wrap gap-2">
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="MON"
				                                               <c:if test="${broadcastForm.broadcastMonday == 1}">checked</c:if>> 월
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="TUE"
				                                               <c:if test="${broadcastForm.broadcastTuesday == 1}">checked</c:if>> 화
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="WED"
				                                               <c:if test="${broadcastForm.broadcastWednesday == 1}">checked</c:if>> 수
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="THU"
				                                               <c:if test="${broadcastForm.broadcastThursday == 1}">checked</c:if>> 목
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="FRI"
				                                               <c:if test="${broadcastForm.broadcastFriday == 1}">checked</c:if>> 금
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="SAT"
				                                               <c:if test="${broadcastForm.broadcastSaturday == 1}">checked</c:if>> 토
				                                    </label>
				                                    <label class="form-check form-check-inline">
				                                        <input class="form-check-input" type="checkbox" name="broadcastDays" value="SUN"
				                                               <c:if test="${broadcastForm.broadcastSunday == 1}">checked</c:if>> 일
				                                    </label>
				                                </div>
				                            </td>
				                        </tr>
				                        <tr>
				                            <th class="bg-light text-center">방송 시작일</th>
				                            <td>
				                                <input type="date" class="form-control"
				                                       name="broadcastFormStartDate"
				                                       value="${fn:substring(broadcastForm.broadcastFormStartDate,0,10)}">
				                            </td>
				                            <th class="bg-light text-center">방송 종료일</th>
				                            <td>
				                                <input type="date" class="form-control"
				                                       name="broadcastFormEndDate"
				                                       value="${fn:substring(broadcastForm.broadcastFormEndDate,0,10)}">
				                            </td>
				                        </tr>
				                        <tr>
				                            <th class="bg-light text-center">방송 시작 시간</th>
				                            <td>
				                                <input type="time" class="form-control"
				                                       name="broadcastFormStartTime"
				                                       value="${fn:substring(broadcastForm.broadcastFormStartTime,0,5)}">
				                            </td>
				                            <th class="bg-light text-center">방송 종료 시간</th>
				                            <td>
				                                <input type="time" class="form-control"
				                                       name="broadcastFormEndTime"
				                                       value="${fn:substring(broadcastForm.broadcastFormEndTime,0,5)}">
				                            </td>
				                        </tr>
				                    </c:when>
				                </c:choose>
				
				                <tr>
				                    <th class="bg-light text-center">내용</th>
				                    <td colspan="3">
				                        <textarea name="approvalDocumentContent" rows="10" class="form-control"
				                                  placeholder="내용을 입력하세요"><c:out value="${document.approvalDocumentContent}"/></textarea>
				                    </td>
				                </tr>
				            </tbody>
				        </table>
				    </div>
				</div>


                <!-- 결재선 / 참조선 상세 (기본 펼침) -->
                <div class="accordion mt-3" id="lineAccordion">
                    <div class="accordion-item">
                        <h2 class="accordion-header" id="headingLines">
                            <button class="accordion-button fw-semibold text-dark" type="button" data-bs-toggle="collapse"
                                    data-bs-target="#collapseLines" aria-expanded="true" aria-controls="collapseLines">
                                결재선 / 참조선
                            </button>
                        </h2>
                        <div id="collapseLines" class="accordion-collapse collapse show" aria-labelledby="headingLines" data-bs-parent="#lineAccordion">
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
                                                    <tbody id="applinePreviewBody"><!-- JS-RENDER --></tbody>
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
                                                <div id="reflinesPreview" class="d-flex flex-wrap gap-2"><!-- JS-RENDER --></div>
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
        // === 기본 엘리먼트/상수 ===
        const form = document.getElementById('commonDocForm');
        const btnUpdate = document.getElementById('btnUpdate');
        const base = '${ctx}';
        const docId = ${document.approvalDocumentId};

        // === 미리보기/히든 ===
        const apvTbody = document.getElementById('applinePreviewBody');
        const refWrap  = document.getElementById('reflinesPreview');
        const hiddenLines = document.getElementById('approvalLineJson');
        const hiddenRefs  = document.getElementById('referenceLineJson');

        // === 문서 공통 정보 ===
        const docDept = ('${document.departmentName}' || '').trim();
        const docTeam = ('${document.teamName}' || '').trim();
        const docType = ('${docType}' || 'COMMON').trim();

        // 타입별 수정 URL 결정 (수정 API 엔드포인트 분기)
        function updateUrlByType() {
            switch (docType) {
                case 'VACATION':  return base + '/approval/vacation/update/'  + docId;
                case 'BROADCAST': return base + '/approval/broadcast/update/' + docId;
                default:          return base + '/approval/common/update/'    + docId;
            }
        }

        // === 서버에서 내려온 초기 데이터(JS 배열로 주입) ===
        var srvApv = [
        <c:forEach var="al" items="${approvalLines}" varStatus="s">
            { userId: ${al.userId}, approvalLineSequence: ${al.approvalLineSequence},
              fullName: '<c:out value="${al.fullName}"/>', userRank: '<c:out value="${al.userRank}"/>' }
            <c:if test="${!s.last}">,</c:if>
        </c:forEach>
        ];
        
        var srvRefTeams = [
        <c:forEach var="t" items="${referenceTeams}" varStatus="s">
            { teamId: ${t.teamId}, teamName: '<c:out value="${t.teamName}"/>',
              departmentName: '<c:out value="${t.departmentName}"/>' }
            <c:if test="${!s.last}">,</c:if>
        </c:forEach>
        ];
        
        var srvRefIndividuals = [
        <c:forEach var="p" items="${referenceIndividuals}" varStatus="s">
            { userId: ${p.userId}, fullName: '<c:out value="${p.fullName}"/>',
              userRank: '<c:out value="${p.userRank}"/>', departmentName: '<c:out value="${p.departmentName}"/>',
              teamName: '<c:out value="${p.teamName}"/>' }
            <c:if test="${!s.last}">,</c:if>
        </c:forEach>
        ];

        // === 공통 유틸 ===
        function safeParse(json, fb) {
            if (typeof json !== 'string' || !json.trim()) return fb;
            try { return JSON.parse(json); } catch { return fb; }
        }
        // 세션 -> 히든 필드로 동기화 (디버깅/백업 용도)
        function syncHiddenFromSS() {
            if (hiddenLines) hiddenLines.value = sessionStorage.getItem('approvalLines') || '[]';
            if (hiddenRefs) hiddenRefs.value  = sessionStorage.getItem('referenceLines') || '[]';
        }
        function getApprovalLines()  { return safeParse(sessionStorage.getItem('approvalLines')  || '[]', []); }
        function getReferenceLines() { return safeParse(sessionStorage.getItem('referenceLines') || '[]', []); }

        // 최초 1회: 서버 데이터 -> sessionStorage (라인/참조 페이지 경유 시 보존)
        function loadFromServerAndInit() {
            try {
                const alreadyApv = safeParse(sessionStorage.getItem('approvalLines') || '[]', []);
                const alreadyRef = safeParse(sessionStorage.getItem('referenceLines') || '[]', []);
                if (alreadyApv.length > 0 || alreadyRef.length > 0) {
                    sessionStorage.setItem('flowKeep', '1');  // 돌아온 흐름 유지 플래그
                    syncLinesPreview();
                    return;
                }

                // 서버 모델 -> 프리뷰에 필요한 필드로 매핑
                const apvForUI = (Array.isArray(srvApv) ? srvApv : []).map(function (al, idx) {
                    return {
                        userId: al.userId,
                        approvalLineSequence: al.approvalLineSequence || (idx + 1),
                        name: al.fullName || '',
                        userRank: al.userRank || '',
                        dept: (al.departmentName || docDept || '').trim(),
                        team: (al.teamName || docTeam || '').trim()
                    };
                });

                const refForUI = [];
                (Array.isArray(srvRefTeams) ? srvRefTeams : []).forEach(function (t) {
                    refForUI.push({ teamId: t.teamId, name: t.teamName || '', dept: t.departmentName || '' });
                });
                (Array.isArray(srvRefIndividuals) ? srvRefIndividuals : []).forEach(function (p) {
                    refForUI.push({ userId: p.userId, name: p.fullName || '', userRank: p.userRank || '', dept: p.departmentName || '', team: p.teamName || '' });
                });

                sessionStorage.setItem('approvalLines', JSON.stringify(apvForUI));
                sessionStorage.setItem('referenceLines', JSON.stringify(refForUI));
                sessionStorage.setItem('flowKeep', '1');
            } catch (e) {
                console.warn('초기 세션 구성 실패:', e);
            } finally {
                syncLinesPreview();
            }
        }

        // === 프리뷰 렌더링 ===
        function renderApvDetail() {
            if (!apvTbody) return;
            const arr = getApprovalLines();
            apvTbody.innerHTML = '';
            arr.slice()
               .sort(function (a, b) {
                   var sa = Number(a.approvalLineSequence ?? a.sequence ?? 999);
                   var sb = Number(b.approvalLineSequence ?? b.sequence ?? 999);
                   return sa - sb;
               })
               .forEach(function (it, idx) {
                   const tr = document.createElement('tr');
                   tr.innerHTML =
                       '<td class="text-center">' + (it.approvalLineSequence || it.sequence || (idx + 1)) + '</td>' +
                       '<td class="text-center">' + ((it.name || '') + (it.userRank ? ' (' + it.userRank + ')' : '')) + '</td>' +
                       '<td class="text-center">' + ([it.dept, it.team].filter(Boolean).join(' / ') || '-') + '</td>';
                   apvTbody.appendChild(tr);
               });
        }
        
        function formatUserDisplay(u) {
            var name = (u.name || u.userName || '');
            var rank = u.userRank ? ' (' + u.userRank + ')' : '';
            var parts = []; if (u.dept) parts.push(u.dept); if (u.team) parts.push(u.team);
            return name + rank + (parts.length ? ' - ' + parts.join(' / ') : '');
        }
        
        function renderRefDetail() {
            if (!refWrap) return;
            const arr = getReferenceLines();
            refWrap.innerHTML = '';
            arr.forEach(function (it) {
                const badge = document.createElement('span');
                badge.className = 'badge bg-light fs-6 px-5 py-2 m-1';
                badge.textContent = (it.teamId != null && it.userId == null)
                    ? ('👥 팀: ' + (it.name || '팀') + (it.dept ? ' (' + it.dept + ')' : ''))
                    : ('👤 ' + (formatUserDisplay(it) || ('ID: ' + (it.userId == null ? '' : it.userId))));
                refWrap.appendChild(badge);
            });
        }
        
        // 데이터가 있을 때만 펼침
        function expandLinesIfHasData() {
            try {
                const hasAny = getApprovalLines().length > 0 || getReferenceLines().length > 0;
                const collapseEl = document.getElementById('collapseLines');
                if (!collapseEl) return;
                const inst = bootstrap.Collapse.getOrCreateInstance(collapseEl, { toggle: false });
                hasAny ? inst.show() : inst.hide();
            } catch (e) {}
        }
        function syncLinesPreview() {
            syncHiddenFromSS();
            try { renderApvDetail(); } catch (e) {}
            try { renderRefDetail(); } catch (e) {}
            try { expandLinesIfHasData(); } catch (e) {}
        }

        // 휴가: 반차 선택 시에만 반차 시간 활성화
        function setupVacationHalfToggle() {
            if (docType !== 'VACATION') return;
            const typeRadios = form.querySelectorAll('input[name="vacationFormType"]');
            const halfRadios = form.querySelectorAll('input[name="vacationFormHalfType"]');
            function sync() {
                const isHalf = Array.from(typeRadios).some(r => r.checked && r.value == '반차');
                halfRadios.forEach(r => { r.disabled = !isHalf; if (!isHalf) r.checked = false; });
            }
            typeRadios.forEach(r => r.addEventListener('change', sync));
            sync();
        }

        // === 초기화 & 복귀시 리프레시 ===
        loadFromServerAndInit();
        setupVacationHalfToggle();
        window.addEventListener('pageshow', syncLinesPreview);
        window.addEventListener('focus',    syncLinesPreview);
        document.addEventListener('visibilitychange', function () {
            if (!document.hidden) syncLinesPreview();
        });

        // 페이지 이탈 시 세션 스토리지 정리(라인/참조 페이지 이동 시엔 유지)
        window.addEventListener('pagehide', function () {
            const keep = sessionStorage.getItem('flowKeep') == '1';
            sessionStorage.setItem('flowKeep', '0');
            if (keep) return;
            sessionStorage.removeItem('approvalLines');
            sessionStorage.removeItem('referenceLines');
        });

        // 안전 파서
        function getUIJson(id) {
            try { return JSON.parse(sessionStorage.getItem(id) || '[]'); } catch { return []; }
        }

        // === 수정 저장 ===
        function submitUpdate() {
            if (!form) return;

            const title   = (form.querySelector('[name="approvalDocumentTitle"]')?.value || '').trim();
            const content = (form.querySelector('[name="approvalDocumentContent"]')?.value || '').trim();
            if (!title) { alert('제목을 입력하세요.'); return; }

            // 결재선: 3명 초과는 경고 후 상위 3명만 전송 (백엔드도 다시 검증)
            let apvLines = getUIJson('approvalLines').map(function (it, idx) {
                return { userId: it.userId, approvalLineSequence: it.approvalLineSequence || (idx + 1) };
            });
            
            if (apvLines.length > 3) {
                alert('결재선은 최대 3명까지 저장됩니다. 상위 3명만 전송합니다.');
                apvLines = apvLines.slice(0, 3).map((l, i) => ({ userId: l.userId, approvalLineSequence: i + 1 }));
            }

            // 참조선: 개인/팀 분리하여 DTO 구성 (팀은 서버에서 개인으로 전개)
            const refRaw = getUIJson('referenceLines');
            const refLines   = [];
            const refTeamIds = [];
            refRaw.forEach(function (it) {
                if (it.teamId) refTeamIds.push(it.teamId);
                else if (it.userId) refLines.push({ userId: it.userId });
            });

            // 기본 DTO(공통)
            const dto = {
                approvalDocumentTitle: title,
                approvalDocumentContent: content,
                approvalLines: apvLines,
                referenceLines: refLines,
                referenceTeamIds: refTeamIds
            };

            // 타입별 폼 수집 + 간단 검증
            if (docType == 'VACATION') {
                const vacType = form.querySelector('input[name="vacationFormType"]:checked')?.value || '';
                const halfSel = form.querySelector('input[name="vacationFormHalfType"]:checked')?.value || null;
                const sDate = form.querySelector('[name="vacationFormStartDate"]')?.value || '';
                const eDate = form.querySelector('[name="vacationFormEndDate"]')?.value || '';
                
                if (vacType == '반차' && !halfSel) { alert('반차 시간(오전/오후)을 선택하세요.'); return; }
                if (sDate && eDate && sDate > eDate) { alert('휴가 기간이 올바르지 않습니다.'); return; }
                dto.vacationForm = {
                    vacationFormType: vacType,
                    vacationFormHalfType: (vacType == '반차' ? halfSel : null),
                    vacationFormStartDate: sDate,
                    vacationFormEndDate: eDate
                };
                
            } else if (docType == 'BROADCAST') {
                const nameEl  = form.querySelector('[name="broadcastFormName"]');
                const capEl   = form.querySelector('[name="broadcastFormCapacity"]');
                const sDateEl = form.querySelector('[name="broadcastFormStartDate"]');
                const eDateEl = form.querySelector('[name="broadcastFormEndDate"]');
                const sTimeEl = form.querySelector('[name="broadcastFormStartTime"]');
                const eTimeEl = form.querySelector('[name="broadcastFormEndTime"]');
                
                const days = Array.from(form.querySelectorAll('input[name="broadcastDays"]:checked'))
                    .map(n => String(n.value || '').trim().toUpperCase())
                    .filter(Boolean);
                dto.broadcastForm = {
                    broadcastFormName: nameEl?.value || '',
                    broadcastFormCapacity: (capEl?.value ? (parseInt(capEl.value, 10) || 0) : 0),
                    broadcastFormStartDate: sDateEl?.value || '',
                    broadcastFormEndDate: eDateEl?.value || '',
                    broadcastFormStartTime: sTimeEl?.value || '',
                    broadcastFormEndTime: eTimeEl?.value || '',
                    broadcastDays: days
                };
            }

            // 전송 (성공 시 상세 페이지로 이동)
            const url = updateUrlByType();
            btnUpdate.disabled = true;
            fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(dto)
            })
            .then(function (resp) {
                if (!resp.ok) return resp.text().then(t => Promise.reject(new Error(t || ('HTTP ' + resp.status))));
                return resp.json().catch(() => ({}));
            })
            .then(function () {
                sessionStorage.removeItem('approvalLines');
                sessionStorage.removeItem('referenceLines');
                sessionStorage.setItem('flowKeep', '0');
                window.location.href = base + '/approval/document/detail/' + docId;
            })
            .catch(function (e) {
                console.error('문서 수정 오류:', e);
                alert('수정 중 오류가 발생했습니다.\n' + (e && e.message ? e.message : e));
            })
            .finally(function () { btnUpdate.disabled = false; });
        }

        // 버튼 바인딩
        if (btnUpdate) btnUpdate.addEventListener('click', submitUpdate);
    })();
</script>

</body>
</html>