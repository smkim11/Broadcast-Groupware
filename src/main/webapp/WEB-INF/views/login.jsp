<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <meta charset="UTF-8">
         <title>Broadcast Login</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="Premium Multipurpose Admin & Dashboard Template" name="description" />
        <meta content="Themesbrand" name="author" />
        <!-- App favicon -->
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/resources/images/favicon.ico">

        <!-- Bootstrap Css -->
        <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" id="bootstrap-style" rel="stylesheet" type="text/css" />
        <!-- Icons Css -->
        <link href="${pageContext.request.contextPath}/resources/css/icons.min.css" rel="stylesheet" type="text/css" />
        <!-- App Css-->
        <link href="${pageContext.request.contextPath}/resources/css/app.min.css" id="app-style" rel="stylesheet" type="text/css" />

<style type="text/css">
	/* 모달 전체 배경 */
#findPasswordModal {
	position: fixed;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
	background-color: rgba(0, 0, 0, 0.6); /* 반투명 검정 */
	display: none; /* 기본은 숨김 */
	z-index: 1000;
	justify-content: center; /* 수평 중앙 정렬 */
	align-items: center; /* 수직 중앙 정렬 */
}

/* 모달 컨테이너 */
#findPasswordModal .modal-contain {
	background-color: #fff;
	padding: 30px 40px;
	border-radius: 10px;
	width: 400px;
	box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
	position: relative;
	text-align: center;
}

/* 제목 */
#findPasswordModal h3 {
	margin-bottom: 20px;
	font-size: 22px;
	color: blue;
}

/* 라벨 */
#findPasswordModal span {
	display: block;
	text-align: left;
	margin-bottom: 5px;
	font-size: 14px;
	color: #555;
}

/* 입력 */
#findPasswordModal input[type="text"] {
	width: 100%;
	padding: 10px;
	margin-bottom: 15px;
	border: 1px solid #ccc;
	border-radius: 5px;
	font-size: 14px;
	box-sizing: border-box;
}

/* 버튼 공통 스타일 */
#findPasswordModal button {
	padding: 10px 20px;
	border-radius: 5px;
	border: none;
	cursor: pointer;
	font-size: 14px;
	transition: background-color 0.3s;
	margin: 5px;
}

/* 닫기 버튼 */
#findPasswordModal button.cancel {
	background-color: green;
	color: #fff;
}

#findPasswordModal button.cancel:hover {
	background-color: green;
}

/* 찾기 버튼 */
#findPasswordModal button[type="submit"] {
	background-color: green;
	color: #fff;
}

#findPasswordModal button[type="submit"]:hover {
	background-color: #0056b3;
}
	
</style>

</head>

    <body class="authentication-bg">
        <div class="account-pages my-5 pt-sm-5">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="text-center">
                            <a href="/login" class="mb-5 d-block auth-logo">
                                <img src="${pageContext.request.contextPath}/resources/images/logo-dark.png" alt="" height="22" class="logo logo-dark">
                                <img src="${pageContext.request.contextPath}/resources/images/logo-light.png" alt="" height="22" class="logo logo-light">
                            </a>
                        </div>
                    </div>
                </div>
                <div class="row align-items-center justify-content-center">
                    <div class="col-md-8 col-lg-6 col-xl-5">
                        <div class="card">
                           
                            <div class="card-body p-4"> 
                                <div class="text-center mt-2">
                                    <h5 class="text-primary">환영합니다.</h5>
                                    <p class="text-muted">로그인</p>
                                </div>
                                <div class="p-2 mt-4">
                                    <form action="/login" method="post">
        
                                        <div class="mb-3">
                                            <label class="form-label" for="username">사원번호</label>
                                            <input type="text" class="form-control" id="username" name="username" placeholder="사원번호 입력" required>
                                        </div>
                
                                        <div class="mb-3">
                                            <div class="float-end">
                                                <a id="find" class="text-muted">비밀번호 찾기</a>
                                            </div>
                                            <label class="form-label" for="password">비밀번호</label>
                                            <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호 입력" required>
                                        </div>
                
                                        <div class="mt-3 text-center">
                                            <button class="btn btn-primary w-sm waves-effect waves-light" type="submit">로그인</button>
                                        </div>
            
                                    </form>
                                </div>
            
                            </div>
                        </div>
	                            관리자아이디: ex)admin<br>
	                            유저아이디: ex)user
                        <div class="mt-2 text-center">
                            <p>© <script>document.write(new Date().getFullYear())</script> 김성민 김예진 장정수 장지영 <i class="mdi mdi-star text-danger"></i> by 맛있는 김장김장</p>
                        </div>

                    </div>
                </div>
                <!-- end row -->
            </div>
            <!-- end container -->
        </div>
        
        <div id="findPasswordModal" class="modal">
        	<div class="modal-contain">
				<form id="findPassword" class="findForm">
	        		<h3>비밀번호 찾기</h3>
	        		
	        		<span>사원번호</span>
	        		<input type="text" class="username" name="username" placeholder="사원번호를 입력하세요.">
	        		<span>생년월일</span>
	        		<input type="text" class="userSn1" name="userSn1" placeholder="ex)990705">
	        		<button type="button" class="cancel">닫기</button>
	        		<button type="submit">찾기</button>
        		</form>
        	</div>
        </div>

<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>

<script type="text/javascript">
	$(document).ready(function() {
		$('#find').on('click', function() {
			$('#findPasswordModal').css('display', 'flex');
		});
		
		$('.cancel').on('click', function(){
			$('#findPasswordModal').hide();
			location.reload();
		});
		
	});
	
	$('#findPassword').on('submit', function(e) {
		e.preventDefault();

		var usernameStr = $('.username').val();
		var userSn1Str = $('.userSn1').val();
		
		if(usernameStr == '') {
			alert('사원번호를 입력하세요')
			return;
		} else if(userSn1Str == '') {
			alert('생년월일을 입력하세요')
			return;
		}

		// JSON 객체 생성
		var payload = { username: usernameStr, userSn1: userSn1Str };

		// 실제 보낼 JSON 문자열 확인
		console.log("보낼 JSON 문자열:", JSON.stringify(payload));

		$.ajax({
			url: "/api/find/password",
			type: "POST",
			contentType: "application/json",
			data: JSON.stringify(payload),
			beforeSend: function(xhr, settings) {
				console.log("AJAX 요청 전송 데이터:", settings.data);
			},
			success: function(res) {
				alert('임시 비밀번호 메일발송완료!');
				$('.username').val('');
				$('.userSn1').val('');
				$('#findPasswordModal').hide();
			},
			error: function(err) {
				console.error(err);
				alert('관리자에게 문의하세요.');
			}
		});

		
	});
</script>
</body>
</html>
