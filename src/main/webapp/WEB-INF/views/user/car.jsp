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

<script>
	// 예약 리스트
	document.addEventListener("DOMContentLoaded", function() {
	var carTable = document.getElementById("carTable");
	var pagination = document.getElementById("pagination");
	var page = 1;
	var size = 10;
	var pageGroupSize = 5;

	function loadCarList(currentPage) {
		page = currentPage;
		carTable.innerHTML = "";

		fetch("/api/user/car?page=" + page + "&size=" + size)
			.then(function(res) {
				return res.json();
			})
			.then(function(data) {
				var carReservationList = data.carReservationList;

				if (data.role === 'admin') {
		            document.getElementById('addCar').style.display = 'inline-block';
		        }

				for (var i = 0; i < carReservationList.length; i++) {
					var c = carReservationList[i];
					var tr = document.createElement("tr");

					// 차량 정보 td
					var tdInfo = document.createElement("td");
					tdInfo.innerHTML = '<div class="vehicleNo">' + c.vehicleNo + '</div>' +
									   '<div class="vehicleName">' + c.vehicleName + '</div>' +
									   '<div class="vehicleType">' + c.vehicleType + '</div>';
					tr.appendChild(tdInfo);

					// 예약 현황 td
					var tdChart = document.createElement("td");
					tdChart.innerHTML = '<div class="chart-container" data-reservations="' + encodeURIComponent(JSON.stringify(c.reservationPeriods)) + '"></div>';
					tr.appendChild(tdChart);

					// 예약 버튼 td
					var tdBtn = document.createElement("td");
					if (c.vehicleStatus === "Y") {
						tdBtn.innerHTML = '<button class="reservationBtn" data-vehicle-id="' + c.vehicleId + '">예약하기</button>';
					} else {
						tdBtn.innerHTML = '<button>예약불가</button>';
					}
					tr.appendChild(tdBtn);

					// 숨겨진 input 추가
					var hiddenInput = document.createElement("input");
					hiddenInput.type = "hidden";
					hiddenInput.value = c.vehicleId;
					tr.appendChild(hiddenInput);

					carTable.appendChild(tr);
				}

				drawCharts();

				// ===== 페이징 추가 =====
				renderPagination(data.pageDto.totalPage);
			})
			.catch(function(err) {
				console.error("차량 데이터 로드 실패:", err);
			});
	}

	function renderPagination(totalPage) {
		pagination.innerHTML = ""; // 기존 페이지 번호 초기화

		var currentGroup = Math.floor((page - 1) / pageGroupSize);
		var startPage = currentGroup * pageGroupSize + 1;
		var endPage = Math.min(startPage + pageGroupSize - 1, totalPage);

		// 이전 그룹 이동
		var prevLi = document.createElement("li");
		prevLi.className = "page-item" + (startPage > 1 ? "" : " disabled");
		var prevA = document.createElement("a");
		prevA.className = "page-link";
		prevA.href = "#";
		prevA.innerText = "<";
		prevA.onclick = function(e) {
			e.preventDefault();
			if (startPage > 1) loadCarList(startPage - 1);
		};
		prevLi.appendChild(prevA);
		pagination.appendChild(prevLi);

		// 페이지 번호 반복
		for (var i = startPage; i <= endPage; i++) {
			var li = document.createElement("li");
			li.className = "page-item" + (i === page ? " active" : "");
			var a = document.createElement("a");
			a.className = "page-link";
			a.href = "#";
			a.innerText = i;
			a.onclick = (function(pageNum) {
				return function(e) {
					e.preventDefault();
					loadCarList(pageNum);
				};
			})(i);
			li.appendChild(a);
			pagination.appendChild(li);
		}

		// 다음 그룹 이동
		var nextLi = document.createElement("li");
		nextLi.className = "page-item" + (endPage < totalPage ? "" : " disabled");
		var nextA = document.createElement("a");
		nextA.className = "page-link";
		nextA.href = "#";
		nextA.innerText = ">";
		nextA.onclick = function(e) {
			e.preventDefault();
			if (endPage < totalPage) loadCarList(endPage + 1);
		};
		nextLi.appendChild(nextA);
		pagination.appendChild(nextLi);
	}

	// 초기 데이터 로드
	loadCarList(page);
});


	// 로그인 사용자 ID
	const userId = "<c:out value='${loginUser.userId}'/>";

	// 초기 날짜 세팅: 현재시간 ~ 23:59
	let today = new Date();
	selectedStartDate = new Date(today);
	selectedStartDate.setHours(0,0,0,0);
	selectedEndDate = new Date(today);
	selectedEndDate.setHours(23,59,59,999);
	let drawnTimes = new Set(); // 중복 시간 출력 방지

	// 시간 라벨 표시 함수
	function drawTimeLabel(ctx, x, date) {
		const hourStr = date.getHours().toString().padStart(2,'0') + ":00";
		if(hourStr === "00:00") return;
		const key = x + "-" + hourStr;
		if(drawnTimes.has(key)) return;
		ctx.fillStyle = "black";
		ctx.font = "10px Arial";
		ctx.fillText(hourStr, x, 45);
		drawnTimes.add(key);
	}

	// 오늘날짜 체크
	function isToday(date) {
		const now = new Date();
		return date.getFullYear() === now.getFullYear() &&
			   date.getMonth() === now.getMonth() &&
			   date.getDate() === now.getDate();
	}

	// 차트 그리기 함수
	function drawCharts() {
		const charts = document.querySelectorAll(".chart-container");

		charts.forEach(chart => {

			chart.innerHTML = "";

			const localDrawnTimes = new Set();

			let periods = JSON.parse(decodeURIComponent(chart.dataset.reservations || "[]"));

			let canvasStart = new Date(selectedStartDate);
			let canvasEnd = new Date(selectedEndDate);

			const canvas = document.createElement("canvas");
			chart.appendChild(canvas);

			canvas.width = chart.clientWidth;
			canvas.height = chart.clientHeight;

			const ctx = canvas.getContext("2d");

			const totalHours = (canvasEnd - canvasStart) / (1000 * 60 * 60);
			const unitWidth = canvas.width / totalHours;

			const drawTimeLabelLocal = (x, date) => {
				const hourStr = date.getHours().toString().padStart(2, '0') + ":00";
				if (hourStr === "00:00") return;
				const key = x + "-" + hourStr;
				if (localDrawnTimes.has(key)) return;
				ctx.fillStyle = "black";
				ctx.font = "10px Arial";
				ctx.fillText(hourStr, x, 45);
				localDrawnTimes.add(key);
			};

			// 1) 전체 바
			ctx.fillStyle = "#e8e6e6";
			ctx.fillRect(0, 15, canvas.width, 20);
			drawTimeLabelLocal(0, canvasStart);

			// 2) 예약 구간
			periods.forEach((p, index) => {

				const startStr = p.reservationStart || p.start;
				const endStr = p.reservationEnd || p.end;

				if (!startStr || !endStr) return;

				const resStart = new Date(startStr.replace(" ", "T"));
				const resEnd = new Date(endStr.replace(" ", "T"));

				if (isNaN(resStart.getTime()) || isNaN(resEnd.getTime())) {
					console.log("예약 데이터 변환 실패:", p);
					return;
				}

				const displayStart = resStart < canvasStart ? canvasStart : resStart;
				const displayEnd = resEnd > canvasEnd ? canvasEnd : resEnd;

				if (displayEnd <= displayStart) return;

				const xStart = ((displayStart - canvasStart) / (1000 * 60 * 60)) * unitWidth;
				const xEnd = ((displayEnd - canvasStart) / (1000 * 60 * 60)) * unitWidth;


				// console.log("예약", index + 1, "=> xStart:", xStart, "xEnd:", xEnd, "width:", xEnd - xStart);

				ctx.fillStyle = "red";
				ctx.fillRect(xStart, 15, xEnd - xStart, 20);

				drawTimeLabelLocal(xStart, displayStart);
				drawTimeLabelLocal(xEnd, displayEnd);
			});

			// 3) 선택 구간
			const startTimeValue = document.getElementById("startTime").value;
			const endTimeValue = document.getElementById("endTime").value;

			if (startTimeValue && endTimeValue) {

				const [sh, sm] = startTimeValue.split(":").map(Number);
				const [eh, em] = endTimeValue.split(":").map(Number);

				const selStart = new Date(selectedStartDate); selStart.setHours(sh, sm, 0);
				const selEnd = new Date(selectedEndDate); selEnd.setHours(eh, em, 0);

				const cs = new Date(Math.max(selStart, canvasStart));
				const ce = new Date(Math.min(selEnd, canvasEnd));

				if (ce > cs) {

					const x1 = ((cs - canvasStart) / (1000 * 60 * 60)) * unitWidth;
					const x2 = ((ce - canvasStart) / (1000 * 60 * 60)) * unitWidth;

					ctx.fillStyle = "blue";
					ctx.fillRect(x1, 15, x2 - x1, 20);

					drawTimeLabelLocal(x1, cs);
					drawTimeLabelLocal(x2, ce);
				}
			}

			// 4) 날짜 표시 (MM-DD)
			const oneDay = 1000 * 60 * 60 * 24;
			ctx.fillStyle = "black";
			ctx.font = "bold 10px Arial";

			for (let d = new Date(canvasStart); d <= canvasEnd; d = new Date(d.getTime() + oneDay)) {
				const offsetX = ((d - canvasStart) / (1000 * 60 * 60)) * unitWidth;
				const month = (d.getMonth() + 1).toString().padStart(2, '0');
				const day = d.getDate().toString().padStart(2, '0');
				ctx.fillText(month + "-" + day, offsetX, 10);
			}

			// 5) 오늘 이전 회색 처리
			const now = new Date();
			const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
			if (now > canvasStart) {
				const pastHours = Math.min((today - canvasStart) / (1000 * 60 * 60), totalHours);
				const pastX = pastHours * unitWidth;
				let grayStartX = 0;
				let grayEndX = pastX;

				periods.forEach(p => {
					const reservationStart = new Date(p.reservationStart);
					if (reservationStart < today) {
						const reservedStartX = ((reservationStart - canvasStart) / (1000 * 60 * 60)) * unitWidth;
						grayEndX = Math.max(0, reservedStartX);
					}
				});

				if (grayEndX > grayStartX) {
					ctx.fillStyle = "#e8e6e6";
					ctx.fillRect(grayStartX, 15, grayEndX - grayStartX, 20);
				}
			}
		});
	}

	// 시간 드롭다운
	function populateTimeOptions(selectId, firstOptionLabel){
	    const select = document.getElementById(selectId);
	    select.innerHTML="";
	    const firstOption = document.createElement("option");
	    firstOption.value="";
	    firstOption.textContent=firstOptionLabel;
	    select.appendChild(firstOption);
	
	    for(let h=0;h<24;h++){
	        const hourStr = h.toString().padStart(2,'0');
	        const option = document.createElement('option');
	        option.value = hourStr+":00";
	        option.textContent = hourStr+":00";
	        select.appendChild(option);
	    }
	}
	
	// 시작시간 유효성
	function validateStartTime(){
	    const timeSelect = document.getElementById("startTime");
	    const selectedTime = timeSelect.value;
	    if(!selectedTime || !selectedStartDate) return;
	
	    const today = new Date();
	    const [hours, minutes] = selectedTime.split(":").map(Number);
	
	    const selectedDateTime = new Date(selectedStartDate.getFullYear(),
	        selectedStartDate.getMonth(),
	        selectedStartDate.getDate(),
	        hours, minutes);
	
	    if(selectedStartDate.toDateString() === today.toDateString()){
	        if(selectedDateTime<today){
	            alert("선택한 시작시간은 현재 시간 이후여야 합니다.");
	            timeSelect.value="";
	        }
	    }
	}
	
	// yyyy-mm-dd 포맷
	function formatLocalDate(date){
	    const yyyy = date.getFullYear();
	    const mm = String(date.getMonth()+1).padStart(2,'0');
	    const dd = String(date.getDate()).padStart(2,'0');
	    return yyyy+"-"+mm+"-"+dd;
	}

		document.addEventListener("DOMContentLoaded", function(){
		    populateTimeOptions("startTime","-- 대여시간 선택 --");
		    populateTimeOptions("endTime","-- 반납시간 선택 --");
		
		    flatpickr("#rentalPeriod",{
		        mode:"range",
		        dateFormat:"Y-m-d",
		        locale:"ko",
		        minDate:"today",
		        allowInput:true,
		        defaultDate:[new Date(), new Date()],
		        onClose:function(selectedDates, dateStr, instance){
		            if(selectedDates.length===1){
		                selectedStartDate = new Date(selectedDates[0]);
		                selectedStartDate.setHours(0,0,0,0); // 당일 선택시 초기값 00:00
		                selectedEndDate = new Date(selectedDates[0]);
		                selectedEndDate.setHours(23,59,59,999); // 당일 선택 초기값 23:59
		                instance.setDate([selectedStartDate, selectedEndDate], true);
		            } else if(selectedDates.length===2){
		                selectedStartDate = new Date(selectedDates[0]);
		                selectedEndDate = new Date(selectedDates[1]);
		                selectedStartDate.setHours(0,0,0,0);
		                selectedEndDate.setHours(23,59,59,999);
		            }
		            
		            drawCharts();
		        }
		    });
	
		
		    document.getElementById("startTime").addEventListener("change",validateStartTime);
		
		    drawCharts();
		
		    document.getElementById("search").addEventListener("click", function(e){
		        e.preventDefault();
		        
		        drawCharts();
		    });
		});
		
		// 날짜 형태 yyyy-mm-dd + hh:mm:ss DB-datetime형식으로
		function formatDateTime(date, time) {
		    if(!date || !time) return "";
		    const yyyy = date.getFullYear();
		    const mm = String(date.getMonth() + 1).padStart(2, '0');
		    const dd = String(date.getDate()).padStart(2, '0');
		    return yyyy + "-" + mm + "-" + dd + " " + time + ":00";
		}
	
		// 조회버튼 이벤트
		document.getElementById("search").addEventListener("click", function() {
		    var vehicleType = document.querySelector("select").value;
		    var startDate = selectedStartDate;
		    var endDate = selectedEndDate;
		    var startTime = document.getElementById("startTime").value;
		    var endTime = document.getElementById("endTime").value;
		    
		    // 대여시간 > 반납시간 방지 - 대여시간 이후 반납시간을 선택
		    var startDateTime = formatDateTime(startDate, startTime);
		    var endDateTime = formatDateTime(endDate, endTime);

		    const startDT = new Date(startDateTime.replace(" ", "T"));
		    const endDT = new Date(endDateTime.replace(" ", "T"));

		    if(vehicleType == '') {
				alert('차량타입을 선택하세요.')
		    } else if(endDate == '') {
				alert('예약 기간을 선택하세여.')
		    } else if(startTime == '') {
				alert('예약시간을 선택하세요.')
		    } else if(startDT  > endDT) {
				alert('예약 시간 이후에 반납시간을 선택하세요')
		    } else if(startDT == endDT) {
				alert('예약시간과 반납시간이 같습니다.')
		    }
		    
		    const rows = document.querySelectorAll("table tr");
		    for(let i=1; i<rows.length; i++){ 
		        const typeCell = rows[i].querySelector(".vehicleType");
		        if(vehicleType === "전체" || vehicleType === "" || typeCell.textContent === vehicleType){
		            rows[i].style.display = "";
		        } else {
		            rows[i].style.display = "none";
		        }
		    }
		    
		    drawCharts();
	
		    console.log("차량 타입:", vehicleType);
		    console.log("대여일시:", startDateTime);
		    console.log("반납일시:", endDateTime);
		});
		
		// 모달
		document.addEventListener("DOMContentLoaded", function() {
	
		    const modal = document.getElementById("carModal");
		    const btn = document.getElementById("addCar");
		    const closeBtn = modal.querySelector(".close");
		    const closeBtns = modal.querySelectorAll(".close1");
		    
		    // 폼 가져오기
		    const addForm = document.getElementById("addForm");
		    const modifyForm = document.getElementById("modifyCar");
		    const toggleForm = document.getElementById("carToggle");
		    const adminTypeSelect = document.getElementById("adminType");
	
		    // 모달 열기
		    btn.onclick = function() {
		        modal.style.display = "flex";
		        showForm("등록");
		    	adminTypeSelect.value = "등록";
		    	
		    	selectAdminCarList();
		    	
		    }
	
		    // 모달 닫기버튼 (x)
		    closeBtn.onclick = function() {
		        modal.style.display = "none";
		    }
		    
		 	// 모달 닫기버튼
		    closeBtns.forEach(function(b) {
				b.onclick = function() {
					modal.style.display = "none";
				}
			});
	
		    // 모달 외부 클릭 닫기
		    window.onclick = function(event) {
		        if(event.target == modal) {
		            modal.style.display = "none";
		        }
		    }
	
		    // 등록
		    addForm.addEventListener("submit", function(e) {
		        e.preventDefault();
		        
		        const vehicleNo = this.vehicleNo.value.trim();
		        const vehicleName = this.vehicleName.value.trim();
		        
		        if(!vehicleNo) {
					alert("차량번호를 입력하세요")
					return;
		        } else if(!vehicleName) {
		        	alert("차종을 입력하세요")
					return;
		        } 
	
		        $.ajax({
		            url: "/api/car/addCar",
		            type: "post",
		            data: $(this).serialize(),
		            success: function(response) {
		                alert("차량 등록 완료");
		                modal.style.display = "none";
		                location.reload();
		            },
		            error: function(xhr, status, error) {
		                alert("등록 실패: " + error);
		            }
		        });
		    });
		    
		    modifyCar.addEventListener("submit", function(e) {
				e.preventDefault();
				
				$.ajax({
					url: "/api/car/modifyCar",
					type: "post",
					data: $(this).serialize(),
					success: function(response) {
						alert("수정 완료");
						modal.style.display = "none";
						location.reload();
					},
					error: function(xhr, status, error) {
						alert("수정 실패: " + error);
					}
				});
		    });
		    
		    // 비활성 or 활성화
		    carToggle.addEventListener("submit", function(e) {
				e.preventDefault();
				console.log($(this).serialize());
				
				$.ajax({
				    url: "/api/car/carToggle",
				    type: "post",
				    data: {
				        vehicleId: $('#toggleVehicleSelect').val(),
				        vehicleUseReasonContent: $('#toggleReason').val(),
				        vehicleUseReasonStartDate: $('#startDate').val(),
				        vehicleUseReasonEndDate: $('#endDate').val(),
				        vehicleStatus: $('#toggleSwitch').is(':checked') ? "Y" : "N"
				    },
				    success: function(res){
				        console.log("변경 완료");
				        modal.style.display = "none";
						location.reload();
				    }
				});
		    });
		    
	    
		// 이슈등록에 사용할 차량 리스트
	    $(document).ready(function() {
	        $.ajax({
	            url: '/api/car/adminCarList',
	            method: 'GET',
	            success: function(vehicleList) {
	              
	            	 var selects = [$('#modifyVehicleSelect'), $('#toggleVehicleSelect')];

	            	 selects.forEach(function(select) {
	                     select.empty();
	                     select.append('<option value="">-- 차량 선택 --</option>');
	                     
	                     vehicleList.forEach(function(vehicle) {
	                         
	                         var statusText = vehicle.vehicleStatus === 'Y' ? '활성화' : '비활성화';

	                         // 옵션 추가
	                         select.append(
	                             '<option value="' + vehicle.vehicleId + '">' 
	                             + vehicle.vehicleNo + ' (' + statusText + ')' 
	                             + '</option>'
	                         );
	                     });
	                 });
	             },
	             
	            error: function(err) {
	                console.error('차량 목록을 불러오는데 실패했습니다.', err);
	            }
	        });
	    });
		
		    // 모달 열 때 호출
		    $('#toggleModalOpenBtn').on('click', function() {
		        $('#carToggle').show();
		    });

		    // 비활성화 폼에서 선택한 차량 가져오기
		    $('#toggleVehicleSelect').change(function() {
		        var selectedId = $(this).val();
		        console.log('선택한 차량 ID (이슈등록 폼):', selectedId);
		        $('#carToggle input[name="vehicleId"]').val(selectedId); 
		    });

		    // 폼에서 선택한 차량 가져오기
		    $('#modifyVehicleSelect').change(function() {
		        var selectedId = $(this).val();
		        $('input[name="vehicleId"]').val(selectedId);
		    });

		    // 폼 전환
		    function showForm(type) {
		        // 모든 폼 숨기기
		        addForm.style.display = "none";
		        modifyForm.style.display = "none";
		        toggleForm.style.display = "none";

		        // 선택한 폼만 보이기
		        if (type === "등록") {
		            addForm.style.display = "block";
		        } else if (type === "수정") {
		            modifyForm.style.display = "block";
		        } else if (type === "이슈등록") {
		            toggleForm.style.display = "block";
		        }     
		        
		    }

		    // select 값 바뀔 때 폼 전환
		    adminTypeSelect.addEventListener("change", function() {
		        showForm(this.value);
		    });
		});

		
		// 예약확인 모달
		document.addEventListener("DOMContentLoaded", function() {
			const modal = document.getElementById("confirmReservation");
			const btn = document.getElementById("myReservation");       
			const closeBtn = modal.querySelector(".close");             
			const closeBtns = modal.querySelectorAll(".close1");         
			const table = document.getElementById("myReservationList"); 
		
			// 예약 확인 버튼 클릭 시 모달 열기 + 데이터 채우기
			btn.addEventListener("click", async function() {
				// 테이블 기존 내용 초기화 (헤더 제외)
				table.querySelectorAll("tr:not(:first-child)").forEach(tr => tr.remove());
		
				try {
					const res = await fetch("/api/user/myReservationList");
					if (!res.ok) throw new Error("서버 오류");
		
					const data = await res.json();
					const myReservationList = data.myReservationList;
					
					//console.log("예약 리스트 확인:", myReservationList);

		
					// 예약 목록 테이블에 채우기
					myReservationList.forEach(c => {
						const tr = document.createElement("tr");
		
						// 차량번호
						const tdVehicleNo = document.createElement("td");
						tdVehicleNo.textContent = c.vehicleNo;
						tr.appendChild(tdVehicleNo);
		
						// 대여 시간
						const tdRentDate = document.createElement("td");
						tdRentDate.textContent = c.rentDate;
						tr.appendChild(tdRentDate);
		
						// 반납 시간
						const tdReturnDate = document.createElement("td");
						tdReturnDate.textContent = c.returnDate;
						tr.appendChild(tdReturnDate);
						
						// rentDateObj 정의 후 24시간 전 계산
						const rentDateObj = new Date(c.rentDate.replace(/-/g, "/"));
						const twentyFourHoursBefore = new Date(rentDateObj.getTime() - 24*60*60*1000);
						const now = new Date();

						// 24시간 전까지만 변경/취소 가능
						const isChangeable = now < twentyFourHoursBefore && rentDateObj > now;
		
					
						// 예약 취소 버튼
						const tdCancel = document.createElement("td");
						const cancelBtn = document.createElement("button");
						cancelBtn.textContent = "취소";
						cancelBtn.disabled = !isChangeable;
						
						// 예약 취소 이벤트
						cancelBtn.addEventListener("click", async function(){
							//console.log("취소 차량 예약 ID 확인:", c.vehicleReservationId);

							if(!confirm("예약을 취소하시겠습니까?")) return;
							
							try {
								const res = await fetch("/api/user/cancelMyReservation?vehicleReservation=" + c.vehicleReservationId, {
									method: "post"
								});
								
								if(!res.ok) throw new Error("서버 오류");
								
								alert("예약이 취소되었습니다.");
								tr.remove(); // 예약내역 삭제
							} catch (err) {
								//console.error(err);
								alert("예약 취소중 오류가 발생했습니다.");
							}
						});
						
						// 버튼생성
						tdCancel.appendChild(cancelBtn);
						tr.appendChild(tdCancel);
		
						table.appendChild(tr);
					});
		
					// 모달 열기
					modal.style.display = "flex";
		
				} catch (err) {
					console.error(err);
					alert("예약 내역을 가져오는 중 오류가 발생했습니다.");
				}
				// 모달 닫기버튼 (x)
			    closeBtn.onclick = function() {
			        modal.style.display = "none";
			    }
			    
			 	// 모달 닫기버튼
			    closeBtns.forEach(function(b) {
					b.onclick = function() {
						modal.style.display = "none";
					}
				});
		
			    // 모달 외부 클릭 닫기
			    window.onclick = function(event) {
			        if(event.target == modal) {
			            modal.style.display = "none";
			        }
			    }
			});
		});
	
		// 날짜 포맷 YYYY-MM-DD
		function formatDate(date) {
		    let y = date.getFullYear();
		    let m = ("0" + (date.getMonth() + 1)).slice(-2);
		    let d = ("0" + date.getDate()).slice(-2);
		    return y + "-" + m + "-" + d;
		}
		
		// Flatpickr 초기화(이슈등록)
		flatpickr("#issueDate", {
		    mode: "range",      // 날짜 범위 선택 가능
		    dateFormat: "Y-m-d",
		    locale:"ko",
		    defaultDate: new Date(), // 오늘 기본값
		    onClose: function(selectedDates) {
		        // 시작일과 종료일을 hidden input에 넣기
		        if (selectedDates.length === 1) {
		            // 당일 선택
		            document.getElementById("startDate").value = formatDate(selectedDates[0]);
		            document.getElementById("endDate").value = formatDate(selectedDates[0]);
		        } else if (selectedDates.length === 2) {
		            // 범위 선택
		            document.getElementById("startDate").value = formatDate(selectedDates[0]);
		            document.getElementById("endDate").value = formatDate(selectedDates[1]);
		        }
		        
		        // console.log('비활성 시작시간 : ', startDate);
		        // console.log('비활성 종료시간 :', endDate);
		    }
		});
		
		// 예약 버튼 이벤트 (모든 버튼에 적용)
		document.getElementById("carTable").addEventListener("click", function(e){
		    if(e.target && e.target.classList.contains("reservationBtn")){
		        var vehicleId = e.target.dataset.vehicleId;
		        var startDateTime = formatDateTime(selectedStartDate, document.getElementById("startTime").value);
		        var endDateTime = formatDateTime(selectedEndDate, document.getElementById("endTime").value);
		
		        if(!userId) {
					alert('로그인이 필요합니다.')
					return;
		        } else if(!vehicleId) {
					alert('차량선택에 에러가 발생했습니다.')
					return;
		        } else if(!startDateTime) {
					alert('대여시간을 선택해주세요.')
					return;
		        } else if(!endDateTime) {
					alert('반납시간을 선택해주세요.')
					return;
		        }
		        
		        console.log("userId:", userId);
		        console.log("vehicleId:", vehicleId);
		        console.log("start:", startDateTime);
		        console.log("end:", endDateTime);		     
		
		        $.ajax({
		            url: "/api/car/CarReservation",
		            type: "POST",
		            contentType: "application/json",
		            data: JSON.stringify({
		                userId: userId,
		                vehicleId: vehicleId,
		                vehicleReservationStartTime: startDateTime,
		                vehicleReservationEndTime: endDateTime
		            }),
		            success: function(res) {
		                alert(res);
		                // 예약 후 리스트 다시 로드
		                location.reload();
		            },
		            error: function(err) {
		                console.error("예약 실패", err);
		                alert("예약에 실패했습니다.");
		            }
		        });
		    }
		});
		
</script>

<footer>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</footer>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>

</body>
</html>
