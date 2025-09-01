 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
 <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
 
 <nav>
 <!-- JAVASCRIPT -->
 <script src="${pageContext.request.contextPath}/resources/libs/jquery/jquery.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/bootstrap/js/bootstrap.bundle.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/metismenu/metisMenu.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/simplebar/simplebar.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/node-waves/waves.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/waypoints/lib/jquery.waypoints.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/jquery.counterup/jquery.counterup.min.js"></script>
  <!-- Session timeout js -->
<!-- 플러그인 본체: 로컬 파일 사용 -->
<script src="${pageContext.request.contextPath}/resources/libs/@curiosityx/bootstrap-session-timeout/index.js"></script>
<!-- SockJS -->
<script src="${pageContext.request.contextPath}/resources/libs/sockjs-client/sockjs.min.js"></script>

<!-- STOMP (구버전 글로벌 Stomp 또는 신버전 UMD 폴백) -->
<script src="${pageContext.request.contextPath}/resources/libs/stompjs/stomp.min.js"></script>

 <!-- App js -->
 <script src="${pageContext.request.contextPath}/resources/js/app.js"></script>
 
 <!-- myPage -->
 <script>
    $(document).ready(function () {
       
        const role = '<c:out value="${sessionScope.loginUser.role}" default=""/>';
        console.log("Session role:", role);

        $("#myPageBtn").click(function (e) {
            e.preventDefault();

            if (role === "admin") {
                window.location.href = "/myPage";
            } else if (role === "user") {
                window.location.href = "/myPage";
            } else {
                alert("권한이 없습니다.");
            }
        });
    });
    
</script>
 <c:if test="${not empty sessionScope.loginUser}">
<script>
  (function () {
    // 플러그인 로드 확인
      if (typeof $.sessionTimeout !== 'function') return;

  // 로그인 여부 (JSTL로 서버에서 true/false를 굽기)
  var loggedIn = ${empty sessionScope.loginUser ? 'false' : 'true'};

  // 현재 경로
  var path = location.pathname.replace('${pageContext.request.contextPath}', '');

  // 1) 미로그인 이면 실행하지 않음
  if (!loggedIn) return;

  // 2) 잠금/로그인 화면에서는 실행하지 않음
  if (/^\/(lock|login)(\/|$)/.test(path)) {
    console.log('skip session-timeout on', path);
    return;
  }
   
    // 한 번만 초기화
    $.sessionTimeout({
      // 유휴 시간: 테스트용으로 5초/10초 (실서비스는 25분/30분)
      warnAfter: 10 * 60 * 1000,	// 경고 띄우는 시점
      redirAfter: 15 * 60 * 1000,	// 시작후 총 경과시간

      // 경로들 꼭 실제 URL로
      redirUrl: "<c:url value='/lock?from=timeout'/>",
      logoutUrl: "<c:url value='/login'/>",
      keepAliveButton: "계속 사용",
      logoutButton: "로그아웃",

      // 서버 세션 keep-alive
      keepAlive: true,
      keepAliveUrl: "<c:url value='/session/ping'/>",
      keepAliveInterval: 1 * 60 * 1000,	// 아무것도 안하는 시간
      ajaxType: "GET",           // 1.2.x
      keepAliveMethod: "GET",    // 혹시 모를 호환성 대비(있어도 해롭지 않음)

      // 한글 UI
      title: "세션 만료 예정",
      message: "일정 시간 동안 활동이 없어 곧 화면이 잠깁니다. 계속 사용하시겠습니까?",
      redirMessage: "활동이 없어 화면이 잠겼습니다.",
      countdownMessage: "자동 잠금까지 {timer}초",
      countdownBar: true
    });

    // Bootstrap5 호환 (플러그인 버전에 따라 필요)
    $("#session-timeout-dialog [data-dismiss='modal']").attr("data-bs-dismiss", "modal");

    // 디버그: 모달 DOM 생성 여부 확인
    setTimeout(() => {
      console.log('timeout dialog exists?', !!document.getElementById('session-timeout-dialog'));
    }, 1000);
  })();
</script>
 </c:if>
</nav>