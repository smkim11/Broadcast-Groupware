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
.chart-container {
    position: relative;
    width: 500px;
    height: 50px;
    border: 1px solid #ccc;
    background: #f9f9f9;
    margin: 5px 0;
}
.time-scale {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
    color: #555;
}
.legend-container {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
}

.addCar {
    padding: 5px 10px;
    font-size: 14px;
    cursor: pointer;
}
.legend {
    margin: 10px 0;
    font-size: 12px;
}
.legend span {
    display: inline-block;
    width: 15px;
    height: 10px;
    margin-right: 5px;
}
.legend .reserved { background: red; }
.legend .available { background: #ccc; }

/* 막대에 상태값 표시색상 */
.legend {
    font-size: 14px;
    color: #333;
}

.red-box, .gray-box, .blue-box, .green-box, .purple-box{
    display: inline-block;
    width: 20px;
    height: 20px;
    margin-right: 5px;
    vertical-align: middle; 
}

.red-box { background-color: red; }
.gray-box { background-color: gray; }
.blue-box { background-color: blue; }
.green-box { background-color: green; }
.purple-box { background-color: purple; }

.modal {
	display: none; 
	position: fixed;
	z-index: 1000;
	left: 0;
	top: 0;
	width: 100%;
	height: 100%;
	background-color: rgba(0, 0, 0, 0.5);
	justify-content: center;
	align-items: center;
}

.modal-content {
	background: white;
	padding: 20px;
	border-radius: 10px;
	width: 400px;
	text-align: center;
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
}


/* fieldset (틀) */
.modal-content fieldset {
	border: 2px solid #007BFF; /* 파란색 테두리 */
	border-radius: 8px;
	padding: 15px;
}

/* legend (제목) */
.modal-content legend {
	padding: 0 10px;
	font-weight: bold;
	color: #007BFF;
}

/* 닫기 버튼 */
.modal .close {
	position: absolute;
	right: 10px;
	top: 5px;
	font-size: 24px;
	font-weight: bold;
	cursor: pointer;
}


</style>

</head>
<body>

	<form id="reservationForm" action="/api/car" method="post">
	    <label>차량선택</label>
	    <select>
	        <option value="">--타입--</option>
	        <option value="소형">소형</option>
	        <option value="중형">중형</option>
	        <option value="대형">대형</option>
	    </select>
	
	    <input type="text" id="rentalPeriod" placeholder="대여일 ~ 반납일" readonly>
	
	    <select id="startTime"></select>
	    <select id="endTime"></select>
	
	    <button type="submit" id="search">조회하기</button>
	</form>
	
	<p>예약 가능한 차량은 총 0대 입니다.</p>
	
		<div class="legend-container">
			<div class="legend">
				<span class="red-box"></span> 예약상태
				<span class="gray-box"></span> 예약 불가
				<span class="blue-box"></span> 예약 가능
				<span class="green-box"></span> 선택시간
				<span class="purple-box"></span> 겹침
			</div>
			<button id="addCar" class="addCar">차량등록</button> <!-- 로그인 기능 구현 후 관리자만 보이게 출력 -->
		</div>
	
	<table border="1">
	<tr>
	    <th>차량정보</th>
	    <th>예약 현황</th>
	    <th>예약하기</th>
	</tr>
	
	<c:forEach var="c" items="${carReservationList}">
		<input type="hidden" value="${c.vehicleId}">
	<tr>
	    <td>
	        <div class="vehicleNo">${c.vehicleNo}</div> 
	        <div class="vehicleName">${c.vehicleName}</div> 
	        <div class="vehicleType">${c.vehicleType}</div>
	    </td>
	    <td>
	        <div class="chart-container"
	             data-start="${c.reservationStart}"
	             data-end="${c.reservationEnd}">
	        </div>
	    </td>
	    <td><button>예약하기</button></td>
	</tr>
	</c:forEach>
	</table>
	
	<!-- 차량등록 모달 -->
	<div id="carModal" class="modal">
		<div class="modal-content">
			<span class="close">&times;</span>
			<h3>차량 등록</h3>
			<form id="carForm">
				<label>차량번호:</label>
				<input type="text" name="vehicleNo" placeholder="000가0000"></br>
				<label>차종:</label>
				<input type="text" name="vehicleName" placeholder="ex) 아반떼, 카니발"></br>
				<label>차량타입:</label>
				<select name="vehicleType" required>
					<option value="소형">소형</option>
					<option value="중형">중형</option>
					<option value="대형">대형</option>
				</select> </br>
				
				<button type="submit">등록</button>
			</form>
		</div>
	</div>

<script>

	//초기 날짜 세팅: 오늘 전체
	let today = new Date();
	selectedStartDate = new Date(today);
	selectedStartDate.setHours(0,0,0,0);
	selectedEndDate = new Date(today);
	selectedEndDate.setHours(23,59,59,999);
	let drawnTimes = new Set(); // 중복 시간 출력 방지용
	
	// 시간 라벨 표시 함수
	function drawTimeLabel(ctx, x, date) {
	    const hourStr = date.getHours().toString().padStart(2,'0') + ":00";
	    if(hourStr === "00:00") return; // 00:00은 표시 안함
	    const key = x + "-" + hourStr;
	    if(drawnTimes.has(key)) return; // 이미 표시된 시간 건너뛰기
	    ctx.fillStyle = "black";
	    ctx.font = "10px Arial";
	    ctx.fillText(hourStr, x, 45); // 막대 아래 표시
	    drawnTimes.add(key);
	}
	
	//초기 날짜 세팅: 오늘 전체
	let now = new Date();
	selectedStartDate = new Date(today);
	selectedStartDate.setHours(0,0,0,0);
	selectedEndDate = new Date(today);
	selectedEndDate.setHours(23,59,59,999);

	// 차트 그릭 함수
	function drawCharts() {
	    const charts = document.querySelectorAll(".chart-container");

	    charts.forEach(chart => {
	        chart.innerHTML = "";
	        const localDrawnTimes = new Set(); // 각 차트별 시간 Set

	        const reservationStart = new Date(chart.dataset.start);
	        const reservationEnd = new Date(chart.dataset.end);

	        const start = selectedStartDate || reservationStart;
	        const end = selectedEndDate || reservationEnd;

	        const canvas = document.createElement("canvas");
	        canvas.width = chart.clientWidth;
	        canvas.height = chart.clientHeight;
	        chart.appendChild(canvas);

	        const ctx = canvas.getContext("2d");
	        const totalHours = (end - start) / (1000*60*60);
	        const unitWidth = canvas.width / totalHours;

	        // drawTimeLabelLocal 함수 상태에따라 색호출
	        function drawTimeLabelLocal(x, date) {
	            const hourStr = date.getHours().toString().padStart(2,'0') + ":00";
	            if(hourStr === "00:00") return;
	            const key = x + "-" + hourStr;
	            if(localDrawnTimes.has(key)) return;
	            ctx.fillStyle = "black";
	            ctx.font = "10px Arial";
	            ctx.fillText(hourStr, x, 45);
	            localDrawnTimes.add(key);
	        }

	        // 전체 바 (파랑)
	        ctx.fillStyle = "blue";
	        ctx.fillRect(0, 15, canvas.width, 20);
	        drawTimeLabelLocal(0, start); // 전체 시작 시간 표시

	        // 예약 구간 빨강
	        const displayStart = new Date(Math.max(reservationStart, start));
	        const displayEnd = new Date(Math.min(reservationEnd, end));
	        let redStartX, redWidth;
	        if(displayEnd > displayStart){
	            redStartX = ((displayStart - start)/(1000*60*60))*unitWidth;
	            redWidth = ((displayEnd - displayStart)/(1000*60*60))*unitWidth;
	            ctx.fillStyle = "red";
	            ctx.fillRect(redStartX,15,redWidth,20);
	            drawTimeLabelLocal(redStartX, displayStart); // 기존예약 시간(빨강)
	            drawTimeLabelLocal(redStartX + redWidth, displayEnd); // 기존예약 종료
	        }

	        // 선택한 시간 초록/보라 처리
	        const startTimeValue = document.getElementById("startTime").value;
	        const endTimeValue = document.getElementById("endTime").value;
	        if(startTimeValue && endTimeValue){
	            const [startH,startM] = startTimeValue.split(":").map(Number);
	            const [endH,endM] = endTimeValue.split(":").map(Number);

	            const selectedStart = new Date(selectedStartDate);
	            selectedStart.setHours(startH,startM,0);
	            const selectedEnd = new Date(selectedEndDate);
	            selectedEnd.setHours(endH,endM,0);

	            // 빨강 예약 종료 이후부터 초록 시작
	            const greenStartTime = new Date(Math.max(selectedStart, reservationEnd));
	            const greenEndTime = selectedEnd;

	            const greenStartX = ((greenStartTime - start)/(1000*60*60))*unitWidth;
	            const greenWidth = ((greenEndTime - greenStartTime)/(1000*60*60))*unitWidth;

	            // 겹치는 영역 계산 (선택 시작~예약 종료 구간)
	            const overlapStartX = ((selectedStart - start)/(1000*60*60))*unitWidth;
	            const overlapEndX = ((Math.min(selectedEnd, reservationEnd) - start)/(1000*60*60))*unitWidth;
	            const overlapWidth = Math.max(0, overlapEndX - overlapStartX);

	            // 보라색 영역
	            if(overlapWidth > 0){
	                ctx.fillStyle = "purple";
	                ctx.fillRect(overlapStartX, 15, overlapWidth, 20);
	                drawTimeLabelLocal(overlapStartX, new Date(Math.max(selectedStart, displayStart))); // ❗ 보라 시작 시간
	                drawTimeLabelLocal(overlapEndX, new Date(Math.min(selectedEnd, displayEnd))); // ❗ 보라 종료 시간
	            }

	            // 겹치지 않는 초록 영역
	            if(greenWidth > 0){
	                ctx.fillStyle = "green";
	                ctx.fillRect(greenStartX, 15, greenWidth, 20);
	                drawTimeLabelLocal(greenStartX, greenStartTime); // ❗ 초록 시작 시간
	                drawTimeLabelLocal(greenStartX + greenWidth, greenEndTime); // ❗ 초록 종료 시간
	            }
	        }

	        // 날짜 표시 (MM-DD)
	        const oneDay = 1000*60*60*24;
	        ctx.fillStyle = "black";
	        ctx.font = "bold 10px Arial";
	        for(let d=new Date(start); d<=end; d=new Date(d.getTime()+oneDay)){
	            const offsetX = ((d-start)/(1000*60*60))*unitWidth;
	            const month = (d.getMonth()+1).toString().padStart(2,'0');
	            const day = d.getDate().toString().padStart(2,'0');
	            ctx.fillText(month + "-" + day, offsetX, 10);
	        }

	        // 회색 처리 (오늘 이전)
	        const now = new Date();
	        if(now>start){
	            const pastHours = Math.min((today-start)/(1000*60*60),totalHours);
	            const pastX = pastHours * unitWidth;
	            let grayStartX = 0;
	            let grayEndX = pastX;
	            if(reservationStart<today && reservationEnd>start){
	                const reservedStartX = ((reservationStart-start)/(1000*60*60))*unitWidth;
	                grayEndX = Math.max(0,reservedStartX);
	            }
	            if(grayEndX>grayStartX){
	                ctx.fillStyle="gray";
	                ctx.fillRect(grayStartX,15,grayEndX-grayStartX,20);
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
	
	function formatDateTime(date, time) {
	    if(!date || !time) return "";
	    const yyyy = date.getFullYear();
	    const mm = String(date.getMonth() + 1).padStart(2, '0');
	    const dd = String(date.getDate()).padStart(2, '0');
	    return yyyy + "-" + mm + "-" + dd + " " + time + ":00";
	}

	document.getElementById("search").addEventListener("click", function() {
	    var vehicleType = document.querySelector("select").value;
	    var startDate = selectedStartDate;
	    var endDate = selectedEndDate;
	    var startTime = document.getElementById("startTime").value;
	    var endTime = document.getElementById("endTime").value;

	    var startDateTime = formatDateTime(startDate, startTime);
	    var endDateTime = formatDateTime(endDate, endTime);
	    
	    if(vehicleType == '') {
			alert('차량타입을 선택하세요.')
	    } else if(endDate == '') {
			alert('대여 기간을 선택하세여.')
	    } else if(startTime == '') {
			alert('대여시간을 선택하세요.')
	    }

	    console.log("차량 타입:", vehicleType);
	    console.log("대여일시:", startDateTime);
	    console.log("반납일시:", endDateTime);
	});
	
	document.addEventListener("DOMContentLoaded", function() {

	    const modal = document.getElementById("carModal");
	    const btn = document.getElementById("addCar");
	    const closeBtn = modal.querySelector(".close");
	    const carForm = document.getElementById("carForm");

	    // 모달 열기
	    btn.onclick = function() {
	        modal.style.display = "flex";
	    }

	    // 모달 닫기
	    closeBtn.onclick = function() {
	        modal.style.display = "none";
	    }

	    // 모달 외부 클릭 닫기
	    window.onclick = function(event) {
	        if(event.target == modal) {
	            modal.style.display = "none";
	        }
	    }

	    // submit 이벤트 한 번만 등록
	    carForm.addEventListener("submit", function(e) {
	        e.preventDefault();

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
	});


</script>

</body>
</html>
