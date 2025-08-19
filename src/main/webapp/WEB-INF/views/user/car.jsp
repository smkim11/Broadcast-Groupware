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

.main-container {
    padding-top: 80px;
    padding-bottom: 60px;
    width: 1000px;
    margin: 0 auto;
    font-family: 'Arial', sans-serif;
    background-color: #fdfdfd;
}

#reservationForm {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    margin-bottom: 20px;
    padding: 15px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background-color: #fafafa;
}

#reservationForm select,
#reservationForm input[type="text"] {
    padding: 6px 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
}

#reservationForm button {
    padding: 6px 12px;
    border: 1px solid #007BFF;
    background-color: #007BFF;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    transition: 0.3s;
}

#reservationForm button:hover {
    background-color: #0056b3;
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
.gray-box { background-color: gray; } 

.addCar {
    padding: 6px 12px;
    border: 1px solid #28a745;
    background-color: blue;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    transition: 0.3s;
}

.addCar:hover {
    background-color: #1e7e34;
    border-color: #1e7e34;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-bottom: 30px;
}

table th, table td {
    padding: 10px;
    text-align: center;
    border: 1px solid #ddd;
}

table th {
    background-color: #f1f1f1;
}

table tr:nth-child(even) {
    background-color: #fafafa;
}

.chart-container {
    position: relative;
    width: 100%;
    height: 50px;
    border-radius: 4px;
    overflow: hidden;
    background-color: #f0f0f0;
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
    width: 400px;
    text-align: center;
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4);
    position: relative;
}

.modal-content h3 {
    margin-bottom: 15px;
    color: blue;
}

.modal-content fieldset {
    border: 2px solid #007BFF;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 15px;
}

.modal-content legend {
    padding: 0 10px;
    font-weight: bold;
    color: #007BFF;
}

.modal-content input[type="text"],
.modal-content select {
    width: calc(100% - 20px);
    margin-bottom: 10px;
    padding: 6px 8px;
    border-radius: 4px;
    border: 1px solid #ccc;
}

.modal-content button {
    padding: 6px 12px;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    margin: 5px;
    transition: 0.3s;
}

.modal-content button[type="submit"] {
    background-color: #007BFF;
    color: white;
}

.modal-content button[type="submit"]:hover {
    background-color: #0056b3;
}

.modal-content .close, .modal-content .close1 {
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
}

.chart-container canvas {
    display: block;
}

</style>

</head>
<body>

<header>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</header>

	<div class="main-container">
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
					<span class="gray-box"></span> 예약 가능시간
					<span class="blue-box"></span> 선택시간
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
		
	</div>
	
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
				<button class="close1" type="button">닫기</button>
				<button type="submit">등록</button>
			</form>
		</div>
	</div>

