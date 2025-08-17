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

.red-box, .gray-box, .blue-box{
    display: inline-block;
    width: 20px;
    height: 20px;
    margin-right: 5px;
    vertical-align: middle; 
}

.red-box { background-color: red; }
.gray-box { background-color: gray; }
.blue-box { background-color: blue; }

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
	
	    <select id="startTime">
	
	    </select>
	
	    <select id="endTime">
	
	    </select>
	
	    <button type="submit" id="search">조회하기</button>
	</form>
	
	<p>예약 가능한 차량은 총 0대 입니다.
	
	<table border="1">
		<tr>
			<th>차량정보</th>
			<th>예약 현황</th>
			<th>예약하기</th>
		</tr>
		
		<c:forEach var="c" items="${carReservationList}">
			<tr>
				<td>
					<div class="vehicleNo">${c.vehicleNo}</div> 
					<div class="vehicleName">${c.vehicleName}</div> 
					<div class="vehicleType">${c.vehicleType}</div>
				</td>
		 <td>
		    <!-- 예약 막대 차트 (Canvas 들어감) -->
		    <div class="legend">
			    <span class="red-box"></span> 예약상태
			    <span class="gray-box"></span> 예약 불가
			    <span class="blue-box"></span> 예약 가능
			</div>
		
		    <div class="chart-container"
		         data-start="${c.reservationStart}"
		         data-end="${c.reservationEnd}">
		    </div>
		
		</td>

				<td><button>예약하기</button></td>
			</tr>
		</c:forEach>
	</table>
	
	<!-- 페이징 -->

