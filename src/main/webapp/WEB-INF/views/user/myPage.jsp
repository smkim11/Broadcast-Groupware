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
	input[readonly] {
	  background-color: #F6F6F6;
	}
	/* 테이블 카드 */
	.table-card {
	    background-color: #fff;
	    padding: 20px;
	    border-radius: 12px;
	    box-shadow: 0 4px 15px rgba(0,0,0,0.05);
	    margin-top: 20px;
	}
	
	/* 프로필 이미지 강조 */
	#profileImg {
	    width: 150px;
	    height: 150px;
	    border-radius: 50%;
	    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
	    transition: transform 0.2s;
	}
	#profileImg:hover {
	    transform: scale(1.05);
	}
	
	/* 서명 캔버스 중앙정렬 */
	#signCanvas, #updateSignCanvas {
	    display: block;
	    margin: 10px auto;
	    border-radius: 6px;
	}
	
	/* 버튼 스타일 개선 */
	.btn-outline-primary, .btn-outline-success, .btn-outline-secondary {
	    border-radius: 6px;
	    padding: 6px 12px;
	    transition: all 0.2s;
	}
	.btn-outline-primary:hover {
	    background-color: #34c38f;
	    color: white;
	    border-color: #34c38f;
	}
	
	/* 테이블 내용 중앙 정렬 */
	.table th, .table td {
	    vertical-align: middle !important;
	}
	
	/* 프로필 이미지 카드 내부에서 중앙 정렬 */
	.card.text-center img#profileImg {
	    display: block;
	    margin: 0 auto; /* 좌우 중앙 정렬 */
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
            <div class="row g-3">
			  <!-- 프로필 -->
			  <div class="col-md-4">
			    <div class="card text-center shadow-sm rounded-2 p-3">
			    	<div>&nbsp;</div><div>&nbsp;</div>
			      <!-- 프로필 이미지 -->
			      <img src="/final/${myInfo.profile}" alt="프로필" id="profileImg" class="avatar-lg rounded-circle mb-3" style="cursor:pointer;">
					<form id="uploadForm" action="/addProfile" method="post" enctype="multipart/form-data">
				        <input type="file" id="fileInput" name="file" accept="image/*" style="display:none;" onchange="document.getElementById('uploadForm').submit();">
				    </form>
					<div>&nbsp;</div><div>&nbsp;</div><div>&nbsp;</div>
			      <!-- 이름, 직급, 소속 -->
			      <h4>${myInfo.fullName}</h4>
			      <p>${myInfo.belong} | ${myInfo.userRank}</p>
			      <div>&nbsp;</div><div>&nbsp;</div>
			    </div>
			  </div>

			  <!-- 정보 수정 카드 -->
			  <div class="col-md-8">
			    <div class="card shadow-sm rounded-2 p-3">
			      <form id="myPageForm" class="needs-validation" novalidate>
			        <table class="table table-bordered align-middle mb-3">
			          <input type="hidden" name="userId" id="userId" value="${myInfo.userId}"/>
			          <tr>
			            <th class="text-center">사원번호</th>
			            <td><input type="text" name="username" id="username" class="form-control" value="${myInfo.username}" readonly></td>
			          </tr>
			          <tr>
			            <th class="text-center">생년월일</th>
			            <td><input type="text" name="birth" id="birth" class="form-control" value="${myInfo.birth}" readonly></td>
			          </tr>
			          <tr>
			            <th class="text-center">전화번호</th>
			            <td>
			              <input type="text" name="userPhone" id="userPhone" value="${myInfo.userPhone}" placeholder="Ex) 010-1234-5678" 
			                     class="form-control" pattern="^\d{2,3}-\d{3,4}-\d{4}$" required>
			              <div class="invalid-feedback">올바른 전화번호를 입력하세요.</div>
			            </td>
			          </tr>
			          <tr>
			            <th class="text-center">이메일</th>
			            <td>
			              <input type="email" name="userEmail" id="userEmail" value="${myInfo.userEmail}" placeholder="Ex) example@naver.com"
			                     class="form-control" required>
			              <div class="invalid-feedback">올바른 이메일을 입력하세요.</div>
			            </td>
			          </tr>
			          <tr>
			            <th class="text-center">서명</th>
			            <td>
			            	<c:choose>
						        <c:when test="${myInfo.sign == null}">
						          <canvas id="signCanvas" width="400" height="200" style="border:1px solid #ccc;"></canvas>
						          <div class="mt-2 d-flex gap-2 justify-content-end">
						            <button type="button" id="btnClear" class="btn btn-outline-secondary btn-sm">삭제</button>
						            <button type="button" id="btnSign" class="btn btn-outline-success btn-sm">등록</button>
						          </div>
						          <input type="hidden" id="signImg" name="signImg">
						        </c:when>
						        <c:otherwise>
						          <img src="/final/${myInfo.sign}" alt="서명 이미지"  width="300" height="150">
						        </c:otherwise>
					      	</c:choose>
			            </td>
			          </tr>
			        </table>
			        <div class="d-flex justify-content-end gap-2">
			          <!-- 서명이 등록되어 있을때만 표시 -->
			          <c:choose>
			          	<c:when test="${myInfo.sign != null}">
			          		<button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#sign-modal">서명 변경</button>
			          	</c:when>
			          	<c:otherwise>
			          	</c:otherwise>
			          </c:choose>
			          <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#pw-modal">비밀번호 변경</button>
			          <button type="submit" id="btn" class="btn btn-outline-primary">수정</button>
			        </div>
			      </form>
			    </div>
			  </div>
			</div>
		<!--비밀번호 변경 모달 -->
		<div class="modal fade" id="pw-modal" tabindex="-1" aria-hidden="true">
		  <div class="modal-dialog modal-dialog-centered">
		    <div class="modal-content">
		      
		      <div class="modal-header py-3 px-4 border-bottom-0">
		        <h5 class="modal-title">비밀번호 변경</h5>
		        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
		      </div>
		      
		      <div class="modal-body">
		      		<form class="needs-validation" id="changePwForm" novalidate>
		      			<div class="row">
		      				<div class="col-12">
                   				<div class="mb-3">
                   					<label class="form-label">기존 비밀번호</label>
                   					<input class="form-control" type="password" name="prevPw" id="prevPw" placeholder="기존 비밀번호" required/>
                                    <div class="invalid-feedback">기존 비밀번호를 입력하세요.</div>
                   				</div>
                   			</div>
                   			<div class="col-12">
                   				<div class="mb-3">
                   					<label class="form-label">새로운 비밀번호</label>
                   					<input class="form-control" type="password" name="newPw" id="newPw" placeholder="새로운 비밀번호" required/>
                                    <div class="invalid-feedback">새로운 비밀번호를 입력하세요.</div>
                   				</div>
                   			</div>
                   			<div class="col-12">
                   				<div class="mb-3">
                   					<label class="form-label">비밀번호 확인</label>
                   					<input class="form-control" type="password" name="newPw2" id="newPw2" placeholder="비밀번호 확인" required/>
                                    <div class="invalid-feedback">비밀번호를 한번 더 입력하세요.</div>
                   				</div>
                   			</div>
		      			</div>
						<div style="background-color: #f8f9fa; padding: 10px 15px; font-size: 0.85rem; color: #555; border-top: 1px solid #dee2e6; border-bottom: 1px solid #dee2e6;">
						    <ul style="margin: 0; padding-left: 20px;">
						        <li>기존 및 직전 비밀번호는 사용할 수 없습니다.</li>
						        <li>비밀번호는 8~13자이며, 숫자·문자·특수문자를 포함해야 합니다.</li>
						    </ul>
						</div>
		      			<div class="modal-footer">
					        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
					        <button type="submit" class="btn btn-outline-success">수정</button>
				      	</div>
		      		</form>
		      </div>
		    </div>
		  </div>
		</div>
		  <!--서명 변경 모달 -->
	      <div class="modal fade" id="sign-modal" tabindex="-1" aria-hidden="true">
			  <div class="modal-dialog modal-dialog-centered">
			    <div class="modal-content">
			      
			      <div class="modal-header py-3 px-4 border-bottom-0">
			        <h5 class="modal-title">서명 변경</h5>
			        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			      </div>
			      <div class="modal-body">
					<form class="needs-validation" id="changeSignForm" novalidate>
			      			<div class="row">
                   					<label class="form-label">서명</label>
			      					<canvas id="updateSignCanvas" width="400px" height="200px" style="border:1px solid #ccc; margin:10px auto;"></canvas>
							        <div class="mt-2 d-flex gap-2">
							            <button type="button" id="updateBtnClear" class="btn btn-outline-secondary btn-sm">삭제</button>
							        </div>
				      		</div>
				      		<div class="modal-footer">
						        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
						        <button type="submit" class="btn btn-outline-success">수정</button>
					      	</div>
				      </form>
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
				Swal.fire({
                    title: "서명을 해주세요.",
                    icon: "error",
					confirmButtonText: "확인",
					confirmButtonColor: "#34c38f"
                });
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
	
	// 프로필사진 등록, 수정
	const profileImg = document.getElementById("profileImg");
	const fileInput = document.getElementById("fileInput");

	profileImg.addEventListener("click", () => fileInput.click());

	fileInput.addEventListener("change", function() {
	    if (this.files && this.files[0]) {
	        const reader = new FileReader();
	        reader.onload = function(e) {
	            profileImg.src = e.target.result; // 선택 즉시 미리보기
	        }
	        reader.readAsDataURL(this.files[0]);
	        
	        // 선택 즉시 서버 업로드
	        document.getElementById("uploadForm").submit();
	    }
	});
	
	// 비밀번호 변경
	const pwForm = document.getElementById("changePwForm");
	pwForm.addEventListener("submit", function(e){
		// 유효성검사에 걸리면 실행되지 않는다
		e.preventDefault();
	    if(!pwForm.checkValidity()){
	        e.stopPropagation();
	        pwForm.classList.add("was-validated");
	        return;
	    }
		const userId = document.getElementById("userId").value;
		const prevPw = document.getElementById("prevPw").value;
		const newPw = document.getElementById("newPw").value;
		const newPw2 = document.getElementById("newPw2").value;
		
		fetch("/updatePassword", {
	        method: "PATCH",
	        headers: {"Content-Type":"application/json"},
	        body: JSON.stringify({userId:userId,prevPw:prevPw,newPw:newPw,newPw2:newPw2})
	    }).then(res => res.text())   // 문자열 응답 받기
	    .then(msg => {
	        if (msg === "변경성공") {
	            Swal.fire({
	                title: "수정되었습니다.",
	                icon: "success",
	                confirmButtonText: "확인",
	                confirmButtonColor: "#34c38f"
	            }).then((result)=>{ 
	                if(result.isConfirmed){
	                    location.href='/logout';
	                }
	            });
	        } else {
	            Swal.fire({
	                title: msg,  // 실패 사유에따라 메세지 출력
	                icon: "error",
	                confirmButtonText: "확인",
	                confirmButtonColor: "#34c38f"
	            });
	        }
	    })
	    .catch(err => {
	        console.error(err);
	        Swal.fire({
	            title: "오류가 발생했습니다.",
	            icon: "error",
	            confirmButtonText: "확인",
	            confirmButtonColor: "#34c38f"
	        });
	    });
	});
	
	var updateCanvas = document.getElementById("updateSignCanvas");
	
	
	if(updateCanvas){
		const signaturePad = new SignaturePad($('canvas')[0], {
			  minWidth: 2,
		    maxWidth: 2,
		    penColor: 'rgb(0, 0, 0)'
		});
		
		// 캔버스 내용 초기화하는 clear()메소드
		$('#updateBtnClear').click(function(){
			signaturePad.clear();
		});
		
		const signForm = document.getElementById("changeSignForm");
		
		signForm.addEventListener("submit", function(e){
			e.preventDefault();  // 바로 제출막고 확인 누르면 제출
			if(signaturePad.isEmpty()){
				e.stopPropagation();
				Swal.fire({
                    title: "서명을 해주세요.",
                    icon: "error",
					confirmButtonText: "확인",
					confirmButtonColor: "#34c38f"
                });
			}else{

			const userId = document.getElementById("userId").value;
			
			fetch("/updateSign", {
		        method: "PATCH",
		        headers: {"Content-Type":"application/json"},
		        body: JSON.stringify({userId:userId,userImagesName: signaturePad.toDataURL()})
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
			}
		});
	}
</script>
</body>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/pages/form-validation.init.js"></script>
</html>