<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
<meta charset="UTF-8">
<style>
/* 템플릿에서 제공하는 에러메세지만 사용  */
.was-validated .form-control:valid,
.form-control.is-valid {
  border-color: #dee2e6 !important;
  background-image: none !important;
  box-shadow: none !important;
}
</style>
<title>방송국</title>
</head>
<body>

<div>
    <jsp:include page ="../views/nav/header.jsp"></jsp:include>
</div>
<div class="main-content">
	<div class="page-content">
                    <div class="container-fluid">

                        <!-- 페이지 제목 -->
                        <div class="row">
                            <div class="col-12">
                                <div class="page-title-box d-flex align-items-center justify-content-between">
                                    <h4 class="mb-0">캘린더</h4>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                               
                                <div class="row">
                                    <div class="col-lg-3" style="display:none;">
									    <div id="external-events"></div>
									</div>
                                    <div class="col-lg-12">
                                        <div class="card">
                                            <div class="card-body">
                                            	<div class="d-flex justify-content-between align-items-start mb-2">
												    <!-- 타입 체크박스 -->
												    <div class="d-flex gap-3">
												        <div class="form-check">
												            <input class="form-check-input" type="checkbox" id="personal">
												            <label class="form-check-label text-info" for="personal">개인</label>
												        </div>
												        <div class="form-check">
												            <input class="form-check-input" type="checkbox" id="team">
												            <label class="form-check-label text-success" for="team">팀</label>
												        </div>
												        <div class="form-check">
												            <input class="form-check-input" type="checkbox" id="total">
												            <label class="form-check-label text-warning" for="total">전체</label>
												        </div>
												    </div>
												
												    <button class="btn btn-outline-primary" id="btn-new-event">
												        <i class="mdi mdi-plus-circle-outline"></i> 일정등록
												    </button>
												</div>

                                                <div id="calendar"></div>
                                            </div>
                                        </div>
                                    </div> 

                                </div> 

                                <div style='clear:both'></div>


                                <!-- 모달창 -->
                                <div class="modal fade" id="event-modal" tabindex="-1">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content">
                                            <div class="modal-header py-3 px-4 border-bottom-0">
                                                <h5 class="modal-title" id="modal-title">캘린더</h5>

                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>

                                            </div>
                                            <div class="modal-body p-4">
                                                <form class="needs-validation" name="event-form" id="form-event" novalidate>
                                                    <input type="hidden" name="calendarId" id="eventid">
                                                    <input type="hidden" name="userId" id="event-user-id">
                                                    <input type="hidden" name="loginUser" id="event-login-user" value="${loginUser}">
                                                    <div class="row">
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">제목</label>
                                                                <input class="form-control" placeholder="제목을 입력하세요."
                                                                    type="text" name="calendarTitle" id="event-title" required/>
                                                                <div class="invalid-feedback">제목을 입력하세요.</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">장소</label>
                                                                <input class="form-control" placeholder="장소를 입력하세요."
                                                                    type="text" name="calendarLocation" id="event-location" required/>
                                                                <div class="invalid-feedback">장소를 입력하세요.</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">시작일</label>
                                                                <input class="form-control" type="datetime-local" name="calendarStartTime" id="event-start-time" required/>
                                                                <div class="invalid-feedback">시작일을 입력하세요.</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">종료일</label>
                                                                <input class="form-control" type="datetime-local" name="calendarEndTime" id="event-end-time" required/>
                                                                <div class="invalid-feedback">종료일을 입력하세요.</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">공개범위</label>
                                                                <!-- 상세보기시 select가 아닌 input으로 보이며 수정불가 -->
                                                                <input class="form-control" type="hidden" id="event-type-read"/>
                                                                <select class="form-control form-select" name="calendarType" id="event-type">
                                                                	<!-- 관리자일때만 공개범위 전체로 설정가능 -->
	                                                                <c:choose>
	                                                                	<c:when test="${role eq 'admin' }">
		                                                                	<option>개인</option>
		                                                                    <option>팀</option>
		                                                                    <option>전체</option>
	                                                                	</c:when>
	                                                                	<c:otherwise>
	                                                                		<option>개인</option>
		                                                                    <option>팀</option>
	                                                                	</c:otherwise>
	                                                                </c:choose>
                                                                </select>
                                                                <div class="invalid-feedback">공개범위를 선택하세요.</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                            	<label class="form-label">메모</label>
                                                            	<textarea class="form-control" rows="5" cols="50" name="calendarMemo" id="event-memo"></textarea>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row mt-2">
                                                        <div class="col-6">
                                                            <button type="button" class="btn btn-outline-danger waves-effect waves-light" id="btn-delete-event">삭제</button>
                                                        </div>
                                                        <div class="col-6 text-end">
                                                            <button type="button" class="btn btn-outline-secondary waves-effect" data-bs-dismiss="modal">닫기</button>
                                                            <button type="submit" class="btn btn-outline-success waves-effect waves-light" id="edit-event-btn">수정</button>
                                                            <button type="submit" class="btn btn-outline-success waves-effect waves-light" id="btn-save-event">등록</button>
                                                        </div>
                                                    </div>
                                                </form>
                                            </div>
                                        </div> <!-- end modal-content-->
                                    </div> <!-- end modal dialog-->
                                </div>
                                <!-- end modal-->

                            </div>
                        </div>
                        
                    </div> <!-- container-fluid -->
                </div>
                </div>
<div>
    <jsp:include page ="../views/nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>
</body>
<script>
	// 공휴일 조회
	window.calendarEvents = [
	    <c:forEach var="event" items="${events}" varStatus="loop">
	        {
	            id: "${event.calendarId}",
	            userId: "${event.userId}",
	            title: "${fn:escapeXml(event.calendarTitle)}",
	            location: "${event.calendarLocation}",
	            start: "${event.calendarStartTime}",
	            end: "${event.calendarEndTime}",
	            type: "${event.calendarType}",
	            className: "bg-danger",
	            memo: "${event.calendarMemo}"
	        }<c:if test="${!loop.last}">,</c:if>
	    </c:forEach>
	];
</script>
<!-- plugin js -->
<script src="${pageContext.request.contextPath}/resources/libs/moment/min/moment.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/jquery-ui-dist/jquery-ui.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/fullcalendar/index.global.min.js"></script>

<!-- Calendar init -->
<script src="${pageContext.request.contextPath}/resources/js/pages/calendar.init.js"></script>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/pages/form-validation.init.js"></script>
</html>