<script>

	let selectedStartDate = null; // 대여일
	let selectedEndDate = null;   // 반납일
	
	//차트 그리기 함수
	function drawCharts() {
	const charts = document.querySelectorAll(".chart-container");

	charts.forEach(chart => {
		chart.innerHTML = ""; // 이전 canvas 제거

		const reservationStart = new Date(chart.dataset.start);
		const reservationEnd = new Date(chart.dataset.end);

		// 선택된 대여일이 없으면 예약 기간만 사용
		const start = selectedStartDate || reservationStart;
		const end = selectedEndDate || reservationEnd;

		const canvas = document.createElement("canvas");
		canvas.width = chart.clientWidth;
		canvas.height = chart.clientHeight;
		chart.appendChild(canvas);

		const ctx = canvas.getContext("2d");

		// 전체 기간 (시간 단위)
		const totalHours = (end - start) / (1000 * 60 * 60);
		const unitWidth = canvas.width / totalHours;

		// 전체 바 (파랑: 예약 가능시간)
		ctx.fillStyle = "blue";
		ctx.fillRect(0, 15, canvas.width, 20);

		// 예약 구간 (빨강) - 선택 기간과 겹치는 부분만 표시
		const displayStart = new Date(Math.max(reservationStart, start));
		const displayEnd = new Date(Math.min(reservationEnd, end));

		if (displayEnd > displayStart) {
			const redStartX = ((displayStart - start) / (1000*60*60)) * unitWidth;
			const redWidth = ((displayEnd - displayStart) / (1000*60*60)) * unitWidth;

			ctx.fillStyle = "red";
			ctx.fillRect(redStartX, 15, redWidth, 20);

			//  예약 구간 시작/끝 시간 표시
			ctx.fillStyle = "black";
			const textY = 15 + 20 + 5;
			ctx.font = "12px Arial";
			const startLabel = displayStart.getHours().toString().padStart(2, '0') + ":00";
			const endLabel = displayEnd.getHours().toString().padStart(2, '0') + ":00";
			

			// 날짜 + 시간 표시 (00:00은 제외)
			if (startLabel !== "00:00") {
				// 날짜 (막대 위)
				ctx.font = "bold 10px Arial";
				ctx.fillText(displayStart.toLocaleDateString("ko-KR"), redStartX, 10);

				// 시간 (날짜 밑)
				ctx.font = "10px Arial";
				ctx.fillText(startLabel, redStartX, 25);
			}

			if (endLabel !== "00:00") {
				// 날짜 (막대 위)
				ctx.font = "bold 10px Arial";
				const endDateText = displayEnd.toLocaleDateString("ko-KR");
				const endDateWidth = ctx.measureText(endDateText).width;
				ctx.fillText(endDateText, redStartX + redWidth - endDateWidth, 10);

				// 시간 (날짜 밑)
				ctx.font = "10px Arial";
				const endTimeWidth = ctx.measureText(endLabel).width;
				ctx.fillText(endLabel, redStartX + redWidth - endTimeWidth, 25);
			}

		}

			// 오늘 기준 이전 구간 처리 (회색)
			const today = new Date();
			if (today > start) {
			    const pastHours = Math.min((today - start) / (1000*60*60), totalHours);
			    const pastX = pastHours * unitWidth;
	
			    // 🔹 예약구간을 제외한 부분만 회색
			    let grayStartX = 0;
			    let grayEndX = pastX;
	
			    // 예약이 오늘 이전부터 시작된 경우 → 예약 시작 전까지만 회색
			    if (reservationStart < today && reservationEnd > start) {
			        const reservedStartX = ((reservationStart - start) / (1000*60*60)) * unitWidth;
			        grayEndX = Math.max(0, reservedStartX);
			    }
	
			    if (grayEndX > grayStartX) {
			        ctx.fillStyle = "gray";
			        ctx.fillRect(grayStartX, 15, grayEndX, 20);
			    }
			}
		});
	}

	
	//시간 선택 드롭다운 생성
	function populateTimeOptions(selectId, firstOptionLabel) {
		const select = document.getElementById(selectId);
		select.innerHTML = "";
	
		const firstOption = document.createElement("option");
		firstOption.value = "";
		firstOption.textContent = firstOptionLabel;
		select.appendChild(firstOption);
	
		for (let h = 0; h < 24; h++) {
			const hourStr = h.toString().padStart(2, '0');
			const option = document.createElement('option');
			option.value = hourStr + ':00';
			option.textContent = hourStr + ':00';
			select.appendChild(option);
		}
	}
	
	//시작시간 유효성 검사
	function validateStartTime() {
		const timeSelect = document.getElementById("startTime");
		const selectedTime = timeSelect.value;
		if (!selectedTime || !selectedStartDate) return;
	
		const today = new Date();
		const [hours, minutes] = selectedTime.split(":").map(Number);
	
		const selectedDateTime = new Date(
			selectedStartDate.getFullYear(),
			selectedStartDate.getMonth(),
			selectedStartDate.getDate(),
			hours,
			minutes
		);
	
		if (selectedStartDate.toDateString() === today.toDateString()) {
			if (selectedDateTime < today) {
				alert("선택한 시작시간은 현재 시간 이후여야 합니다.");
				timeSelect.value = "";
			}
		}
	}
	
	//yyyy-mm-dd hh:mm:ss 포맷 함수
	function formatDateTime(dateObj, timeStr) {
		if (!dateObj) return "";
		const yyyy = dateObj.getFullYear();
		const mm = String(dateObj.getMonth() + 1).padStart(2, '0');
		const dd = String(dateObj.getDate()).padStart(2, '0');
		let hh = "00", mi = "00", ss = "00";
		if (timeStr) [hh, mi] = timeStr.split(":");
		return yyyy + "-" + mm + "-" + dd + " " + hh + ":" + mi + ":" + ss;
	}
	
	//대여시간 및 반납시간 초기화
	document.addEventListener("DOMContentLoaded", function () {
		populateTimeOptions("startTime", "-- 대여시간 선택 --");
		populateTimeOptions("endTime", "-- 반납시간 선택 --");
	
		// Flatpickr
		flatpickr("#rentalPeriod", {
			mode: "range",
			dateFormat: "Y-m-d",
			locale: "ko",
			minDate: "today",
			onClose: function(selectedDates) {
				if (selectedDates.length === 2) {
					selectedStartDate = selectedDates[0];
					selectedEndDate = selectedDates[1];
					console.log("대여일:", selectedStartDate);
					console.log("반납일:", selectedEndDate);
	
					// 차트 갱신
					drawCharts();
				}
			}
		});
	
		// 시작시간 변경 이벤트
		document.getElementById("startTime").addEventListener("change", validateStartTime);
	
		// 조회 버튼
		document.getElementById("search").addEventListener("click", function(e) {
			e.preventDefault(); // 폼 제출 막기
	
			const carTypeSelect = document.querySelector("select");
			const carType = carTypeSelect.value;
	
			const startTime = document.getElementById("startTime").value;
			const endTime = document.getElementById("endTime").value;
	
			const startDateTime = formatDateTime(selectedStartDate, startTime);
			const endDateTime = formatDateTime(selectedEndDate, endTime);
	
			console.log("차량 타입:", carType);
			console.log("대여일시:", startDateTime);
			console.log("반납일시:", endDateTime);
	
			// 차트 갱신
			drawCharts();
		});
	});

</script>

</body>
</html>
