<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>차량예약</title>

<!-- Flatpickr CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

<!-- Flatpickr JS -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

<!-- range 한국어로 -->
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- jquery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>

.list {
	width: 100%;
	min-height: 100vh;
	padding: 20px;
	box-sizing: border-box;
}

table.table-bordered {
    width: 100%;
    border-collapse: collapse; /* 테두리 겹침 방지 */
}

table.table-bordered th,
table.table-bordered td {
    border: 1px solid #ddd; /* 테두리 색상 */
    padding: 5px 10px;       /* 상하/좌우 패딩 */
    text-align: center;
}

table.table-bordered th {
    background-color: #f1f1f1;
}

table.table-bordered tr:nth-child(even) {
    background-color: #fafafa;
}

/* table.table-bordered 안의 버튼 전용 */
table.table-bordered button {
    padding: 4px 12px;        /* 상하 4px, 좌우 12px */
    min-width: 80px;          /* 최소 가로폭 */
    border: 1px solid blue;   /* 테두리 */
    background-color: blue;    /* 배경색 */
    color: white;              /* 글자색 */
    border-radius: 4px;        /* 모서리 둥글게 */
    cursor: pointer;
    font-size: 13px;           /* 글자 크기 */
    transition: 0.3s;
}

table.table-bordered button:hover {
    background-color: #0056b3;
    border-color: #003d80;
}

table.table-bordered th,
table.table-bordered td {
    border: 1px solid #ddd;    /* 테두리 */
    padding: 4px 10px;          /* 상하 4px, 좌우 6px */
    text-align: center;
    font-size: 13px;
}

/* td 안 div: vehicleNo, vehicleName, vehicleType 공통 스타일 */
table.table-bordered td > div.vehicleNo,
table.table-bordered td > div.vehicleName,
table.table-bordered td > div.vehicleType {
    width: 100%;                /* td 전체 폭 사용 */
    padding: 4px 6px;           /* 상하 4px, 좌우 6px */
    height: 30px;               /* 높이 지정 */
    display: flex;              
    align-items: center;
    justify-content: center;
    border-radius: 4px;         
    background-color: #f0f0f0;  
    font-size: 13px;
    cursor: pointer;
    transition: 0.3s;
    box-sizing: border-box;
}

table.table-bordered td > div.vehicleNo:hover,
table.table-bordered td > div.vehicleName:hover,
table.table-bordered td > div.vehicleType:hover {
    background-color: #d0d7ff;  /* hover 시 색상 변화 */
}


#reservationForm button {
	padding: 5px;
    border: 1px solid blue;
    background-color: blue;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    transition: 0.3s;
}

#reservationForm select,
#reservationForm input[type="text"] {
    padding: 6px 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
}

#reservationBtn {
    width: 200px;       /* 원하는 가로폭으로 설정 */
    padding: 3px 12px;  /* 높이 조절 */
    border: 1px solid blue;
    background-color: blue;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    transition: 0.3s;
}

#reservationForm button:hover {
    background-color: blue;
    border-color: #0056b3;
}

.legend-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.legend span {
    display: inline-block;
    width: 18px;
    height: 18px;
    margin-right: 5px;
    border-radius: 3px;
}

.red-box { background-color: red; } 
.blue-box { background-color: blue; } 
/*.gray-box { background-color: #e8e6e6; } */

.myReservation, .addCar {
    padding: 6px 12px;
    border: 1px solid #28a745;
    background-color: blue;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    transition: 0.3s;
}

.myReservation:hover, .addCar:hover {
    background-color: blue;
    border-color: #1e7e34;
}

.addCar:hover {
    background-color: blue;
    border-color: #1e7e34;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 30px;
}

table th, table td {
    padding: 5px;
    text-align: center;
    border: 1px solid #ddd;
}

table th {
    background-color: #f1f1f1;
}

table tr:nth-child(even) {
    background-color: #fafafa;
}


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

.modal-content {
    background: white;
    padding: 25px;
    border-radius: 12px;
    width: 90%;
    max-width: 400px;
    text-align: center;
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4);
    position: relative;
}

.modal-content h3 {
    margin-bottom: 15px;
    color: blue;
}

.modal-content fieldset {
    border: 2px solid blue;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 15px;
}

.modal-content legend {
    padding: 0 10px;
    font-weight: bold;
    color: blue;
}

.modal-content input[type="text"],
.modal-content select {
    width: calc(100% - 20px);
    margin-bottom: 10px;
    padding: 6px 8px;
    border-radius: 4px;
    border: 1px solid #ccc;
}

.modal-content button, .close1 {
    padding: 6px 12px;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    margin: 5px;
    transition: 0.3s;
    
}

