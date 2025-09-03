<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시판</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
</head>
<style>
/* 스위치 공통 */
.switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 24px;
}

/* 숨김 체크박스 */
.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

/* 슬라이더 */
.slider {
    position: absolute;
    cursor: pointer;
    top: 0; left: 0; right: 0; bottom: 0;
    background-color: #e74c3c; /* 비활성화 색 */
    transition: 0.4s;
    border-radius: 24px;
}

/* 슬라이더 원 */
.slider:before {
    position: absolute;
    content: "";
    height: 18px; width: 18px;
    left: 3px; bottom: 3px;
    background-color: white;
    transition: 0.4s;
    border-radius: 50%;
}

/* 체크 시 색상 변경 & 원 이동 */
input:checked + .slider {
    background-color: #28a745; /* 활성화 색 */
}

input:checked + .slider:before {
    transform: translateX(26px);
}

/* 검색 */
/* 검색 폼 전체 영역 */
.searchForm {
    margin-top: 15px;
}

/* 검색 영역 박스 */
.search-main {
    display: flex;
    align-items: center;
    gap: 8px; 
    padding: 10px 15px;
    border-radius: 8px;
}

/* 셀렉트박스 */
.search-main select {
    padding: 6px 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
    background-color: #fff;
    font-size: 14px;
}

/* 입력창 */
.search-main input[type="text"] {
    flex: 1; /* 가로 공간 꽉 채움 */
    border-radius: 6px;
    font-size: 14px;
}

/* 검색 버튼 */
.search-main button {
    border-radius: 6px;
    padding: 6px 14px;
    font-size: 14px;
    transition: all 0.2s ease-in-out;
}

#insertPostModal {
    display: inline-block; /* 버튼 기본 표시 유지 */
}

/* 버튼 우측 정렬 */
.button-container {
    display: flex;
    justify-content: flex-end; /* 우측 정렬 */
    margin-bottom: 1rem; /* 필요 시 여백 */
}


</style>

<body>
<div>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>
<div class="main-content">
	<div class="page-content">
		<div class="container-fluid">
		
       	 <div class="row">
               <div class="col-12">
                   <div class="page-title-box d-flex align-items-center justify-content-between">
                       <h4 class="mb-0">게시판 관리</h4>
                       <div class="page-title-right">
                           <ol class="breadcrumb m-0">
                               <li class="breadcrumb-item">게시판</li>
                           </ol>
                       </div>
                   </div>
               </div>
           </div>
           
			<div class="button-container">
				<button id="adminBoard" class="adminBoard btn btn-outline-primary waves-effect waves-light">게시판 관리</button>
			</div>
           
			<table class="table table-striped">
				<tbody>
					<tr>
						<th>번호</th>
						<th>분류(활성화)</th>
						<th>상단고정</th>
						<th>제목</th>
						<th>작성자</th>
						<th>작성시간</th>
						<th>활성화</th>
					</tr>
					<c:forEach var="board" items="${boardList}">
						<tr>
							<td>${board.postId}</td>
							<td>${board.boardTitle}(${board.boardStatus == 'Y' ? '활성화' : '비활성화'})</td>
							<td>
							    <label class="switch">
							        <input type="checkbox" class="toggle-fixed-checkbox" 
							               data-id="${board.postId}" 
							               ${board.fixed == 'Y' ? 'checked' : ''}>
							        <span class="slider round"></span>
							    </label>
							</td>
							<td>
								<a href="/post/detail?postId=${board.postId}&boardId=${board.boardId}">
									${board.title}
								</a>
							</td>
							<td>${board.userName}</td>
							<td>${fn:substring(board.createDate, 0, 16)}</td>
							<td>
							    <label class="switch">
							        <input type="checkbox" class="toggle-post-status-checkbox" 
							               data-id="${board.postId}" 
							               ${board.postStatus == 'Y' ? 'checked' : ''}>
							        <span class="slider round"></span>
							    </label>
							</td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
           <!-- <a href="" id="insertBoardModal" class="btn btn-outline-primary waves-effect waves-light">게시판 등록</a>  -->
           
           	<!-- 검색 -->
	  		<div class="row mt-3">
			    <div class="col-12">
		           	<form action="/admin/adminBoard" method="get" id="searchForm" class="searchForm d-flex justify-content-center">
		           		<div id="search-main" class="search-main">
		           			<select id="searchType" name="searchType">
		           				<option value="분류">분류</option>
		           				<option value="제목">제목</option>
		           				<option value="작성자">작성자</option>
		           			</select>
		           			<input type="text" id="searchWord" class="form-control" style="max-width: 360px;" name="searchWord" placeholder="검색어를 입력하세요">
		           			<button type="submit" class="btn btn-primary ms-2">검색</button>
		           		</div>
		           	</form>
		         </div>
		    </div>   
           
			<nav class="mt-3">
			   <ul class="pagination pagination-sm justify-content-center mb-0 pagination-rounded gap-1">
			
			    <!-- 이전 블럭 -->
			    <c:url var="prevUrl" value="">
			        <c:param name="currentPage" value="${pageDto.startPage - 1}"/>
			        <c:param name="searchType" value="${param.searchType}"/>
			        <c:param name="searchWord" value="${param.searchWord}"/>
			    </c:url>
			    <c:if test="${pageDto.hasPrev}">
			        <a class="page-link" href="${prevUrl}" aria-label="이전">&lt;</a>
			    </c:if>
			
			    <!-- 현재 블럭 페이지 번호 -->
			    <c:forEach begin="${pageDto.startPage}" end="${pageDto.endPage}" var="i">
			        <c:url var="pageUrl" value="">
			            <c:param name="currentPage" value="${i}"/>
			            <c:param name="searchType" value="${param.searchType}"/>
			            <c:param name="searchWord" value="${param.searchWord}"/>
			        </c:url>
			        <c:choose>
			            <c:when test="${i == pageDto.currentPage}">
			                <!-- 현재 페이지는 링크 X, 강조 표시 -->
			                <span class="page-link" style="font-weight:bold; text-decoration:underline;" aria-current="page">${i}</span>
			            </c:when>
			            <c:otherwise>
			                <a class="page-link" href="${pageUrl}">${i}</a>
			            </c:otherwise>
			        </c:choose>
			    </c:forEach>
			
			    <!-- 다음 블럭 -->
			    <c:url var="nextUrl" value="">
			        <c:param name="currentPage" value="${pageDto.endPage + 1}"/>
			        <c:param name="searchType" value="${param.searchType}"/>
			        <c:param name="searchWord" value="${param.searchWord}"/>
			    </c:url>
			    <c:if test="${pageDto.hasNext}">
			        <a class="page-link" href="${nextUrl}" aria-label="다음">&gt;</a>
			    </c:if>
			
				</ul>
			</nav>
           
           
          </div>
	</div>
