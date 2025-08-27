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
	/* 글자색 흰색으로 */
	.fc-event {
    color: #fff !important;
    cursor: default !important;
	}
	.fc-event:hover {
    opacity: 1 !important;
    color: #fff !important;
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
                        <h4 class="mb-0">근태</h4>
                        <input type="hidden" name="loginUser" id="loginUser" value="${loginUser}">
                    </div>
                </div>
            </div>
                       
			<div class="col-xl-12">
                 <div class="card">
                     <div class="card-body">
                         <h4 class="card-title"><span id="date" style="color:gray"></span></h4>
                         <span id="time" style="color:gray; font-size: 30px;"></span>
                         <div class="row">
                             <div class="col-6">
                                 <div>
                                 <c:choose>
                                 	<c:when test="${attendance.attendanceIn == null}">
                                 		<button class="btn btn-outline-primary" id="in">출근</button>
                                 		<button class="btn btn-outline-primary" id="outside">외근</button>
                                 	</c:when>
                                 	<c:when test="${attendance.attendanceIn == null and attendance.attendanceOutside != null and attendance.attendanceOut == null}">
                                 		<button class="btn btn-outline-primary" id="out">퇴근</button>
                                 		<button class="btn btn-outline-primary" id="inside">복귀</button>
                                 	</c:when>
                                 	<c:when test="${attendance.attendanceIn != null and attendance.attendanceOutside == null and attendance.attendanceOut == null}">
                                 		<button class="btn btn-outline-primary" id="out">퇴근</button>
                                 		<button class="btn btn-outline-primary" id="outside">외근</button>
                                 	</c:when>
                                 	<c:when test="${attendance.attendanceIn != null and attendance.attendanceOutside != null 
                                 					and attendance.attendanceOut == null and attendance.attendanceInside == null}">
                                 		<button class="btn btn-outline-primary" id="out">퇴근</button>
                                 		<button class="btn btn-outline-primary" id="inside">복귀</button>
                                 	</c:when>
                                 	<c:when test="${attendance.attendanceOut != null}">
                                 	</c:when>
                                 	<c:when test="${attendance.attendanceInside != null and attendance.attendanceInside != null}">
                                 		<button class="btn btn-outline-primary" id="out">퇴근</button>
                                 	</c:when>
                                 </c:choose>
                                 </div>
                             </div>
                             <div class="col-6">
                                 <div class="card-group" style="margin-top:-70px;">
                                     <div class="card">
                     					<div class="card-body">
                 							총 근무일
                    						<div>${totalWorkDay}</div>
                     					</div>
                     				</div>
                     				<div class="card">
                     					<div class="card-body">
                     						이번달 근무시간
                     						<div>${fn:substring(monthWorkHours,0,2)}시간 ${fn:substring(monthWorkHours,3,5)}분</div>
                   						</div>
               						</div>
                					<div class="card">
                     					<div class="card-body">
                     						잔여 휴가
                     					</div>
                     				</div>
                                 </div>
                         	</div>
                    	</div>
                 	</div>
             	</div>
			</div>
			<div class="row">
            	<div class="col-12">
            		<div class="row">
            			<div class="col-lg-12">
            				<div class="card">
                        		<div class="card-body">
                        			<div id="calendar"></div>
                        		</div>
                			</div>
                       	</div>
                	</div>
               	</div>
           </div>
		</div>
	</div>
