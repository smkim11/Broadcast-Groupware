<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- DataTables -->
<link href="${pageContext.request.contextPath}/resources/libs/datatables.net-bs4/css/dataTables.bootstrap4.min.css" rel="stylesheet" type="text/css" />
<link href="${pageContext.request.contextPath}/resources/libs/datatables.net-buttons-bs4/css/buttons.bootstrap4.min.css" rel="stylesheet" type="text/css" />
<!-- Responsive datatable examples -->
<link href="${pageContext.request.contextPath}/resources/libs/datatables.net-responsive-bs4/css/responsive.bootstrap4.min.css" rel="stylesheet" type="text/css" /> 

<link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
<meta charset="UTF-8">
<style>
#datatable-buttons_wrapper .dt-buttons .btn {
    background-color: #5c74ec !important;
    border: 1px solid #5c74ec;
    color: white !important;
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
	            		<c:choose>
	            			<c:when test="${ald.role == 'admin' or ald.userRank == '국장' }">
	            				<h4 class="mb-0">직원 근태</h4>
	            			</c:when>
	            			<c:when test="${ald.role != 'admin' and ald.userRank == '팀장' }">
	            				<h4 class="mb-0">팀원 근태</h4>
	            			</c:when>
	            			<c:when test="${ald.role != 'admin' and ald.userRank == '부서장' }">
	            				<h4 class="mb-0">부서원 근태</h4>
	            			</c:when>
	            		</c:choose>
                        
                    </div>
	                <div class="card">
	                    <div class="card-body">
		                    <div class="d-flex align-items-center justify-content-center mb-3">
							    <button id="prev" class="btn btn-sm btn-outline-primary me-2"><</button>
							    <h5 id="attendanceDate" class="mb-0">${ald.year }년 ${ald.month }월</h5>
							    <button id="next" class="btn btn-sm btn-outline-primary ms-2">></button>
							</div>
	                        <table id="datatable-buttons" class="table table-bordered dt-responsive nowrap" style="border-collapse: collapse; border-spacing: 0; width: 100%;">
	                            <thead>
		                            <tr>
		                                <th>부서</th>
		                                <th>팀</th>
		                                <th>이름</th>
		                                <th>근무시간</th>
		                                <th>지각횟수</th>
		                                <th>사용휴가</th>
		                            </tr>
	                            </thead>
	                            <tbody id="attendanceBody">
	                            <c:forEach var="list" items="${list}">
		                            <tr>
		                                <td>${list.departmentName }</td>
		                                <td>${list.teamName }</td>
		                                <td>${list.fullName } ${list.userRank }</td>
		                                <td>${list.monthWorkHours }</td>
		                                <td>${list.lateness }회</td>
		                                <td></td>
		                            </tr>
	                            </c:forEach>
	                            </tbody>
	                        </table>
	                    </div>
	                </div>
	            </div> <!-- end col -->
	        </div> <!-- end row -->
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
</body>
<script>
var year = ${ald.year};
var month = ${ald.month};
/*
	

	var attendanceDate = document.getElementById("attendanceDate");
	function attendance(y,m){
		fetch(`/selectAttendanceList?year=${y}&month=${m}`)
	 		.then(res => res.json())
	        .then(data => {
	        	console.log("응답 데이터:", data);	
	            year = data.ald.year;
	            month = data.ald.month;
	            attendanceDate.innerText =
	                `${data.ald.year}년 ${data.ald.month}월`;
			const tbody = document.getElementById("attendanceBody");
			tbody.innerHTML ="";
			data.list.forEach(item => {
                tbody.innerHTML += `
                    <tr>
                        <td>${item.departmentName}</td>
                        <td>${item.teamName}</td>
                        <td>${item.fullName} ${item.userRank}</td>
                        <td>${item.monthWorkHours}</td>
                        <td>${item.lateCount || ''}</td>
                        <td>${item.vacation || ''}</td>
                    </tr>
                `;
            });
        });
	}
*/	
	document.getElementById("prev").addEventListener("click",()=>{
		let newMonth = month - 1;
	    let newYear = year;
        if (newMonth < 1) {   // 1월보다 작으면
        	newMonth = 12;
            newYear--;
        }
        //attendance(year, month);
        location.href = '/attendanceList?year='+newYear+'&month='+newMonth;
	});
	
	document.getElementById("next").addEventListener("click",()=>{
		let newMonth = month + 1;
	    let newYear = year;
        if (newMonth > 12) {   // 12월보다 크면
        	newMonth = 1;
        	newYear++;
        }
        location.href = '/attendanceList?year='+newYear+'&month='+newMonth;
        //attendance(year, month);
	});
</script>
<!-- Required datatable js -->
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net/js/jquery.dataTables.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-bs4/js/dataTables.bootstrap4.min.js"></script>
<!-- Buttons examples -->
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-buttons/js/dataTables.buttons.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-buttons-bs4/js/buttons.bootstrap4.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/jszip/jszip.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/pdfmake/build/pdfmake.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/pdfmake/build/vfs_fonts.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-buttons/js/buttons.html5.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-buttons/js/buttons.print.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-buttons/js/buttons.colVis.min.js"></script>

<!-- Responsive examples -->
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-responsive/js/dataTables.responsive.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/datatables.net-responsive-bs4/js/responsive.bootstrap4.min.js"></script>

<!-- Datatable init js -->
<script src="${pageContext.request.contextPath}/resources/js/pages/datatables.init.js"></script>

<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>
</html>