</div>

<!-- 게시판 관리 모달 -->
<div id="boardManageModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; 
    background:rgba(0,0,0,0.5); justify-content:center; align-items:center;">
    <div style="background:white; padding:20px; width:500px; border-radius:8px; position:relative;">
        <h3>게시판 관리</h3>

        <!-- 탭 버튼 -->
        <div style="margin-bottom:15px; text-align:center;">
            <button type="button" id="showRegister" style="margin-right:10px;">게시판 등록</button>
            <button type="button" id="showModifyName" style="margin-right:10px;">게시판 이름 수정</button>
            <button type="button" id="showModifyStatus">게시판 상태 수정</button>
        </div>

        <!-- 등록 폼 -->
        <form id="postForm" enctype="multipart/form-data" style="display:block;">
            <div style="margin-bottom:10px;">
                <label>게시판명</label><br>
                <input type="text" name="boardTitle" style="width:100%;" required>
            </div>
            <div style="text-align:right;">
                <button type="button" class="closeModal">닫기</button>
                <button type="submit">등록</button>
            </div>
        </form>

        <!-- 이름 수정 폼 -->
        <form id="modifyFormName" enctype="multipart/form-data" style="display:none;">
            <div style="margin-bottom:10px;">
                <label>게시판 선택</label><br>
                <select class="boardSelectName">
                    <option value="">-- 게시판 --</option>
                </select>
                <input type="hidden" name="boardId" class="hiddenBoardId" value="">
            </div>
            <div style="margin-bottom:10px;">
                <label>게시판명</label><br>
                <input type="text" name="boardTitle" style="width:100%;" required>
            </div>
            <div style="text-align:right;">
                <button type="button" class="closeModal">닫기</button>
                <button type="submit">수정</button>
            </div>
        </form>

        <!-- 상태 수정 폼 -->
        <form id="modifyFormStatus" enctype="multipart/form-data" style="display:none;">
            <div style="margin-bottom:10px;">
                <label>게시판 선택</label><br>
                <select class="boardSelectStatus">
                    <option value="">-- 게시판 --</option>
                </select>
                <input type="hidden" name="boardId" class="hiddenBoardId" value="">
            </div>
            <div style="margin-bottom:10px;">
                <label>게시판 상태</label><br>
                <label class="switch">
                    <input type="checkbox" name="boardStatus" class="boardStatusToggle">
                    <span class="slider round"></span>
                </label>
                <span class="statusLabelText">비활성화</span>
            </div>
            <div style="text-align:right;">
                <button type="button" class="closeModal">닫기</button>
                <button type="submit">수정</button>
            </div>
        </form>

    </div>
</div>



<script type="text/javascript">
	