<script>

	//초기 날짜 세팅: 현재시간 ~ 23:59
	let today = new Date();
	selectedStartDate = new Date(today);
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
	        const localDrawnTimes = new Set(); // 각 차트별 시간 Set
	
	        const reservationStart = new Date(chart.dataset.start);
	        const reservationEnd = new Date(chart.dataset.end);
	
	        let start = selectedStartDate || reservationStart;
	        let end = selectedEndDate || reservationEnd;
	        
	    	 // 오늘 날짜 선택 시 현재 시간 이후로 시작
	        if (isToday(start)) {
	            const now = new Date();
	            if (now > start) {
	                start = new Date(now); // 시작 시간을 현재 시간으로
	            }
	        }
	
	        const canvas = document.createElement("canvas");
	        canvas.width = chart.clientWidth;
	        canvas.height = chart.clientHeight;
	        chart.appendChild(canvas);
	
	        const ctx = canvas.getContext("2d");
	        const totalHours = (end - start) / (1000 * 60 * 60);
	        const unitWidth = canvas.width / totalHours;
	
	        // drawTimeLabelLocal 함수
	        function drawTimeLabelLocal(x, date) {
	            const hourStr = date.getHours().toString().padStart(2, '0') + ":00";
	            if (hourStr === "00:00") return;
	            const key = x + "-" + hourStr;
	            if (localDrawnTimes.has(key)) return;
	            ctx.fillStyle = "black";
	            ctx.font = "10px Arial";
	            ctx.fillText(hourStr, x, 45);
	            localDrawnTimes.add(key);
	        }
	
	        // 1) 전체 바 (파랑)
	        ctx.fillStyle = "gray";
	        ctx.fillRect(0, 15, canvas.width, 20);
	        drawTimeLabelLocal(0, start);
	
	        // 2) 예약 구간 (빨강)
	        const displayStart = new Date(Math.max(reservationStart, start));
	        const displayEnd = new Date(Math.min(reservationEnd, end));
	        if (displayEnd > displayStart) {
	            // 예약 좌표도 차트 범위 안으로 보정
	            const redStartX = ((displayStart - start) / (1000 * 60 * 60)) * unitWidth;
	            const redEndX = ((displayEnd - start) / (1000 * 60 * 60)) * unitWidth;
	            const redWidth = redEndX - redStartX;
	
	            ctx.fillStyle = "red";
	            ctx.fillRect(redStartX, 15, redWidth, 20);
	            drawTimeLabelLocal(redStartX, displayStart);
	            drawTimeLabelLocal(redEndX, displayEnd);
	        }
	
	        // 3) 선택 구간
	        const startTimeValue = document.getElementById("startTime").value;
	        const endTimeValue = document.getElementById("endTime").value;
	        if (startTimeValue && endTimeValue) {
	            const [startH, startM] = startTimeValue.split(":").map(Number);
	            const [endH, endM] = endTimeValue.split(":").map(Number);
	
	            const selectedStart = new Date(selectedStartDate);
	            selectedStart.setHours(startH, startM, 0);
	            const selectedEnd = new Date(selectedEndDate);
	            selectedEnd.setHours(endH, endM, 0);
	
	            // 선택 시간 범위를 차트 표시 구간(start~end) 안으로 보정
	            const clippedStart = new Date(Math.max(selectedStart, start));
	            const clippedEnd = new Date(Math.min(selectedEnd, end));
	
	            if (clippedEnd > clippedStart) { // 겹칠 때만 그림
	                const selStartX = ((clippedStart - start) / (1000 * 60 * 60)) * unitWidth;
	                const selEndX = ((clippedEnd - start) / (1000 * 60 * 60)) * unitWidth;
	
	                // 예약 좌표도 보정된 값 사용
	                const resStartX = ((displayStart - start) / (1000 * 60 * 60)) * unitWidth;
	                const resEndX = ((displayEnd - start) / (1000 * 60 * 60)) * unitWidth;
	
	                // 겹치는 영역 계산
	                const overlapStartX = Math.max(selStartX, resStartX);
	                const overlapEndX = Math.min(selEndX, resEndX);
	                const overlapWidth = Math.max(0, overlapEndX - overlapStartX);
	
	                // 왼쪽 초록
	                if (selStartX < overlapStartX) {
	                    ctx.fillStyle = "gray";
	                    ctx.fillRect(selStartX, 15, overlapStartX - selStartX, 20);
	                    drawTimeLabelLocal(selStartX, clippedStart);
	                    drawTimeLabelLocal(overlapStartX, new Date(Math.max(selectedStart, reservationStart)));
	                }
	
	                // 중복
	                if (overlapWidth > 0) {
	                    ctx.fillStyle = "red";
	                    ctx.fillRect(overlapStartX, 15, overlapWidth, 20);
	                    drawTimeLabelLocal(overlapStartX, new Date(Math.max(selectedStart, reservationStart)));
	                    drawTimeLabelLocal(overlapEndX, new Date(Math.min(selectedEnd, reservationEnd)));
	                }
	
	                // 오른쪽 초록
	                if (selEndX > overlapEndX) {
	                    ctx.fillStyle = "blue";
	                    ctx.fillRect(overlapEndX, 15, selEndX - overlapEndX, 20);
	                    drawTimeLabelLocal(overlapEndX, new Date(Math.min(selectedEnd, reservationEnd)));
	                    drawTimeLabelLocal(selEndX, clippedEnd);
	                }
	            }
	        }
	
	        // 4) 날짜 표시 (MM-DD)
	        const oneDay = 1000 * 60 * 60 * 24;
	        ctx.fillStyle = "black";
	        ctx.font = "bold 10px Arial";
	        for (let d = new Date(start); d <= end; d = new Date(d.getTime() + oneDay)) {
	            const offsetX = ((d - start) / (1000 * 60 * 60)) * unitWidth;
	            const month = (d.getMonth() + 1).toString().padStart(2, '0');
	            const day = d.getDate().toString().padStart(2, '0');
	            ctx.fillText(month + "-" + day, offsetX, 10);
	        }
	
	        // 5) 회색 처리 (오늘 이전)
	        const now = new Date();
	        if (now > start) {
	            const pastHours = Math.min((today - start) / (1000 * 60 * 60), totalHours);
	            const pastX = pastHours * unitWidth;
	            let grayStartX = 0;
	            let grayEndX = pastX;
	            if (reservationStart < today && reservationEnd > start) {
	                const reservedStartX = ((reservationStart - start) / (1000 * 60 * 60)) * unitWidth;
	                grayEndX = Math.max(0, reservedStartX);
	            }
	            if (grayEndX > grayStartX) {
	                ctx.fillStyle = "gray";
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
	
		    var startDateTime = formatDateTime(startDate, startTime);
		    var endDateTime = formatDateTime(endDate, endTime);
		    
		    if(vehicleType == '') {
				alert('차량타입을 선택하세요.')
		    } else if(endDate == '') {
				alert('대여 기간을 선택하세여.')
		    } else if(startTime == '') {
				alert('대여시간을 선택하세요.')
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
	
		    console.log("차량 타입:", vehicleType);
		    console.log("대여일시:", startDateTime);
		    console.log("반납일시:", endDateTime);
		});
		
		// 모달
		document.addEventListener("DOMContentLoaded", function() {
	
		    const modal = document.getElementById("carModal");
		    const btn = document.getElementById("addCar");
		    const closeBtn = modal.querySelector(".close");
		    const closeBtn1 = modal.querySelector(".close1");
		    const carForm = document.getElementById("carForm");
	
		    // 모달 열기
		    btn.onclick = function() {
		        modal.style.display = "flex";
		    }
	
		    // 모달 닫기버튼
		    closeBtn.onclick = function() {
		        modal.style.display = "none";
		    }
		    
		 	// 모달 닫기버튼
		    closeBtn1.onclick = function() {
		        modal.style.display = "none";
		    }
	
		    // 모달 외부 클릭 닫기
		    window.onclick = function(event) {
		        if(event.target == modal) {
		            modal.style.display = "none";
		        }
		    }
	
		    // 등록
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

<footer>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</footer>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>

</body>
</html>
