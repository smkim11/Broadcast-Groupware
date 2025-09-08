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


</head>

    <body class="authentication-bg">
        <div class="account-pages my-5 pt-sm-5">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="text-center">
                            <a href="/login" class="mb-3 d-block auth-logo">
                                <img src="${pageContext.request.contextPath}/resources/images/logo-back.png" alt="" height="50" class="logo logo-dark">
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
                                   <form id="loginForm" action="/login" method="post" novalidate>
									  <div class="mb-3">
									    <label class="form-label" for="username">사원번호</label>
									    <input type="text" class="form-control" id="username" name="username"
									           placeholder="사원번호 입력" autocomplete="username" inputmode="numeric">
									    <div class="invalid-feedback" id="usernameHelp">사원번호를 입력하세요.</div>
									  </div>
									
									  <div class="mb-3">
									    <div class="float-end">
									      <a class="text-muted" href="#" data-bs-toggle="modal" data-bs-target="#findPasswordModal">비밀번호 찾기</a>
									    </div>
									    <label class="form-label" for="password">비밀번호</label>
									    <input type="password" class="form-control" id="password" name="password"
									           placeholder="비밀번호 입력" autocomplete="current-password">
									    <div class="invalid-feedback" id="passwordHelp">비밀번호를 입력하세요.</div>
									  </div>
									
									  <div class="mt-3 text-center">
									    <button class="btn btn-outline-primary w-sm" type="submit">로그인</button>
									  </div>
									</form>
                                </div>
            
                            </div>
                        </div>
	                            관리자 - 210304 / 1234<br>
								국장   - 210501 / 1234<br>
								부서장	- 210201 / 1234<br>
								팀장	 	- 220207 / 1234<br>
								사원 		- 220202 / 1234
                        <div class="mt-2 text-center">
                            <p>© <script>document.write(new Date().getFullYear())</script> 김성민 김예진 장정수 장지영 <i class="mdi mdi-star text-danger"></i> by 맛있는 김장김장</p>
                        </div>

                    </div>
                </div>
                <!-- end row -->
            </div>
            <!-- end container -->
        </div>
        
        <!-- 로그인 실패 모달 -->
		<div class="modal fade" id="loginErrorModal" tabindex="-1" aria-hidden="true">
		  <div class="modal-dialog modal-dialog-centered">
		    <div class="modal-content">
		      <div class="modal-header">
		        <h5 class="modal-title">로그인 실패</h5>
		        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
		      </div>
		      <div class="modal-body">
		        <p id="loginErrorText" class="mb-0">사원번호 또는 비밀번호가 일치하지 않습니다.</p>
		      </div>
		      <div class="modal-footer">
		        <button type="button" class="btn btn-primary" data-bs-dismiss="modal">확인</button>
		      </div>
		    </div>
		  </div>
		</div>
        
      <!-- 비밀번호 찾기 모달 -->
		<div class="modal fade" id="findPasswordModal" tabindex="-1" aria-hidden="true">
		  <div class="modal-dialog modal-dialog-centered">
		    <div class="modal-content">
		
		      <div class="modal-header">
		        <h5 class="modal-title">비밀번호 찾기</h5>
		        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
		      </div>
		
				<form id="findPassword" class="findForm">
				  <div class="modal-body">
				
				    <div class="mb-3 text-start">
				      <label class="form-label">사원번호</label>
				      <input type="text" class="form-control username" name="username" placeholder="사원번호를 입력하세요.">
				      <div class="invalid-feedback">사원번호를 입력하세요.</div>
				    </div>
				
				    <div class="mb-3 text-start">
				      <label class="form-label">생년월일</label>
				      <input type="text" class="form-control userSn1" name="userSn1" placeholder="ex) 990705">
				      <div class="invalid-feedback">생년월일을 6자리 숫자로 입력하세요. (예: 990705)</div>
				    </div>
				
				  </div>
				  <div class="modal-footer">
				    <button type="button"
				            class="btn btn-outline-secondary btn-sm"
				            data-bs-dismiss="modal">닫기</button>
				    <button type="submit"
				            class="btn btn-outline-success btn-sm">확인</button>
				  </div>
				</form>
		
		    </div>
		  </div>
		</div>