$(document).ready(function() {

    // 모달 열기
    $('#adminBoard').on('click', function() {
        $('#boardManageModal').css('display', 'flex');
    });

    // 모달 닫기
    $('.closeModal').on('click', function() {
        $('#boardManageModal').hide();
        location.reload();
    });

    // 탭 버튼
    $('#showRegister').on('click', function() {
        $('#postForm').show();
        $('#modifyFormName, #modifyFormStatus').hide();
    });

    $('#showModifyName').on('click', function() {
        $('#modifyFormName').show();
        $('#postForm, #modifyFormStatus').hide();
    });

    $('#showModifyStatus').on('click', function() {
        $('#modifyFormStatus').show();
        $('#postForm, #modifyFormName').hide();
    });

    // 게시판 메뉴 Ajax
    $.ajax({
        url: '/board/menu',
        method: 'GET',
        success: function(data) {

            // 이름 수정 select
            var selectName = $('.boardSelectName');
            selectName.empty().append('<option value="">-- 게시판 --</option>');

            // 상태 수정 select
            var selectStatus = $('.boardSelectStatus');
            selectStatus.empty().append('<option value="">-- 게시판 --</option>');

            data.forEach(function(menu) {
                selectName.append(
                    $('<option></option>').val(menu.boardId).text(menu.boardTitle)
                );

                var statusText = menu.boardStatus === 'Y' ? '활성화' : '비활성화';
                selectStatus.append(
                    $('<option></option>')
                        .val(menu.boardId)
                        .text(menu.boardTitle + '(' + statusText + ')')
                        .attr('data-status', menu.boardStatus)
                );
            });


            // 이름 수정 select 변경 시 hidden input 업데이트
            selectName.on('change', function() {
                var selectedId = $(this).val();
                $('#modifyFormName .hiddenBoardId').val(selectedId);
            });

            // 상태 수정 select 변경 시 hidden input 및 토글 반영
            selectStatus.on('change', function() {
                var selectedId = $(this).val();
                $('#modifyFormStatus .hiddenBoardId').val(selectedId);

                var status = $(this).find('option:selected').data('status');
                var checkbox = $('#modifyFormStatus .boardStatusToggle');
                var label = $('#modifyFormStatus .statusLabelText');

                checkbox.prop('checked', status === 'Y' || status === 'ACTIVE'); // DB 값 Y/N 또는 ACTIVE
                label.text(checkbox.is(':checked') ? '활성화' : '비활성화');
            });
        }
    });

    // 토글 클릭 시 라벨 변경 (상태 수정 폼)
    $('#modifyFormStatus .boardStatusToggle').on('change', function() {
        var label = $('#modifyFormStatus .statusLabelText');
        label.text($(this).is(':checked') ? '활성화' : '비활성화');
    });

    // 게시판 등록
    $('#postForm').on('submit', function(e) {
        e.preventDefault();

        var formData = new FormData(this);

        $.ajax({
            url: '/board/newBoard',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(res) {
                alert('게시판 등록 성공');
                $('#boardManageModal').hide();
                location.reload();
            },
            error: function() {
                alert('게시판 등록 실패');
            }
        });
    });

    // 게시판 이름 수정
    $('#modifyFormName').on('submit', function(e) {
        e.preventDefault();

        var formData = new FormData(this);

        $.ajax({
            url: '/board/modifyBoardName',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(res) {
                alert('게시판명 수정 완료');
                $('#boardManageModal').hide();
                location.reload();
            },
            error: function() {
                alert('게시판명 수정 실패');
            }
        });
    });

    // 게시판 상태값 수정
    $('#modifyFormStatus').on('submit', function(e) {
        e.preventDefault();

        var boardId = $('#modifyFormStatus .hiddenBoardId').val();
        var boardStatus = $('#modifyFormStatus .boardStatusToggle').is(':checked') ? 'Y' : 'N';

        if (!boardId) {
            alert('게시판을 선택하세요.');
            return;
        }

        console.log('상태수정 게시판 번호:', boardId);
        console.log('상태수정 게시판 상태값:', boardStatus);

        $.ajax({
            url: '/board/modifyBoardStatus',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({
                boardId: boardId,
                boardStatus: boardStatus
            }),
            success: function(res) {
                alert('게시판 상태 수정 완료');
                $('#boardManageModal').hide();
                location.reload();
            },
            error: function(err) {
                console.error(err);
                alert('게시판 상태 수정 실패');
            }
        });
    });

    // 상단고정 토글
    $(document).on('change', '.toggle-fixed-checkbox', function() {
        var checkbox = $(this);
        var id = checkbox.data('id');
        var newStatus = checkbox.is(':checked') ? 'Y' : 'N';
        $.ajax({
            url: '/board/toggleFixed',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ postId: id, topFixed: newStatus }),
            success: function(res) {
                console.log('상단고정 상태 변경 완료:', newStatus);
            }
        });
    });

    // 노출활성화 토글
    $(document).on('change', '.toggle-post-status-checkbox', function() {
        var checkbox = $(this);
        var id = checkbox.data('id');
        var newStatus = checkbox.is(':checked') ? 'Y' : 'N';
        $.ajax({
            url: '/board/togglePostStatus',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ postId: id, postStatus: newStatus }),
            success: function(res) {
                console.log('게시글 노출 상태 변경 완료:', newStatus);
            }
        });
    });

});


</script>
<div><jsp:include page ="../nav/footer.jsp"></jsp:include></div>
<div><jsp:include page ="../nav/javascript.jsp"></jsp:include></div>
</body>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>
</html>