.modal-content button[type="submit"] {
    background-color: green;
    color: white;
}

.modal-content button[type="submit"]:hover {
    background-color: green;
}

.modal-content .close, .modal-content{
    position: absolute;
    top: 10px;
    right: 15px;
    font-size: 24px;
    font-weight: bold;
    cursor: pointer;
    color: #333;
}

.modal-content .close1 {
    top: auto;
    bottom: 10px;
    right: 10px;
    background-color: green;
    font-size: 24px;
    font-weight: bold;
    cursor: pointer;
    color: #333;
     color: white;
}

/* chart-container 스타일 */
.chart-container {
position: relative;
width: 100%;
max-width: 1400px;
height: 80px;
box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
padding: 5px 10px;
box-sizing: border-box;
}

/* canvas 기본 스타일 */
.chart-container canvas {
	width: 100% !important;
	height: 80px !important;
	display: block;
	background-color: transparent; /* 투명 배경 (JS에서 색상 채움) */
	cursor: pointer;				  /* 마우스 포인터 변경 */
}

/* 예약 상태 구분용 (캔버스에 그리거나 div로 겹쳐도 가능) */
.chart-block {
	position: absolute;
	top: 0;
	height: 100%;
	border-radius: 4px;
}

/* 예약 불가 시간 (빨강) */
.chart-block.reserved {
	background-color: rgba(255, 0, 0, 0.7);
}

/* 예약 가능 시간 (회색) */
.chart-block.available {
	background-color: #e5e7eb;
}

/* 내가 선택한 시간 (파랑) */
.chart-block.selected {
	background-color: rgba(37, 99, 235, 0.8);
}


/* 토글 스위치 전체 */
.toggle-container {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    margin-bottom: 10px;
}

/* 스위치 */
.switch {
    position: relative;
    display: inline-block;
    width: 50px;
    height: 24px;
}

/* 숨긴 checkbox */
.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

/* 슬라이더 */
.slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #ccc;
    transition: 0.4s;
    border-radius: 24px;
}

/* 원 버튼 */
.slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 2px;
    bottom: 2px;
    background-color: white;
    transition: 0.4s;
    border-radius: 50%;
}

/* 체크 시 색 변경 및 원 이동 */
.switch input:checked + .slider {
    background-color: green;
}

.switch input:checked + .slider:before {
    transform: translateX(26px);
}
/* 예약확인 모달 전용 CSS */
.myReservation-modal {
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

.myReservation-modal-content {
    background: white;
    padding: 25px;
    border-radius: 12px;
    width: 95%;           /* 기존보다 조금 넓게 */
    max-width: 600px;     /* 가로폭 확대 */
    text-align: center;
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4);
    position: relative;
}

.myReservation-modal-content h3 {
    margin-bottom: 15px;
    color: blue;
}

.myReservation-modal-content table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 15px;
}

.myReservation-modal-content table th,
.myReservation-modal-content table td {
    padding: 8px;
    border: 1px solid #ddd;
    text-align: center;
}

.myReservation-modal-content button, 
.myReservation-modal-content .close1 {
    padding: 6px 12px;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    margin: 5px;
    transition: 0.3s;
}

.myReservation-modal-content .close {
    position: absolute;
    top: 10px;
    right: 15px;
    font-size: 24px;
    font-weight: bold;
    cursor: pointer;
    color: #333;
}

.myReservation-modal-content .close1 {
    top: auto;
    bottom: 10px;
    right: 10px;
    background-color: green;
    font-size: 24px;
    font-weight: bold;
    cursor: pointer;
    color: white;
}

</style>

</head>
<body>

<header>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</header>
<div class="main-content">
	<div class="page-content">
		<div class="container-fluid">
		
	<!-- 페이지 타이틀 영역 (제목 + 경로 표시) -->
            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">차량 예약</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item">예약</li>
                                <li class="breadcrumb-item active">차량</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            
    <div id="loginUser" data-user-id="${loginUser.userId}"></div>
	
	<div class="list">
		<form id="reservationForm" action="/api/car" method="post">
		    <label>차량선택</label>
		    <select>
		        <option value="">--타입--</option>
		        <option value="전체">전체</option>
		        <option value="소형">소형</option>
		        <option value="중형">중형</option>
		        <option value="대형">대형</option>
		    </select>
		
		    <input type="text" id="rentalPeriod" placeholder="대여일 ~ 반납일" readonly>
		
		    <select id="startTime"></select>
		    <select id="endTime"></select>
		
		    <button type="submit" id="search">조회하기</button>
		</form>
		
			<div class="legend-container">
				<div class="legend">
					<span class="red-box"></span> 예약 불가
					<!-- <span class="gray-box"></span> 예약 가능시간 -->
					<span class="blue-box"></span> 선택시간
				</div>

					<div class="button-group">
				        <button id="myReservation" class="myReservation">예약확인</button>
				        <button id="addCar" class="addCar" style="display:none;">차량관리</button>
				    </div>
				
			</div>
		
		
	<table id="carTable" class="table table-bordered">
    <thead>
        <tr>
            <th>차량 정보</th>
            <th>예약 현황</th>
            <th>예약 버튼</th>
        </tr>
    </thead>
    <tbody id="carList">
    
    </tbody>