<script src="${pageContext.request.contextPath}/resources/libs/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>
<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>
<script>
// 로그인 페이지
$(function(){
	  const $u  = $('#username');
	  const $p  = $('#password');

	  // 에러 표시/해제 유틸
	  function showErr($el, msg){
	    $el.addClass('is-invalid');
	    $el.next('.invalid-feedback').text(msg).show();
	  }
	  function clearErr($el){
	    $el.removeClass('is-invalid');
	    $el.next('.invalid-feedback').hide();
	  }

	  // 단일 필드 검사
	  function validateUsername(){
	    const v = ($u.val() || '').trim();
	    clearErr($u);
	    if(!v){ showErr($u, '사원번호를 입력하세요.'); return false; }
	    if(!/^\d+$/.test(v)){ showErr($u, '사원번호는 숫자만 입력하세요.'); return false; }
	    // 길이 제한이 있다면 여기서 추가(예: if(v.length !== 6) {...})
	    return true;
	  }
	  function validatePassword(){
	    const v = ($p.val() || '').trim();
	    clearErr($p);
	    if(!v){ showErr($p, '비밀번호를 입력하세요.'); return false; }
	    // 규칙을 더 원하면 여기 추가(최소 길이 등)
	    return true;
	  }

	  // blur 시 즉시 검사
	  $u.on('blur', validateUsername);
	  $p.on('blur', validatePassword);

	  // 타이핑 중 오류 해제
	  $u.on('input', () => clearErr($u));
	  $p.on('input', () => clearErr($p));

	  // 제출 시 전체 검사 → 실패하면 제출 막고 첫 에러로 포커스
	  $('#loginForm').on('submit', function(e){
	    const okU = validateUsername();
	    const okP = validatePassword();
	    if(!(okU && okP)){
	      e.preventDefault();
	      $('.is-invalid:first').trigger('focus');
	    }
	  });

	  // 페이지 로드 시 값이 미리 채워져 있으면 경고 숨김
	  if(($u.val()||'').trim()) clearErr($u);
	  if(($p.val()||'').trim()) clearErr($p);
	});
	
	const qp = new URLSearchParams(location.search);
	if (qp.has('error')) {
	  const msg = qp.get('msg')
	    ? decodeURIComponent(qp.get('msg'))
	    : '사원번호 또는 비밀번호가 일치하지 않습니다.';
	
	  Swal.fire({
	    icon: 'error',
	    title: '로그인 실패',
	    text: msg,
	    confirmButtonText: '확인',
	    confirmButtonColor: '#556ee6' // 테마 색(원하면 변경)
	  }).then(() => {
	    // 주소창에서 ?error 파라미터 제거(새로고침해도 다시 안 뜨게)
	    const url = new URL(location.href);
	    url.searchParams.delete('error');
	    url.searchParams.delete('msg');
	    history.replaceState(null, '', url);
	  });
	}

// 비밀번호 찾기
$(function(){
  const CSRF_TOKEN  = $('meta[name="_csrf"]').attr('content')  || '';
  const CSRF_HEADER = $('meta[name="_csrf_header"]').attr('content') || 'X-CSRF-TOKEN';

  // 부트스트랩 모달 인스턴스(성공 시 닫기)
  const modalEl = document.getElementById('findPasswordModal');
  let modal = null;
  try {
    modal = bootstrap.Modal.getOrCreateInstance(modalEl);
  } catch (e) {
    console.warn('bootstrap 모달 인스턴스 생성 실패:', e);
  }

  // SweetAlert 로드 확인
  console.log('Swal type =', typeof Swal); // 'function' 이어야 정상
  console.log('bootstrap type =', typeof bootstrap);

  // 폼 제출
  $(document).on('submit', '#findPassword', function(e){
    e.preventDefault();

    var usernameStr = ($('.username').val() || '').trim();
    var userSn1Str  = ($('.userSn1').val()  || '').trim();

    console.log('[findPassword submit] payload =', {username: usernameStr, userSn1: userSn1Str});

    if (!usernameStr || !userSn1Str){
      // 기본 유효성 (원하면 여기 SweetAlert 써도 됨)
      alert('사원번호/생년월일을 입력하세요.');
      return;
    }

    $.ajax({
      url: "/api/find/password",
      type: "POST",
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify({ username: usernameStr, userSn1: userSn1Str }),
      beforeSend: function(xhr){
        if (CSRF_TOKEN) xhr.setRequestHeader(CSRF_HEADER, CSRF_TOKEN);
      },
      success: function(res){
        console.log('[findPassword success] res =', res);

        // optional chaining 없이 안전비교
        var ok = res && res.status === 'success';

        if (ok) {
          if (typeof Swal === 'function') {
            Swal.fire({
              icon: 'success',
              title: '메일 발송',
              text: '임시 비밀번호를 발송했습니다.'
            }).then(function(){
              $('.username, .userSn1').val('');
              try { if (modal) modal.hide(); } catch(e){ console.warn('modal hide 실패', e); }
            });
          } else {
            alert('임시 비밀번호를 발송했습니다.');
            $('.username, .userSn1').val('');
            try { if (modal) modal.hide(); } catch(e){}
          }
        } else {
          var msg = (res && res.message) ? res.message : '사원번호/생년월일이 일치하지 않습니다.';
          if (typeof Swal === 'function') {
            Swal.fire({ icon: 'error', title: '확인', text: msg });
          } else {
            alert(msg);
          }
        }
      },
      error: function(xhr){
        console.log('[findPassword error] status=', xhr.status, 'response=', xhr.responseText);
        var msg = '요청 처리 중 오류가 발생했습니다.';
        try {
          var j = JSON.parse(xhr.responseText);
          if (j && j.message) msg = j.message;
        } catch(e){}
        if (typeof Swal === 'function') {
          Swal.fire({ icon: 'error', title: '오류', text: msg });
        } else {
          alert(msg);
        }
      }
    });
  });
});

</script>

</body>
</html>
