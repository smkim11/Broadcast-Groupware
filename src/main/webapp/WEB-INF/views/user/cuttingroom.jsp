<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
<meta charset="UTF-8">

<!-- flatpickr CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

<!-- flatpickr JS -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

<!-- 한글 로케일 -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

<style>
/* 템플릿에서 제공하는 에러메세지만 사용  */
.was-validated .form-control:valid,
.form-control.is-valid {
  border-color: #dee2e6 !important;
  background-image: none !important;
  box-shadow: none !important;
}

/* 기존 CSS 유지, 모달만 수정됨 */

/* 모달 전체 배경 */
.modal {
	display: none; 
	position: fixed;
	z-index: 1000;
	left: 0;
	top: 0;
	width: 100%;
	height: 100%;
	background-color: rgba(0, 0, 0, 0.6);
	justify-content: center;
	align-items: center;
}

.modal-content,
#detail-modal,
.reservation-modal,
#management-modal .modal-content,
#myReservation-modal .modal-content {
	background: white;
	padding: 25px;
	border-radius: 12px;
	width: 90%;
	max-width: 600px;   /* 모달 가로 최대값 */
	text-align: center;
	box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4);
	position: relative;
	box-sizing: border-box;
	display: flex;
	flex-direction: column;
}

/* 모달 제목 */
.modal-content h3,
#detail-modal h3,
.reservation-modal h3,
#management-modal .modal-content h3,
#myReservation-modal .modal-content h3 {
	margin-bottom: 15px;
	color: blue;
}

/* 테이블 스타일 - th/td 구분 선 강화 */
.meetingroomDatail, 
.myReservation {
	width: 100%;
	border-collapse: collapse;
	margin-bottom: 15px;
}

.meetingroomDatail th, 
.meetingroomDatail td,
.myReservation th,
.myReservation td {
	border: 1px solid #bbb;
	padding: 8px 10px;
	text-align: center;
}

.meetingroomDatail th,
.myReservation th {
	background-color: #f8f8f8;
	font-weight: bold;
}

.modal .btn-group {
	display: flex;
	justify-content: flex-end; /* 오른쪽 정렬 */
	gap: 10px;                 /* 버튼 간격 */
}

/* 공통 버튼 */
.modal .btn-group button {
	padding: 10px 0;           /* 상하 패딩 통일 */
	font-size: 14px;
	border-radius: 4px;
	border: none;
	cursor: pointer;
	color: white;
	box-sizing: border-box;
	width: 100px;              /* 버튼 너비 고정 */
	text-align: center;
}

/* 닫기 버튼 */
.modal .btn-group .close {
	background-color: #28a745;
}

/* 예약 버튼 */
.modal .btn-group .reservationBtn {
	background-color: #28a745;
}

/* 취소 버튼 */
.modal .btn-group button.cancel {
	background-color: #e74c3c; 
	color: white;
	box-shadow: none;
}



/* 폼 섹션 */
.form-section {
	display: flex;
	flex-direction: column;
	gap: 12px;
	margin-top: 15px;
}

.form-section label {
	font-size: 14px;
	font-weight: 500;
	color: #444;
}

.form-section input,
.form-section select,
textarea {
	padding: 10px;
	font-size: 14px;
	border: 1px solid #ccc;
	border-radius: 6px;
	width: 100%;
	box-sizing: border-box;
	transition: border-color 0.2s;
}

.form-section input:focus,
.form-section select:focus,
textarea:focus {
	border-color: #007bff;
	outline: none;
}

/* 토글 스위치 */
.switch {
	position: relative;
	display: inline-block;
	width: 50px;
	height: 24px;
	margin: 0 8px;
}

.switch input {
	opacity: 0;
	width: 0;
	height: 0;
}

.slider {
	position: absolute;
	cursor: pointer;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: #ccc;
	transition: 0.3s;
	border-radius: 24px;
}

.slider:before {
	content: "";
	position: absolute;
	height: 18px;
	width: 18px;
	left: 3px;
	bottom: 3px;
	background: #fff;
	border-radius: 50%;
	transition: 0.3s;
}

