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
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#tab-search">검색</a>
                        </li>
                    </ul>

                    <div class="row">
                        <!-- 조직도 / 검색 패널 -->
                        <div class="col-md-5">
                            <div class="tab-content border rounded p-2" style="height: 440px; overflow:auto;">
                                <!-- 조직도 -->
                                <div id="tab-org" class="tab-pane fade show active">
                                    <small class="text-muted d-block mb-2">샘플 조직도 (체크 후 ▶ 버튼)</small>
                                    <ul class="list-unstyled">
                                        <li class="mb-2">
                                            <i class="uil uil-building"></i> 방송국 본사
                                            <ul class="list-unstyled ms-3 mt-1">
                                                <li>
                                                    <i class="uil uil-sitemap"></i> 편성제작부
                                                    <ul class="list-unstyled ms-3 mt-1">
                                                        <li class="form-check">
                                                            <input class="form-check-input user-chk" type="checkbox" id="u101" data-user-id="101" data-user-name="홍길동" data-user-pos="사원">
                                                            <label class="form-check-label" for="u101">홍길동 (사원)</label>
                                                        </li>
                                                        <li class="form-check">
                                                            <input class="form-check-input user-chk" type="checkbox" id="u102" data-user-id="102" data-user-name="김민아" data-user-pos="대리">
                                                            <label class="form-check-label" for="u102">김민아 (대리)</label>
                                                        </li>
                                                    </ul>
                                                </li>
                                                <li class="mt-2">
                                                    <i class="uil uil-sitemap"></i> 영상기술부
                                                    <ul class="list-unstyled ms-3 mt-1">
                                                        <li class="form-check">
                                                            <input class="form-check-input user-chk" type="checkbox" id="u201" data-user-id="201" data-user-name="박준호" data-user-pos="과장">
                                                            <label class="form-check-label" for="u201">박준호 (과장)</label>
                                                        </li>
                                                        <li class="form-check">
                                                            <input class="form-check-input user-chk" type="checkbox" id="u202" data-user-id="202" data-user-name="이지은" data-user-pos="차장">
                                                            <label class="form-check-label" for="u202">이지은 (차장)</label>
                                                        </li>
                                                    </ul>
                                                </li>
                                            </ul>
                                        </li>
                                    </ul>
                                </div>

                                <!-- 검색 -->
                                <div id="tab-search" class="tab-pane fade">
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="keyword" placeholder="이름/부서 검색">
                                        <button class="btn btn-primary" type="button" id="btnSearch">검색</button>
                                    </div>
                                    <div class="mt-2">
                                        <div class="form-check">
                                            <input class="form-check-input user-chk" type="checkbox" id="u301" data-user-id="301" data-user-name="정해인" data-user-pos="사원">
                                            <label class="form-check-label" for="u301">정해인 (사원)</label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input user-chk" type="checkbox" id="u302" data-user-id="302" data-user-name="한소희" data-user-pos="대리">
                                            <label class="form-check-label" for="u302">한소희 (대리)</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 가운데 이동 버튼 -->
                        <div class="col-md-1 d-flex flex-column align-items-center justify-content-center gap-2">
                            <button type="button" id="btnAdd" class="btn btn-outline-primary">&gt;</button>
                            <button type="button" id="btnRemove" class="btn btn-outline-secondary">&lt;</button>
                            <button type="button" id="btnReset" class="btn btn-outline-danger">&#x21BA;</button>
                        </div>

                        <!-- 오른쪽: 결재선 정보 -->
                        <div class="col-md-6">
                            <div class="border rounded p-2" style="height: 440px; overflow:auto;">
                                <table class="table table-sm table-hover align-middle text-center" id="tblLines">
								    <thead class="table-light">
								        <tr>
								        	<th style="width:10%;" class="text-center">선택</th>
								           	<th style="width:10%;" class="text-center">순서</th>
											<th style="width:15%;" class="text-center">유형</th>
											<th style="width:25%;" class="text-center">결재자</th>
											<th style="width:20%;" class="text-center">이동</th>
								        </tr>
								    </thead>
								    <tbody></tbody>
								</table>
                            </div>
                            <small class="text-muted d-block mt-2">※ 드래그 대신 ▲/▼ 버튼으로 순서를 조정합니다.</small>
                        </div>
                    </div>

                    <!-- 하단 버튼 -->
                    <div class="d-flex justify-content-end gap-2 mt-3">
                        <button type="button" id="btnApply" class="btn btn-outline-success">적용</button>
                        <a href="javascript:history.back();" class="btn btn-outline-secondary">닫기</a>
                    </div>

                    <!-- 숨김필드 (필요 시 폼 제출로 변경 가능) -->
                    <input type="hidden" id="approvalLinesJson" value="[]">

                </div>
            </div>

        </div>
    </div>
