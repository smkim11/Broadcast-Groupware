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

/* 모달 배경 */
.modal {
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background: rgba(0, 0, 0, 0.5);
	display: none; /* JS에서 열고 닫기 */
	justify-content: center;
	align-items: center;
	z-index: 1000;
}

/* 모달 박스 */
.modal-content {
	background: #fff;
	width: 200px;
	max-width: 90%;
	padding: 30px 25px;
	border-radius: 12px;
	box-shadow: 0 6px 20px rgba(0, 0, 0, 0.25);
	position: relative;
	box-sizing: border-box;
	animation: fadeIn 0.3s ease;
}

/* 닫기(X) 버튼 */
.modal-content .close {
	position: absolute;
	top: 12px;
	right: 15px;
	font-size: 22px;
	font-weight: bold;
	color: #777;
	cursor: pointer;
	background: none;
	border: none;
}

/* 제목 */
.modal-content h3 {
	margin: 0 0 20px;
	font-size: 20px;
	font-weight: 600;
	text-align: center;
	color: #333;
}

/* 폼 영역 */
.form-section {
	display: flex;
	flex-direction: column;
	gap: 12px;
	margin-top: 15px;
}

/* label */
.form-section label {
	font-size: 14px;
	font-weight: 500;
	color: #444;
}

/* input, select */
.form-section input,
.form-section select {
	padding: 10px;
	font-size: 14px;
	border: 1px solid #ccc;
	border-radius: 6px;
	width: 100%;
	box-sizing: border-box;
	transition: border-color 0.2s;
}

.form-section input:focus,
.form-section select:focus {
	border-color: #007bff;
	outline: none;
}

/.btn-group {
	display: flex;
	justify-content: flex-end; /* 오른쪽 정렬 */
	gap: 10px;                 /* 버튼 간격 */
	margin-top: 15px;
}

.btn-group button {
	min-width: 80px;
	padding: 8px 14px;
	border-radius: 6px;
	cursor: pointer;
	border: none;
	font-size: 14px;
}

.btn-group button.close {
	background: #f1f1f1;
	color: #333;
}

.btn-group button[type="submit"] {
	background: #007bff;
	color: #fff;
}


.btn-group button.close:hover {
	background: #999;
}

.btn-group button[type="submit"] {
	background: #007bff;
	color: #fff;
}

.btn-group button[type="submit"]:hover {
	background: #0056b3;
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
	to   { opacity: 1; transform: scale(1); }
}

/*예약 모달 css*/
.modal {
	display: none;
	position: fixed;
	top: 0; left: 0;
	width: 100%; height: 100%;
	background: rgba(0,0,0,0.5);
	justify-content: center; align-items: center;
	z-index: 1000;
}

.reservation-modal {
	background: #fff;
	padding: 20px;
	border-radius: 8px;
	width: 400px;
	max-width: 90%;
}

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
.btn-group {
	display: flex;
	justify-content: flex-end;
	gap: 10px;
}

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
    height: 120px;      /* 원하는 높이로 조정 */
    min-height: 120px;  /* 최소 높이 고정 */
    max-height: 120px;  /* 최대 높이 고정 */
    position: relative; /* 이벤트 위치 조정 용도 */
    overflow: hidden;   /* 셀 내부 이벤트 넘침 처리 */
}

/* 셀 안 이벤트 영역 */
.fc-daygrid-day-events {
    max-height: 100%;   /* 셀 높이에 맞춤 */
    overflow-y: auto;   /* 스크롤 가능 */
}

/* 이벤트 간격 조정 */
.fc-daygrid-event {
    margin-bottom: 2px;
}



/* 날짜 셀 이벤트 영역 */
.fc-daygrid-day-events {
    max-height: 70px;   /* 2건 정도만 보이도록 높이 제한 */
    overflow-y: auto;   /* 스크롤 가능 */
}

/* 이벤트 간격 조정 */
.fc-daygrid-event {
    margin-bottom: 2px;
}


</style>
<title>회의실</title>
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
												        <!-- 회의실 리스트 출력 -->
												       	<select id="roomList">
												       		<option>-- 회의실 선택 --</option>
												       	</select>
												    </div>											
												
												    <button class="btn btn-outline-primary" id="">
												         예약내역
												    </button>
												    <c:if test="${loginUser.role eq 'admin'}">
														<button class="btn btn-outline-primary" id="management">
															회의실 관리
														</button>
													</c:if>

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
			<span class="close">&times;</span>
			<h3>회의실 관리</h3>
	
			<!-- 모드 선택 -->
			<select name="adminType" id="adminType">
				<option value="등록">등록</option>
				<option value="이슈관리">이슈관리</option>
			</select>
	
			<form id="addForm" class="form-section">
				<label>회의실명</label>
				<input type="text" name="roomName" placeholder="회의실명을 입력해주세요">
				<label>위치</label>
				<input type="text" name="roomLocation" placeholder="ex) 본관2층">
				<label>수용 인원</label>
				<input type="number" name="roomCapacity" placeholder="수용가능한 인원 수">
				<div class="btn-group">
					<button class="close" type="button">닫기</button>
					<button type="submit">등록</button>
				</div>
			</form>
	
			<!-- 이슈등록 폼 -->
			<form id="issueForm" class="form-section" style="display:none;">
				<input type="hidden" name="roomStatus" value="">
			
				<select id="modifyIssueSelect">
					<option value="">-- 회의실 선택 --</option>
				</select>
				<input type="hidden" name="roomId" value="">
				<label>기간</label>
				<input type="text" id="rentalPeriod" placeholder="시작일 ~ 정료일" readonly>
			
			    <select id="startTime"></select>
			    <select id="endTime"></select>
	
				<div class="toggle-container">
					<span>비활성화</span>
					<label class="switch">
						<input type="checkbox" id="toggleSwitch" name="roomStatus">
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
					<button type="submit">변경</button>
				</div>
			</form>
		</div>
	</div>
	
	
	<!-- 상세보기 모달 -->
	<div id="detailReservation-modal" class="modal">
		<div id="detail-modal">
		<span class="close">&times;</span>
			<h3>상세정보</h3>
			
			<table id="meetingroomReservationDetail" class="meetingroomDatail">
				<thead>
					<tr>
						<th>사용일</th>
						<th>사용 시간</th>
						<th>회의 주제</th>
						<th>예약자</th>
						<th>예약 취소</th>
					</tr>
				</thead>	
				
				<tbody id="detailList">
					
				</tbody>
			</table>
		</div>
	</div>
	
	<!-- 날짜 클릭시 모달 => 예약 -->
	<div id="reservationMeetingroom-modal" class="modal">
		<div class="reservation-modal">
			<span class="close">&times;</span>
			<h3>회의실 예약</h3>
			<form id="reservationMeetingroom">
			<input type="hidden" id="reservationRoomId" name="roomId">
		    <input type="hidden" id="reservationReasonHidden" name="roomReservationReason">
		    <input type="hidden" id="reservationStartTime" name="roomReservationStartTime">
		    <input type="hidden" id="reservationEndTime" name="roomReservationEndTime">
		    
			<p id="chooseDate" class="chooseDate">선택한 날짜:</p>
			<div>
				회의 주제 : <textarea rows="2" cols="20" id="roomReservationReason" placeholder="회의 주제를 입력하세요."></textarea>
			</div>
				<div id="timeSlots" class="time-slots">
					
				</div>
				
				<div class="btn-group">
					<button class="close" type="button">닫기</button>
					<button type="submit">예약</button>
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

<script src="${pageContext.request.contextPath}/resources/js/reservation/meetingroom.js"></script>
</html>