</div>
<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>
</body>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
<script>
	const loginUser = document.getElementById("loginUser").value;
	window.attendaceEvents = [
	    <c:forEach var="list" items="${attendanceList}" varStatus="loop">
	    
	        {
				// 출근시간과 퇴근시간을 분단위 까지만 보이도록 설정
	            title: "출근 ${fn:substring(list.attendanceIn,0,5)} ~ ${fn:substring(list.attendanceOut,0,5)}",
	            // fullcalendar에서 start와 end는 (yyyy-MM-dd'T'HH:mm:ss)형식으로 넣어줘야 한다
	            start: "${list.attendanceDate}T${list.attendanceIn}",
	            end: "${list.attendanceDate}T${list.attendanceOut}",
	            className: "bg-info"
	        },
	        {
				// 외근출발 시간과 복귀시간을 분단위 까지만 보이도록 설정
	            title: "외근 ${fn:substring(list.attendanceOutside,0,5)} ~ ${fn:substring(list.attendanceInside,0,5)}",
	            // fullcalendar에서 start와 end는 (yyyy-MM-dd'T'HH:mm:ss)형식으로 넣어줘야 한다
	            start: "${list.attendanceDate}T${list.attendanceOutside}",
	            end: "${list.attendanceDate}T${list.attendanceInside}",
	            className: "bg-success"
	        }<c:if test="${!loop.last}">,</c:if>
	    </c:forEach>
	];
    // 실시간 시계 1초마다 실행
	var clockDate = document.getElementById("date");
	var clockTime = document.getElementById("time");
    function clock() {
    	var time = new Date();
    	
    	var year = time.getFullYear();
    	var month = time.getMonth();
        var date = time.getDate();
        var day = time.getDay();
        var week = ['일', '월', '화', '수', '목', '금', '토'];
        
        var hours = time.getHours();
        var minutes = time.getMinutes();
        var seconds = time.getSeconds();

        clockDate.innerText =
        	(year)+"년 "+ (month + 1)+"월 " + (date)+"일 " + (week[day])+"요일";
        clockTime.innerText =
            (hours < 10 ? "0" + hours : hours) + ":" +
            (minutes < 10 ? "0" + minutes : minutes) + ":" +
            (seconds < 10 ? "0" + seconds : seconds);
    }
    clock();
    setInterval(clock, 1000); // 1초마다 실행

	var btnIn = document.getElementById("in");
    var btnOut = document.getElementById("out");
    var btnOutside = document.getElementById("outside");
    var btnInside = document.getElementById("inside");
    
    // 출근 기록 (출근버튼이 있을때만 실행가능)
    if(btnIn){
    	btnIn.addEventListener('click',()=>{
        	fetch("/insertAttendanceIn", {
                method: "POST",
                headers: {"Content-Type":"application/json"},
                body: JSON.stringify({userId:loginUser})
        	}).then((res) => {
        		if(res.ok){
        			Swal.fire({
        		        title: "출근하였습니다.",
        		        icon: "success",
        				confirmButtonText: "확인",
        		        confirmButtonColor: "#34c38f"
        		    }).then((result)=>{ // 확인 누르면 페이지 새로고침
        		    	if(result.isConfirmed){
        		    		location.reload();
        		    	}
        		    });
        		}else{
        			Swal.fire({
        	            title: "오류",
        	            icon: "error",
        				confirmButtonText: "확인",
        				confirmButtonColor: "#34c38f"
        	        });
        		}
        	});
        });
    }
    
    // 퇴근 기록(퇴근버튼이 있을때만 실행가능)
    if(btnOut){
    	btnOut.addEventListener('click',()=>{
        	fetch("/updateAttendanceOut", {
                method: "PATCH",
                headers: {"Content-Type":"application/json"},
                body: JSON.stringify({userId:loginUser})
        	}).then((res) => {
        		if(res.ok){
        			Swal.fire({
        		        title: "퇴근하였습니다.",
        		        icon: "success",
        				confirmButtonText: "확인",
        		        confirmButtonColor: "#34c38f"
        		    }).then((result)=>{ // 확인 누르면 페이지 새로고침
        		    	if(result.isConfirmed){
        		    		location.reload();
        		    	}
        		    });
        		}else{
        			Swal.fire({
        	            title: "오류",
        	            icon: "error",
        				confirmButtonText: "확인",
        				confirmButtonColor: "#34c38f"
        	        });
        		}
        	});
        });
    }
    
    // 외근 기록(외근버튼이 있을때만 가능)
    if(btnOutside){
    	btnOutside.addEventListener('click',()=>{
        	fetch("/updateAttendanceOutside", {
                method: "PATCH",
                headers: {"Content-Type":"application/json"},
                body: JSON.stringify({userId:loginUser})
        	}).then((res) => {
        		if(res.ok){
        			Swal.fire({
        		        title: "외근.",
        		        icon: "success",
        				confirmButtonText: "확인",
        		        confirmButtonColor: "#34c38f"
        		    }).then((result)=>{ // 확인 누르면 페이지 새로고침
        		    	if(result.isConfirmed){
        		    		location.reload();
        		    	}
        		    });
        		}else{
        			Swal.fire({
        	            title: "오류",
        	            icon: "error",
        				confirmButtonText: "확인",
        				confirmButtonColor: "#34c38f"
        	        });
        		}
        	});
        });
    }
    
    // 외근복귀 기록(복귀버튼이 있을때만 가능)
    if(btnInside){
    	btnInside.addEventListener('click',()=>{
        	fetch("/updateAttendanceInside", {
                method: "PATCH",
                headers: {"Content-Type":"application/json"},
                body: JSON.stringify({userId:loginUser})
        	}).then((res) => {
        		if(res.ok){
        			Swal.fire({
        		        title: "외근복귀하였습니다.",
        		        icon: "success",
        				confirmButtonText: "확인",
        		        confirmButtonColor: "#34c38f"
        		    }).then((result)=>{ // 확인 누르면 페이지 새로고침
        		    	if(result.isConfirmed){
        		    		location.reload();
        		    	}
        		    });
        		}else{
        			Swal.fire({
        	            title: "오류",
        	            icon: "error",
        				confirmButtonText: "확인",
        				confirmButtonColor: "#34c38f"
        	        });
        		}
        	});
        });
    }
    
</script>
<!-- plugin js -->
<script src="${pageContext.request.contextPath}/resources/libs/moment/min/moment.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/jquery-ui-dist/jquery-ui.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/fullcalendar/index.global.min.js"></script>

<!-- Calendar init -->
<script src="${pageContext.request.contextPath}/resources/js/pages/attendance-calendar.init.js"></script>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/pages/form-validation.init.js"></script>
</html>