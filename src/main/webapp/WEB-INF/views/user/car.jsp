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
			<th>대여시간</th>
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
				    ${c.reservationStart} ~ ${c.reservationEnd}
	        	</td>
				<td><button>예약하기</button></td>
			</tr>
		</c:forEach>
	</table>
	
	<!-- 페이징 -->


<script>

	document.addEventListener("DOMContentLoaded", function () {
	    populateTimeOptions("startTime");
	    populateTimeOptions("endTime");
	});
	
   	let selectedStartDate = null; // 대여일
   	let selectedEndDate = null; // 반납일
	        
	flatpickr("#rentalPeriod", {
	    mode: "range",          // Range 모드: 시작일 ~ 종료일 선택
	    dateFormat: "Y-m-d", // 날짜 형식
	    locale: "ko", // 한국어
	    minDate: "today", // 오늘 이후부터 예약일 선택
	    onClose: function(selectedDates, dateStr, instance) {
	        // 선택된 기간을 split해서 시작일/종료일 변수로 활용 가능
	        
	        if (selectedDates.length === 2) {
	        	selectedStartDate = selectedDates[0]; // 대여일
	        	selectedEndDate = selectedDates[1]; // 반납일
	            console.log("대여일:", selectedDates[0]);
	            console.log("반납일:", selectedDates[1]);
	        }
	    }
	});
   	
	document.getElementById("search").addEventListener("click", function () {
	    // ...
	    console.log("대여일:", selectedStartDate);
	    console.log("반납일:", selectedEndDate);
	});
	
   	// 시간 선택 드롭다운
   	document.addEventListener("DOMContentLoaded", function () {
	    populateTimeOptions("startTime", "-- 대여시간 선택 --");
	    populateTimeOptions("endTime", "-- 반납시간 선택 --");
	});
   	
   	function populateTimeOptions(selectId, firstOptionLabel) {
   	    const select = document.getElementById(selectId);
   	    select.innerHTML = ""; // 기존 옵션 초기화

   	    // 첫 번째 옵션 생성
   	    const firstOption = document.createElement("option");
   	    firstOption.value = "";
   	    firstOption.textContent = firstOptionLabel;
   	    select.appendChild(firstOption);

   	    // 시간 옵션 생성
   	    for (let h = 0; h < 24; h++) {
   	        const hourStr = h.toString().padStart(2, '0');
   	        const option = document.createElement('option');
   	        option.value = hourStr + ':00';
   	        option.textContent = hourStr + ':00';
   	        select.appendChild(option);
   	    }
   	}

	function validateStartTime() {
	    const timeSelect = document.getElementById("startTime");
	    const selectedTime = timeSelect.value;

	    if (!selectedTime || !selectedStartDate) return;

	    const today = new Date();
	    const [hours, minutes] = selectedTime.split(":").map(Number);

	    // 시작일 + 선택한 시간으로 Date 객체 생성
	    const selectedDateTime = new Date(
	        selectedStartDate.getFullYear(),
	        selectedStartDate.getMonth(),
	        selectedStartDate.getDate(),
	        hours,
	        minutes
	    );

	    // 날짜가 오늘인 경우에만 시간 비교
	    if (selectedStartDate.toDateString() === today.toDateString()) {
	        if (selectedDateTime < today) {
	            alert("선택한 시작시간은 현재 시간 이후여야 합니다.");
	            timeSelect.value = "";
	        }
	    }
	}

	document.getElementById("startTime").addEventListener("change", validateStartTime);
	
	// 형식 변경 yyyy-mm-dd hh:mm:ss
	function formatDateTime(dateObj, timeStr) {
	    if (!dateObj) return "";

	    const yyyy = dateObj.getFullYear();
	    const mm = String(dateObj.getMonth() + 1).padStart(2, '0'); // 월
	    const dd = String(dateObj.getDate()).padStart(2, '0'); // 일

	    let hh = "00", mi = "00", ss = "00";
	    if (timeStr) {
	        [hh, mi] = timeStr.split(":");
	    }

	    return yyyy + "-" + mm + "-" + dd + " " + hh + ":" + mi + ":" + ss;
	}

	
	// 조회 버튼 클릭 이벤트
	document.getElementById("search").addEventListener("click", function() {
	    var carTypeSelect = document.querySelector("select");
	    var carType = carTypeSelect.value;
	
	    var startDate = selectedStartDate;
	    var endDate = selectedEndDate;
	
	    var startTime = document.getElementById("startTime").value;
	    var endTime = document.getElementById("endTime").value;
	
	    // 검증 생략
	
	    // 포맷팅
	    var startDateTime = formatDateTime(startDate, startTime);
	    var endDateTime = formatDateTime(endDate, endTime);
		
	    <%--
	    console.log("차량 타입:", type);
	    console.log("대여일시:", startDateTime);
	    console.log("반납일시:", endDateTime);
	    --%>
	});

	
</script>

</body>
</html>