input:checked + .slider {
	background-color: #007bff;
}

input:checked + .slider:before {
	transform: translateX(26px);
}

/* 애니메이션 */
@keyframes fadeIn {
	from { opacity: 0; transform: scale(0.9); }
	to { opacity: 1; transform: scale(1); }
}

/* 예약 모달 시간 슬롯 */
.time-slots {
	display: flex;
	flex-wrap: wrap;
	gap: 10px;
	margin-bottom: 15px;
}

.time-slots label {
	background: #f0f0f0;
	padding: 5px 10px;
	border-radius: 4px;
	cursor: pointer;
}

.time-slots input[type="checkbox"] {
	display: none;
}

.time-slots input[type="checkbox"]:checked + span {
	background: #007bff;
	color: #fff;
}

/* FullCalendar 관련 스타일 */
.fc-event {
	color: #fff !important;
	cursor: default !important;
}
.fc-event:hover {
	opacity: 1 !important;
	color: #fff !important;
}

/* 월뷰 각 날짜 셀 높이 고정 */
.fc-daygrid-day {
	height: 120px;
	min-height: 120px;
	max-height: 120px;
	position: relative;
	overflow: hidden;
}

/* 셀 안 이벤트 영역 */
.fc-daygrid-day-events {
	max-height: 70px;
	overflow-y: auto;
}

/* 이벤트 간격 조정 */
.fc-daygrid-event {
	margin-bottom: 2px;
}

/* select 기본 스타일 */
#roomList {
	padding: 6px 12px;
	border-radius: 4px;
	background-color: #f8f9fa;
	cursor: pointer;
	transition: 0.3s;
}

/* 예약/관리 버튼 공통 스타일 */
#myReservationBtn,
#management {
	padding: 6px 12px;
	border: 1px solid #1e7e34;
	background-color: blue;
	color: white;
	border-radius: 4px;
	cursor: pointer;
	transition: 0.3s;
	font-size: 14px;       
	line-height: 1.4; 
	height: 36px;      
	box-sizing: border-box; 
}

.d-flex {
	display: flex;
	align-items: center;
}

.gap-3 {
	gap: 1rem;
}


