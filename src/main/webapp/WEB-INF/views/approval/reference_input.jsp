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
                    <ul class="nav nav-tabs mb-3">
                        <li class="nav-item">
                            <a class="nav-link active" data-bs-toggle="tab" href="#tab-org2">조직도</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#tab-search2">검색</a>
                        </li>
                    </ul>

                    <div class="row">
                        <!-- 조직도/검색 -->
                        <div class="col-md-5">
                            <div class="tab-content border rounded p-2" style="height: 440px; overflow:auto;">
                                <div id="tab-org2" class="tab-pane fade show active">
                                    <small class="text-muted d-block mb-2">샘플 조직도 (체크 후 ▶ 버튼)</small>
                                    <ul class="list-unstyled">
                                        <li class="form-check">
                                            <input class="form-check-input ref-chk" type="checkbox" id="r101" data-user-id="101" data-user-name="홍길동">
                                            <label class="form-check-label" for="r101">홍길동</label>
                                        </li>
                                        <li class="form-check">
                                            <input class="form-check-input ref-chk" type="checkbox" id="r102" data-user-id="102" data-user-name="김민아">
                                            <label class="form-check-label" for="r102">김민아</label>
                                        </li>
                                        <li class="form-check">
                                            <input class="form-check-input ref-chk" type="checkbox" id="r201" data-user-id="201" data-user-name="박준호">
                                            <label class="form-check-label" for="r201">박준호</label>
                                        </li>
                                    </ul>
                                </div>
                                <div id="tab-search2" class="tab-pane fade">
                                    <div class="input-group">
                                        <input type="text" class="form-control" placeholder="이름 검색">
                                        <button class="btn btn-primary" type="button">검색</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 가운데 이동 버튼 -->
                        <div class="col-md-1 d-flex flex-column align-items-center justify-content-center gap-2">
                            <button type="button" id="btnRefAdd" class="btn btn-outline-primary">&gt;</button>
                            <button type="button" id="btnRefRemove" class="btn btn-outline-secondary">&lt;</button>
                        </div>

                        <!-- 오른쪽: 선택 결과 -->
                        <div class="col-md-6">
                            <div class="border rounded p-2" style="height: 440px; overflow:auto;">
                                <ul class="list-group" id="refList">
                                    <!-- 동적 추가 -->
                                </ul>
                            </div>
                        </div>
                    </div>

                    <!-- 하단 버튼 -->
                    <div class="d-flex justify-content-end gap-2 mt-3">
                        <button type="button" id="btnRefApply" class="btn btn-outline-success">적용</button>
                        <a href="javascript:history.back();" class="btn btn-outline-secondary">닫기</a>
                    </div>

                    <input type="hidden" id="referenceLinesJson" value="[]">
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
        const ul = document.getElementById('refList');
        const add = document.getElementById('btnRefAdd');
        const remove = document.getElementById('btnRefRemove');
        const apply = document.getElementById('btnRefApply');
        const jsonField = document.getElementById('referenceLinesJson');

        function addSelected() {
            document.querySelectorAll('.ref-chk:checked').forEach(chk => {
                const id = chk.getAttribute('data-user-id');
                const name = chk.getAttribute('data-user-name');
                if (ul.querySelector('li[data-user-id="' + id + '"]')) return;

                const li = document.createElement('li');
                li.className = 'list-group-item d-flex justify-content-between align-items-center';
                li.setAttribute('data-user-id', id);
                li.innerHTML = '<span>' + name + '</span>' +
                               '<button type="button" class="btn btn-outline-danger btn-sm btn-del">삭제</button>';
                ul.appendChild(li);
                chk.checked = false;
            });
        }

        function removeSelected() {
            ul.querySelectorAll('.list-group-item.active').forEach(li => li.remove());
        }
        
        ul.addEventListener('click', function (e) {
            const li = e.target.closest('li');
            if (!li) return;
            if (e.target.classList.contains('btn-del')) {
                li.remove();
            } else {
                li.classList.toggle('active');
            }
        });

        function applySelection() {
            const list = [];
            ul.querySelectorAll('li').forEach(li => {
                list.push({ userId: parseInt(li.getAttribute('data-user-id'), 10) });
            });
            const json = JSON.stringify(list);
            jsonField.value = json;
            localStorage.setItem('referenceLines', json);
            history.back();
        }

        add.addEventListener('click', addSelected);
        remove.addEventListener('click', removeSelected);
        apply.addEventListener('click', applySelection);
    })();
</script>

</body>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
</html>
