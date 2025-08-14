<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta charset="UTF-8">
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
									    <button id="btn-new-event"></button>
									</div>
                                    <div class="col-lg-12">
                                        <div class="card">
                                            <div class="card-body">
                                            <div class="form-check">
					                             <input class="form-check-input" type="checkbox" id="formCheck1">
					                             <label class="form-check-label" for="formCheck1">
					                                 개인
					                             </label>
                         					</div>
                                                <div id="calendar"></div>
                                            </div>
                                        </div>
                                    </div> <!-- end col -->

                                </div> 

                                <div style='clear:both'></div>


                                <!-- Add New Event MODAL -->
                                <div class="modal fade" id="event-modal" tabindex="-1">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content">
                                            <div class="modal-header py-3 px-4 border-bottom-0">
                                                <h5 class="modal-title" id="modal-title">캘린더</h5>

                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-hidden="true"></button>

                                            </div>
                                            <div class="modal-body p-4">
                                                <form class="needs-validation" name="event-form" id="form-event" novalidate>
                                                    <input type="hidden" id="eventid">
                                                    <div class="row">
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">제목</label>
                                                                <input class="form-control" placeholder="일정을 입력하세요."
                                                                    type="text" name="calendarTitle" id="event-title" required value="" />
                                                                <div class="invalid-feedback">Please provide a valid event name</div>
                                                            </div>
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="mb-3">
                                                                <label class="form-label">공개범위</label>
                                                                <select class="form-control form-select" name="category" id="event-category">
                                                                    <option value="bg-primary">개인</option>
                                                                    <option value="bg-success">팀</option>
                                                                    <option value="bg-warning">전체</option>
                                                                </select>
                                                                <div class="invalid-feedback">Please select a valid event category</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="row mt-2">
                                                        <div class="col-6">
                                                            <button type="button" class="btn btn-danger" id="btn-delete-event">삭제</button>
                                                        </div>
                                                        <div class="col-6 text-end">
                                                            <button type="button" class="btn btn-light me-1" data-bs-dismiss="modal">닫기</button>
                                                            <button type="submit" class="btn btn-success" id="edit-event-btn">수정</button>
                                                            <button type="submit" class="btn btn-success" id="btn-save-event">저장</button>
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
</body>
<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>

<script>
window.calendarEvents = [
    <c:forEach var="event" items="${events}" varStatus="loop">
        {
            id: "${event.id}",
            title: "${fn:escapeXml(event.calendarTitle)}",
            start: "${event.calendarStartTime}",
            end: "${event.calendarEndTime}",
            className: "${event.className}"
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
</html>