</style>
<title>편집실</title>
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
                        <h4 class="mb-0">편집실 예약</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item">시설</li>
                                <li class="breadcrumb-item active">편집실</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            
            <div id="loginUser" data-user-id="${loginUser.userId}"></div>
            
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
												        <!-- 편집실 리스트 출력 -->
												       	<select id="roomList">
												       		<option>-- 편집실 선택 --</option>
												       	</select>
												    </div>											
													<div class="button-group">
													    <button class="myReservationBtn" id="myReservationBtn">
													         예약내역
													    </button>
													    <c:if test="${loginUser.role eq 'admin'}">
															<button class="btn btn-outline-primary" id="management">
																편집실 관리
															</button>
														</c:if>
													</div>
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
                        
                        
    <!-- 관리자 모달 -->
	<div id="management-modal" class="modal">
		<div class="modal-content">
			<span class="close" style="text-align: right; background-color: white;">&times;</span>
			<h3>편집실 관리</h3>
	
			<!-- 모드 선택 -->
			<select name="adminType" id="adminType">
				<option value="등록">등록</option>
				<option value="이슈관리">이슈관리</option>
			</select>
	
			<form id="addForm" class="form-section">
				<label>편집실명</label>
				<input type="text" name="roomName" placeholder="편집실명을 입력해주세요">
				<label>위치</label>
				<input type="text" name="roomLocation" placeholder="ex) 본관2층">
				<label>수용 인원</label>
				<input type="number" name="roomCapacity" placeholder="수용가능한 인원 수">
				<div class="btn-group">
					<button class="close" type="button">닫기</button>
					<button class="reservationBtn" type="submit">등록</button>
				</div>
			</form>
	
			<!-- 이슈등록 폼 -->
			<form id="issueForm" class="form-section" style="display:none;">
				<input type="hidden" name="roomStatus" value="">
			
				<select id="modifyIssueSelect">
					<option value="">-- 편집실 선택 --</option>
				</select>
				<input type="hidden" name="roomId" value="">
				<label>기간</label>
				<input type="text" id="rentalPeriod" placeholder="시작일 ~ 정료일" readonly>
			
			    <select id="startTime"></select>
			    <select id="endTime"></select>
	
				<div class="toggle-container">
					<span>비활성화</span>
					<label class="switch">
						<input type="checkbox" id="toggleSwitch">
						<span class="slider round"></span>
					</label>
					<span>활성화</span>
				</div>
	
				<div class="roomReason">사유</div>
				<input type="text" id="toggleReason" name="roomUseReasonContent" placeholder="ex: 공사, 수리(완료),">
				
				<input type="hidden" name="roomUseReasonStartDate" value="">
				<input type="hidden" name="roomUseReasonEndDate" value="">
				<div class="btn-group">
					<button class="close" type="button">닫기</button>
					<button type="submit" class="reservationBtn">변경</button>
				</div>
			</form>
		</div>
	</div>
	
	
	<!-- 상세보기 모달 -->
	<div id="detailReservation-modal" class="modal">
		<div id="detail-modal">
		<span class="close" style="text-align: right; background-color: white;">&times;</span>
			<h3>상세정보</h3>
			
			<table id="meetingroomReservationDetail" class="meetingroomDatail">
				<thead>
					<tr>
						<th>사용일</th>
						<th>사용 시간</th>
						<th>작품명</th>
						<th>예약자</th>
					</tr>
				</thead>	
				
				<tbody id="detailList">
					
				</tbody>
			</table>
				<div class="btn-group">
					<c:if test="${loginUser.role eq 'admin'}">
						<button type="submit" class="cancel" style="background-color: red;">취소</button>
					</c:if>
					<button class="close" type="button" style="">닫기</button>
				</div>
		</div>
	</div>
	
	<!-- 본인 예약내역 모달 -->
	<div id="myReservation-modal" class="modal">
		<div class="modal-content">
		<span class="close" style="text-align: right; background-color: white;">&times;</span>
			<h3>예약 내역</h3>
			
			<table id="myReservationDetail" class="myReservation">
				<thead>
					<tr>
						<th>편집실</th>
						<th>위치</th>
						<th>사용일</th>
						<th>사용 시간</th>
						<th>작품명</th>
						<th>취소</th>
					</tr>
				</thead>	
				
				<tbody id="myReservationList">
					
				</tbody>
			</table>
				<div class="btn-group">
					<button class="close" type="button">닫기</button>
				</div>
		</div>
	</div>
	
	<!-- 날짜 클릭시 모달 => 예약 -->
	<div id="reservationMeetingroom-modal" class="modal">
		<div class="reservation-modal">
			<span class="close" style="text-align: right; background-color: white;">&times;</span>
			<h3>편집실 예약</h3>
			<form id="reservationMeetingroom">
			<input type="hidden" id="reservationRoomId" name="roomId">
		    <input type="hidden" id="reservationReasonHidden" name="roomReservationReason">
		    <input type="hidden" id="reservationStartTime" name="roomReservationStartTime">
		    <input type="hidden" id="reservationEndTime" name="roomReservationEndTime">
		    
			<p id="chooseDate" class="chooseDate">선택한 날짜:</p>
			<div>
				<textarea rows="2" cols="20" id="roomReservationReason" placeholder="작품명을 입력하세요."></textarea>
			</div>
				<div id="timeSlots" class="time-slots">
					
				</div>
				
				<div class="btn-group">
					<button class="close" type="button">닫기</button>
					<button type="submit" class="reservationBtn">예약</button>
				</div>
			</form>
		</div>
	</div>

                        
                    </div> <!-- container-fluid -->
                </div>
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

<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/pages/form-validation.init.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/reservation/cuttingroom.js"></script>
</html>