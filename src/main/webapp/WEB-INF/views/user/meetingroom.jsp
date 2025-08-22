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
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>
<div class="main-content">
	<div class="page-content">
                    <div class="container-fluid">

            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">회의실 예약</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item">시설</li>
                                <li class="breadcrumb-item active">회의실</li>
                            </ol>
                        </div>
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
												    
												    
												    
												    
												    <div class="d-flex gap-3">
												        <!-- 회의실 리스트 출력 -->
												       	<select>
												       		<option>-- 회의실 선택 --</option>
												       	</select>
												    </div>											
												
												    <button class="btn btn-outline-primary" id="">
												         예약내역
												    </button>
												    <button class="btn btn-outline-primary" id="management">
												         회의실 관리
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
                                            
                                            
                                        </div> <!-- end modal-content-->
                                    </div> <!-- end modal dialog-->
                                </div>
                                <!-- end modal-->

                            </div>
                        </div>
                        
                    </div> <!-- container-fluid -->
                </div>
               </div>
               
               
               <!-- 임시 위치 모달 -->
               
		<div id="management-modal" class="modal">
			<div class="modal-content"></div>
			<span class="close">&times;</span>
			<h3>회의실 관리</h3>
			
			<!-- 모드 선택 -->
			<select name="adminType" id="adminType">
				<option value="등록">등록</option>
				<option value="수정">수정</option>
				<option value="이슈관리">이슈관리</option>
			</select>
			
			<form id="addForm" class="form-section">
				<label>회의실명</label>
				<input type="text" name="roomName" placeholder="회의실명을 입력해주세요">
				<label>위치</label>
				<input type="text" name="roomLocation" placeholder="ex) 본관2층">
				<label>수용 인원</label>
				<input type="number" name="roomCapacity" placeholder="수용가능한 인원 수">
				<button class="close" type="button">닫기</button>
				<button type="submit">등록</button>
			</form>
			
			<form id="modifyForm" class="form-section" style="display:none;">
				<select id="modifyRoomSelect">
				    <option value="">-- 회의실 선택 --</option>
				</select>
				<label>위치</label>
				<input type="text" name="roomLocation" placeholder="변경사항을 입력하세요">
				<label>수용 인원</label>
				<input type="number" name="roomCapacity" placeholder="변경사항을 입력하세요">
				<button class="close" type="button">닫기</button>
				<button type="submit">등록</button>
			</form>
			
			<!-- 이슈등록 폼 -->
			<form id="issueForm" class="form-section" style="display:none;">
				<select id="modifyRoomSelect">
				    <option value="">-- 회의실 선택 --</option>
				</select>
				<input type="hidden" name="roomId" value="">
				<label>기간</label>
				<input type="text" id="issueDate" placeholder="날짜 선택">
				<!-- ajax 전송용 -->
				<input type="hidden" name="roomUseReasonStartDate" id="startDate">
   				<input type="hidden" name="roomUseReasonEndDate" id="endDate">
   				
				<div class="toggle-container">
				    <span>비활성화</span>
				    <label class="switch">
				        <input type="checkbox" id="toggleSwitch" name="toggle">
				        <span class="slider round"></span>
				    </label>
				    <span>활성화</span>
				</div>

				<div class="roomReason">사유</div>
				<input type="text" id="toggleReason" name="roomUseReasonContent" placeholder="ex: 공사, 수리(완료),">
				<button class="close" type="button">닫기</button>
				<button type="submit">변경</button>
			</form>
			
		</div>
<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
</body>
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

<script src="${pageContext.request.contextPath}/resources/js/reservation/meetingroom.js"></script>
</html>