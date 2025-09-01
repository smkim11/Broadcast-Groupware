<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />

  <meta charset="UTF-8">
  <title>Chat</title>
  <style>
/* 템플릿에서 제공하는 에러메세지만 사용  */
.was-validated .form-control:valid,
.form-control.is-valid {
  border-color: #dee2e6 !important;
  background-image: none !important;
  box-shadow: none !important;
}
</style>
</head>
<body>

<div>
  <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
  <div class="page-content">
    <div class="container-fluid">

      <!-- start page title -->
      <div class="row">
        <div class="col-12">
          <div class="page-title-box d-flex align-items-center justify-content-between">
            <h4 class="mb-0">Chat</h4>
            <div class="page-title-right">
              <ol class="breadcrumb m-0">
                <li class="breadcrumb-item"><a href="javascript: void(0);">KOJ</a></li>
                <li class="breadcrumb-item active">Chat</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
      <!-- end page title -->

      <!-- 로그인/방 메타 (서버에서 내려주세요: loginUserId, loginUserName) -->
      <div id="chat-meta"
           data-room-id="${chatroomId}"
           data-user-id="${loginUserId}"
           data-user-name="${loginUserName}"
           data-user-rank="${loginUserRank}"
		   data-avatar-url="${loginUserAvatarUrl}"
		   data-avatar-version="${loginUserAvatarVersion}"
           data-context-path="${pageContext.request.contextPath}"
           data-avatar-default="<c:url value='/resources/images/users/avatar-default.png'/>">
      </div>

      <div class="d-lg-flex mb-4">
        <!-- Sidebar -->
        <div class="chat-leftsidebar card">
          <div class="p-3 px-4">
            <div class="d-flex align-items-start">
             <c:set var="loginAvatar" value="${empty loginUserAvatarUrl 
			  ? pageContext.request.contextPath.concat('/resources/images/users/avatar-default.png') 
			  : loginUserAvatarUrl}" />
			
			<div class="flex-shrink-0 me-3 align-self-center">
			  <img id="sidebar-login-avatar"
			       src="${loginAvatar}"
			       class="avatar-xs rounded-circle" alt="">
			</div>
			
			<div class="flex-grow-1">
			  <h5 class="font-size-16 mb-1">
			    <a href="#" class="text-reset">
			      <span id="sidebar-login-name">${loginUserName}</span>
					<span class="text-muted" id="sidebar-login-rank">
					  <c:if test="${not empty loginUserRank}">(${loginUserRank})</c:if>
					</span>
			      <i class="mdi mdi-circle text-success align-middle font-size-10 ms-1"></i>
			    </a>
			  </h5>
			</div>
                <div class="float-end">
                  <a href="javascript:void(0);" id="open-invite" class="text-primary"><i class="mdi mdi-plus"></i> 초대하기</a>
                </div>
            </div>
          </div>

          <!-- Search -->
          <div class="p-3">
            <div class="search-box chat-search-box">
              <div class="position-relative">
                <input type="text" class="form-control bg-light border-light rounded" placeholder="Search...">
                <i class="uil uil-search search-icon"></i>
              </div>
            </div>
          </div>

          <!-- Groups / Contacts -->
          <div class="pb-3">
            <div class="chat-message-list" data-simplebar>
              <!-- 그룹 리스트 -->
              <div class="p-4 border-top">
                <h5 class="font-size-16 mb-3"><i class="uil uil-users-alt me-1"></i> 그룹채팅</h5>
                <ul class="list-unstyled chat-list group-list">
                 <!-- 추후 동적 렌더링 -->
                </ul>
              </div>

              <!-- 1대1 리스트 -->
              <div class="p-4 border-top">
                <h5 class="font-size-16 mb-3"><i class="uil uil-user me-1"></i> 1:1채팅</h5>
                <ul class="list-unstyled chat-list">
                  <!-- 추후 동적 렌더링 -->
                </ul>
              </div>
            </div>
          </div>
        </div>
        <!-- end chat-leftsidebar -->

        <!-- Chat 영역 -->
        <!-- 빈 상태 화면 (처음엔 보이게) -->
		<div id="chat-empty" class="w-100 user-chat mt-4 mt-sm-0 ms-lg-1">
		    <div class="card-body d-flex align-items-center justify-content-center" style="height:65vh;">
		      <div class="text-center">
		        <div class="mb-2" style="font-size:42px;">💬</div>
		        <h5 class="mb-1">채팅방을 선택하세요</h5>
		        <p class="text-muted mb-0">왼쪽 목록에서 1:1 또는 그룹 채팅을 클릭하면 대화가 시작됩니다.</p>
		      </div>
		  </div>
		</div>
        <!-- 채팅화면 -->
        <div class="w-100 user-chat mt-4 mt-sm-0 ms-lg-1 d-none" id="chat-panel">
          <div class="card">
            <!-- 채팅방 헤더 -->
			 <div class="p-3 px-lg-4 border-bottom">
			  <div class="d-flex align-items-center justify-content-between">
			    <div class="d-flex align-items-center">
			      <!--  크기 고정 클래스 적용 -->
			      <img id="room-avatar"
			           src="<c:url value='/resources/images/users/avatar-default.png'/>"
			           class="rounded-circle header-profile-user"
			           alt="avatar">
			
			      <div class="ms-2 min-w-0">
			        <h5 id="room-title" class="font-size-16 mb-0 text-truncate"></h5>
			          <!-- 항상 보이게. DM이면 2 Member, 그룹이면 n Members -->
						  <a href="#" id="room-members-link" class="small text-muted">
						    <i class="uil uil-users-alt me-1"></i>
						    <span id="room-members-count">0</span>
						    <span id="room-members-word">Members</span>
						  </a>
			      </div>
			    </div>
			
			    <li class="list-inline-item">
                   <div class="dropdown">
                       <button class="btn nav-btn dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                           <i class="uil uil-ellipsis-h"></i>
                       </button>
                       <div class="dropdown-menu dropdown-menu-end">
                           <a class="dropdown-item" href="#" id="btn-pin=room">상단고정</a>
                           <a class="dropdown-item" href="#" id="action-rename-room">채팅방 이름 변경</a>
                           <a class="dropdown-item text-danger" href="#" id="action-leave-room">대화방 나가기</a>
                       </div>
                   </div>
               </li>
			  </div>
			</div>

          <!-- 채팅 메시지 영역 (SimpleBar 사용) -->
			<div class="chat-conversation py-3" id="messageScroll" data-simplebar style="height:65vh;">
			  <ul class="list-unstyled chat-conversation-list mb-0 px-3"
			      id="chat-messages"
			      role="log" aria-live="polite" aria-relevant="additions"></ul>
			  <div id="bottomAnchor"></div>
			</div>

            <!-- 입력창 -->
            <div class="p-3 chat-input-section">
              <div class="row">
                <div class="col">
                  <div class="position-relative">
                    <input type="text" class="form-control chat-input rounded" id="chat-input" placeholder="메시지 입력...">
                  </div>
                </div>
                <div class="col-auto">
                  <button type="button" id="send-btn" class="btn btn-primary chat-send w-md" disabled>
                    <span class="d-none d-sm-inline-block me-2">보내기</span>
                    <i class="mdi mdi-send float-end"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- end user-chat -->
      </div>
    </div>
  </div>
