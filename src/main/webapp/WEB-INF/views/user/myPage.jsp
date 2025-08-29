<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/sign/signature_pad.umd.min.js"></script>
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
</style>
<title>KOJ방송국</title>
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
                        <h4 class="mb-0">마이페이지</h4>
                    </div>
                </div>
            </div>
   		<form class="needs-validation" id="myPageForm" novalidate>
			<table class="table table-bordered align-middle">
				<input type="hidden" name="userId" id="userId" value="${myInfo.userId }"/>
				<tr>
					<th colspan="2">
						<img src="${pageContext.request.contextPath}/resources/images/users/avatar-4.jpg" 
							alt="" class="avatar-lg rounded-circle img-thumbnail">
					</th>
				</tr>
				<tr>
					<th class="text-center">소속</th>
					<td><input type="text" name="belong" id="belong" class="form-control" value="${myInfo.belong }" readonly></td>
				</tr>
				<tr>
					<th class="text-center">이름</th>
					<td><input type="text" name="fullName" id="fullName" class="form-control" value="${myInfo.fullName }" readonly></td>
				</tr>
				<tr>
					<th class="text-center">사원번호</th>
					<td><input type="text" name="username" id="username" class="form-control" value="${myInfo.username }" readonly></td>
				</tr>
				<!-- 
				<tr>
					<th class="text-center">비밀번호</th>
					<td><input type="password" name="pw" id="pw" class="form-control"></td>
				</tr>
				-->
				<tr>
					<th class="text-center">전화번호</th>
					<td><input type="text" name="userPhone" id="userPhone" value="${myInfo.userPhone }" placeholder="Ex) 010-1234-5678" 
							class="form-control" pattern="^\d{2,3}-\d{3,4}-\d{4}$" required>
					<div class="invalid-feedback">올바른 전화번호를 입력하세요.</div></td>
				</tr>
				<tr>
					<th class="text-center">이메일</th>
					<td><input type="email" name="userEmail" id="userEmail" value="${myInfo.userEmail }" placeholder="Ex) example@naver.com"
							class="form-control" required>
					<div class="invalid-feedback">올바른 이메일을 입력하세요.</div></td>
				</tr>
				<tr>
				    <th class="text-center">서명</th>
				    	<!-- 서명이 없으면 서명등록창, 있으면 저장된 서명이미지 -->
				    	<td>
						    <c:choose>
						    	<c:when test="${myInfo.sign == null }">
							    	<canvas id="signCanvas" width="400px" height="200px" style="border: 1px solid #000000;"></canvas>
							        <div class="mt-2 d-flex gap-2">
							            <button type="button" id="btnClear" class="btn btn-secondary btn-sm">삭제</button>
							            <button type="button" id="btnSign" class="btn btn-primary btn-sm">등록</button>
							        </div>
							        <input type="hidden" id="signImg" name="signImg">
						    	</c:when>
						    	<c:otherwise>
						    		 <img src="/final/${myInfo.sign}" 
       									alt="서명 이미지" width="300" height="150">
						    	</c:otherwise>
						    </c:choose>
				    	</td>
				</tr>
			</table>
			<div class="text-center">
				<button type="submit" id="btn" class="btn btn-outline-primary">수정</button>
			</div>
		</form>
   		</div>
    </div>
</div>
<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
<script>
	var canvas = document.getElementById("signCanvas");
	
	
	if(canvas){
		const signaturePad = new SignaturePad($('canvas')[0], {
			  minWidth: 2,
		    maxWidth: 2,
		    penColor: 'rgb(0, 0, 0)'
		});
		
		// 캔버스 내용 초기화하는 clear()메소드
		$('#btnClear').click(function(){
			signaturePad.clear();
		});
		
		// ajax로 SignaturePad 객체안 사인이미지를 서버로 전송
		$('#btnSign').click(function(){
			if(signaturePad.isEmpty()){
				alert('서명을 해주세요.');
			}else{
				$.ajax({
					asyn : true, // true면 비동기(백그라운드로 실행)
					url: '/addSign',
					type: 'post',
					data: {
						userId: $('#userId').val()
						, userImagesName: signaturePad.toDataURL() // 인수 생략시 기본값은 PNG 이미지
					} // 로그인 사용자 id, signaturePad객체 안의 사인 이미지
				}).done(function(data){ // data = 결제 완료
					$('#signImg').val(data);
					Swal.fire({
        		        title: "서명을 등록하였습니다.",
        		        icon: "success",
        				confirmButtonText: "확인",
        		        confirmButtonColor: "#34c38f"
        		    }).then((result)=>{ // 확인 누르면 페이지 새로고침
        		    	if(result.isConfirmed){
        		    		location.reload();
        		    	}
        		    });
				}).fail(function(){
					Swal.fire({
	                    title: "등록을 실패했습니다.",
	                    icon: "error",
						confirmButtonText: "확인",
						confirmButtonColor: "#34c38f"
	                });
				});
			}
		});
	}
	const form = document.getElementById("myPageForm");
	form.addEventListener("submit", function(e){
		// 유효성검사에 걸리면 실행되지 않는다
		e.preventDefault();
	    if(!form.checkValidity()){
	        e.stopPropagation();
	        form.classList.add("was-validated");
	        return;
	    }
		const userId = document.getElementById("userId").value;
		const userPhone = document.getElementById("userPhone").value;
		const userEmail = document.getElementById("userEmail").value;
		
		fetch("/updateMyPage", {
	        method: "PATCH",
	        headers: {"Content-Type":"application/json"},
	        body: JSON.stringify({userId:userId,userPhone:userPhone,userEmail:userEmail})
	    }).then((res) => {
			if(res.ok){
				Swal.fire({
			        title: "수정되었습니다.",
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
                    title: "수정을 실패했습니다.",
                    icon: "error",
					confirmButtonText: "확인",
					confirmButtonColor: "#34c38f"
                });
			}
		});
	});
</script>
</body>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/pages/form-validation.init.js"></script>
</html>