</div>

<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>

<script>
    (function () {
        const tblBody = document.querySelector('#tblLines tbody');
        const addBtn = document.getElementById('btnAdd');
        const removeBtn = document.getElementById('btnRemove');
        const resetBtn = document.getElementById('btnReset');
        const applyBtn = document.getElementById('btnApply');
        const jsonField = document.getElementById('approvalLinesJson');

        function refreshOrder() {
            const rows = tblBody.querySelectorAll('tr');
            rows.forEach((tr, idx) => tr.querySelector('.seq').innerText = (idx + 1));
        }

        function addSelectedUsers() {
            const checked = document.querySelectorAll('.user-chk:checked');
            checked.forEach(chk => {
                const uid = chk.getAttribute('data-user-id');
                const name = chk.getAttribute('data-user-name');
                const pos = chk.getAttribute('data-user-pos');
                if (tblBody.querySelector('tr[data-user-id="' + uid + '"]')) return;

                const tr = document.createElement('tr');
                tr.setAttribute('data-user-id', uid);
                tr.innerHTML =
                	'<td class="text-center"><input type="checkbox" class="row-chk"></td>' +
                    '<td class="text-center seq"></td>' +
                    '<td class="text-center">결재</td>' +
                    '<td>' + name + ' <span class="text-muted">(' + pos + ')</span></td>' +
                    '<td class="text-center">' +
                        '<div class="btn-group btn-group-sm" role="group">' +
                            '<button type="button" class="btn btn-outline-primary btn-up" style="font-size:0.53rem;">▲</button>' +
                            '<button type="button" class="btn btn-outline-primary btn-down" style="font-size:0.55rem;">▼</button>' +
                        '</div>' +
                    '</td>';
                tblBody.appendChild(tr);
                chk.checked = false;
            });
            refreshOrder();
        }

     	// 좌측 "<" 버튼 → 체크된 행 제거
        function removeSelectedRows() {
            const selected = tblBody.querySelectorAll('input.row-chk:checked');
            selected.forEach(chk => chk.closest('tr').remove());
            refreshOrder();
        }

        // 전체 초기화 (빨간색 '초기화' 버튼)
        function resetAll() {
            tblBody.innerHTML = '';
            document.querySelectorAll('.user-chk:checked').forEach(chk => chk.checked = false);
            refreshOrder();
        }

        // 행 선택 토글(선택/해제만)
        tblBody.addEventListener('click', function (e) {
            const tr = e.target.closest('tr');
            if (!tr) return;
            if (e.target.closest('.btn-up') || e.target.closest('.btn-down')) return;
            tr.classList.toggle('table-active');
        });

        // 위/아래 이동
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

        // 적용: JSON 저장 후 이전 페이지로
        function applySelection() {
            const rows = tblBody.querySelectorAll('tr');
            const list = [];
            rows.forEach((tr, idx) => {
                list.push({
                    userId: parseInt(tr.getAttribute('data-user-id'), 10),
                    approvalLineSequence: idx + 1,
                    approvalLineStatus: '대기',
                    approvalLineComment: '',
                    role: tr.querySelector('.role').value
                });
            });
            const json = JSON.stringify(list);
            jsonField.value = json;
            localStorage.setItem('approvalLines', json);
            history.back();
        }

        addBtn.addEventListener('click', addSelectedUsers);
        removeBtn.addEventListener('click', removeSelectedRows);
        resetBtn.addEventListener('click', resetAll);
        applyBtn.addEventListener('click', applySelection);
    })();
</script>

</body>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
</html>