</div>

<!-- 조직도(초대) 모달 -->
<div class="modal fade" id="inviteModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">조직도</h5>
        <button class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>

      <!-- 선택된 사용자 미리보기 -->
      <div id="invite-selected" class="border rounded p-2 mb-2" style="min-height:42px;">
        <small class="text-muted">선택한 사용자가 여기에 표시됩니다.</small>
      </div>

      <div class="modal-body">
  <input id="inviteSearch" class="form-control mb-2" placeholder="이름/직급 검색">

  <ul class="list-unstyled mb-0" id="invite-modal-body">
    <c:forEach var="dept" items="${orgTree}">
      <li class="mb-2">
        <a class="text-decoration-none d-inline-flex align-items-center org-toggle"
           data-bs-toggle="collapse"
           href="#dept-${dept.id}"
           role="button"
           aria-expanded="true"
           aria-controls="dept-${dept.id}">
          <span class="me-1 caret" style="display:inline-block; transition:.2s transform;">▾</span>
          <i class="uil uil-building me-1"></i> ${dept.name}
        </a>

        <!-- 부서: 기본 접힘 -->
        <ul class="list-unstyled ms-3 mt-1 collapse" id="dept-${dept.id}">
          <c:if test="${not empty dept.users}">
            <c:forEach var="team" items="${dept.users}">
              <li class="mt-2">
                <a class="text-decoration-none d-inline-flex align-items-center org-toggle"
                   data-bs-toggle="collapse"
                   href="#team-${dept.id}-${team.id}"
                   role="button"
                   aria-expanded="false"
                   aria-controls="team-${dept.id}-${team.id}">
                  <span class="me-1 caret" style="display:inline-block; transition:.2s transform;">▸</span>
                  <i class="uil uil-sitemap me-1"></i> ${team.name}
                </a>

                <!-- 팀: 기본 접힘 -->
                <ul class="list-unstyled ms-3 mt-1 collapse" id="team-${dept.id}-${team.id}">
                  <!-- 팀 전체 체크(개인 비활성화 용 / 초대 대상 수집 안 함) -->
                  <li class="form-check mb-1">
                    <input class="form-check-input ref-chk team-chk"
                           type="checkbox"
                           id="t${team.id}"
                           data-team-id="${team.id}">
                    <label class="form-check-label" for="t${team.id}">
                      👥 팀 전체: ${team.name}
                    </label>
                  </li>

                  <!-- 팀 소속 사용자 -->
                  <c:forEach var="user" items="${team.users}">
                    <li class="form-check">
                      <input class="form-check-input ref-chk user-chk"
                             type="checkbox"
                             id="u${user.id}"
                             data-id="${user.id}"
                             data-name="${user.name}"
                             data-rank="${user.userRank}"
                             data-dept="${dept.name}"
                             data-team="${team.name}"
                             data-team-id="${team.id}">
                      <label class="form-check-label" for="u${user.id}">
                        👤 ${user.name} <span class="text-muted">(${user.userRank})</span>
                      </label>
                    </li>
                  </c:forEach>
                </ul>
              </li>
            </c:forEach>
          </c:if>
        </ul>
      </li>
    </c:forEach>
  </ul>
</div>

      <div class="modal-footer">
        <button class="btn btn-light" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-primary" id="invite-submit-btn">초대</button>
      </div>
    </div>
  </div>
</div>

<!-- 멤버 목록 모달 -->
<div class="modal fade" id="membersModal" tabindex="-1" aria-hidden="true"  data-bs-focus="false">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title mb-0">멤버</h5>
        <button class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body p-0">
        <ul id="membersList" class="list-group list-group-flush"></ul>
      </div>
       <div class="modal-footer">
        <button class="btn btn-light" data-bs-dismiss="modal">닫기</button>
        <button class="btn btn-primary" id="members-invite-btn">
          <i class="mdi mdi-plus me-1"></i> 초대하기
        </button>
      </div>
    </div>
  </div>
</div>


<div><jsp:include page ="../nav/footer.jsp"></jsp:include></div>
<div><jsp:include page ="../nav/javascript.jsp"></jsp:include></div>

<!-- jQuery / SockJS / STOMP / bootstrap 등 라이브러리 뒤에 -->
<script src="<c:url value='/resources/js/pages/chat.init.js'/>?v=1"></script>
<script src="<c:url value='/resources/js/pages/chat-org.init.js'/>?v=1"></script>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
</body>
</html>
