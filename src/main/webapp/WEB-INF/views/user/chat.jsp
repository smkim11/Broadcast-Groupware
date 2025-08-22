<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Chat</title>
</head>
<body>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>

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
           data-room-id="<c:out value='${chatroomId}' default='1'/>"
           data-user-id="<c:out value='${loginUserId}' default='0'/>"
           data-user-name="<c:out value='${loginUserName}' default=''/>">
      </div>

      <div class="d-lg-flex mb-4">
        <!-- Sidebar -->
        <div class="chat-leftsidebar card">
          <div class="p-3 px-4">
            <div class="d-flex align-items-start">
              <div class="flex-shrink-0 me-3 align-self-center">
                <img src="<c:url value='/resources/images/users/avatar-default.png'/>"
                     class="avatar-xs rounded-circle" alt="">
              </div>
              <div class="flex-grow-1">
                <h5 class="font-size-16 mb-1">
                  <a href="#" class="text-reset ">
                    Marcus
                    <i class="mdi mdi-circle text-success align-middle font-size-10 ms-1"></i>
                  </a>
                </h5>
                <p class="text-muted mb-0">Available</p>
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
                <div class="float-end">
                  <a href="javascript:void(0);" id="open-invite" class="text-primary"><i class="mdi mdi-plus"></i> 초대하기</a>
                </div>
                <h5 class="font-size-16 mb-3"><i class="uil uil-users-alt me-1"></i> 그룹채팅</h5>
                <ul class="list-unstyled chat-list group-list">
                  <li class="active">
                    <a href="#">
                      <div class="d-flex align-items-center">
                        <div class="flex-shrink-0 me-3">
                          <div class="avatar-xs">
                            <span class="avatar-title rounded-circle bg-primary-subtle text-primary">G</span>
                          </div>
                        </div>
                        <div class="flex-grow-1">
                          <h5 class="font-size-14 mb-0">General</h5>
                        </div>
                      </div>
                    </a>
                  </li>
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
        <div class="w-100 user-chat mt-4 mt-sm-0 ms-lg-1" id="chat-panel">
          <div class="card">
            <!-- 채팅방 헤더 -->
            <div class="p-3 px-lg-4 border-bottom">
              <div class="row">
                <div class="col-md-6 col-6">
                  <h5 class="font-size-16 mb-1 text-truncate">
                    <a href="#" class="text-reset">채팅방</a>
                  </h5>
                  <small id="ws-status" class="text-muted">연결 시도중...</small>
                </div>
                <div class="col-md-6 col-6 text-end">
                  <button class="btn nav-btn dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <i class="uil uil-ellipsis-h"></i>
                  </button>
                </div>
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
        <ul id="invite-modal-body" class="list-unstyled mb-0"></ul>
      </div>

      <div class="modal-footer">
        <button class="btn btn-light" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-primary" id="invite-submit-btn">초대</button>
      </div>
    </div>
  </div>
</div>



<div><jsp:include page ="../nav/footer.jsp"></jsp:include></div>
<div><jsp:include page ="../nav/javascript.jsp"></jsp:include></div>

<!-- jQuery / SockJS / STOMP / bootstrap 등 라이브러리 뒤에 -->
<script src="<c:url value='/resources/js/pages/chat.init.js'/>?v=1"></script>
<script src="<c:url value='/resources/js/pages/chat-org.init.js'/>?v=1"></script>
</body>
</html>
