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
                                     <button class="btn btn-outline-primary" id="in">출근</button>
                                     <button class="btn btn-outline-primary" id="out">퇴근</button>
                                     <button class="btn btn-outline-primary" id="outside">외근</button>
                                     <button class="btn btn-outline-primary" id="inside">복귀</button>
                                 </div>
                             </div>
                             <div class="col-6">
                                 <div class="card-group" style="margin-top:-70px;">
                                     <div class="card">
                     					<div class="card-body">
                     						<div class="col-2">
                     							총 휴가
                     						</div>
                     					</div>
                     				</div>
                     				<div class="card">
                     					<div class="card-body">
                     						<div class="col-2">
                     							사용 휴가
                     						</div>
                   						</div>
               						</div>
                					<div class="card">
                     					<div class="card-body">
                     						<div class="col-2">
                     							잔여 휴가
                     						</div>
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