</table>

</div>

<nav aria-label="Page navigation">
    <ul class="pagination" id="pagination"></ul>
</nav>


	
	<!-- 차량등록 모달 -->
	<div id="carModal" class="modal">
		<div class="modal-content">
			<span class="close">&times;</span>
			<h3>차량 관리</h3>
			
			<!-- 모드 선택 -->
			<select name="adminType" id="adminType">
				<option value="등록">등록</option>
				<option value="수정">수정</option>
				<option value="이슈등록">차량관리</option>
			</select>
			
			<!-- 등록 폼 -->
			<form id="addForm" class="form-section">
				<label>차량번호</label>
				<input type="text" name="vehicleNo" placeholder="000가0000"><br>
				<label>차종</label>
				<input type="text" name="vehicleName" placeholder="ex) 아반떼, 카니발"><br>
				<label>차량타입</label>
				<select name="vehicleType" required>
					<option value="소형">소형</option>
					<option value="중형">중형</option>
					<option value="대형">대형</option>
				</select><br>
				<button class="close1" type="button">닫기</button>
				<button type="submit">등록</button>
			</form>
			
			<!-- 수정 폼 -->
			<form id="modifyCar" class="form-section" style="display:none;">
				<label for="vehicleSelect">차량 선택</label>
				<select id="modifyVehicleSelect">
				    <option value="">-- 차량 선택 --</option>
				</select>
				<input type="hidden" name="vehicleId" value="">
				<label>차량번호</label>
				<input type="text" name="vehicleNo" placeholder="000가0000"><br>
				<label>차종</label>
				<input type="text" name="vehicleName" placeholder="ex) 아반떼, 카니발"><br>
				<label>차량타입</label>
				<select name="vehicleType" required>
					<option value="소형">소형</option>
					<option value="중형">중형</option>
					<option value="대형">대형</option>
				</select><br>
				<button class="close1" type="button">닫기</button>
				<button type="submit">수정</button>
			</form>
			
			<!-- 이슈등록 폼 -->
			<form id="carToggle" class="form-section" style="display:none;">
				<label for="vehicleSelect">차량 선택</label>
				<select id="toggleVehicleSelect">
				    <option value="">-- 차량 선택 --</option>
				</select>
				<input type="hidden" name="vehicleId" value="">
				<label>기간</label>
				<input type="text" id="issueDate" placeholder="날짜 선택">
				<!-- ajax 전송용 -->
				<input type="hidden" name="vehicleUseReasonStartDate" id="startDate">
   				<input type="hidden" name="vehicleUseReasonEndDate" id="endDate">
   				
				<div class="toggle-container">
				    <span>비활성화</span>
				    <label class="switch">
				        <input type="checkbox" id="toggleSwitch" name="toggle">
				        <span class="slider round"></span>
				    </label>
				    <span>활성화</span>
				</div>

				<div class="toggleReason">사유</div>
				<input type="text" id="toggleReason" name="vehicelUseReasonContent" placeholder="ex: 사고, 수리(완료),">
				<button class="close1" type="button">닫기</button>
				<button type="submit">변경</button>
			</form>
			
			
		</div>
     </div>
     
     <!-- 예약확인 모달 -->
     <div id="confirmReservation" class="myReservation-modal">
     	<div class="myReservation-modal-content">
     		<span class="close">&times;</span>
			<h3>예약 확인</h3>
     		
     		<table border="1" id="myReservationList">
     			<tr>
     				<th>차량번호</th>
     				<th>대여 시간</th>
     				<th>반납 시간</th>
     				<th>예약 취소</th>
     			</tr>
     		</table>
     		<div style="text-align: left;">
     			<p>* 2일전까지의 내역입니다.</p>
     			<p>* 예약 취소는 24시간 전까지 가능합니다.</p>
     		</div>
     		<button class="close1" type="button">닫기</button>
     	</div>
     </div>


     
     </div>
   </div>
 </div>


<footer>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</footer>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>

</body>
<script src="${pageContext.request.contextPath}/resources/js/reservation/car.js"></script>
</html>
