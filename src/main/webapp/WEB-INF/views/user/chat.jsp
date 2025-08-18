<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
<div>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>
            <!-- Start right Content here -->
<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- Page Title -->
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

            <div class="d-lg-flex mb-4">
                <!-- Left Sidebar -->
                <div class="chat-leftsidebar card">
                    <div class="p-3 px-4">
                        <div class="d-flex align-items-start">
                            <div class="flex-grow-1">
                                <h5 class="font-size-16 mb-1">
                                    <a href="#" class="text-reset ">사용자명</a>
                                </h5>
                                <p class="text-muted mb-0">상태</p>
                            </div>
                        </div>
                    </div>

                    <!-- 검색창 -->
                    <div class="p-3">
                        <div class="search-box chat-search-box">
                            <div class="position-relative">
                                <input type="text" class="form-control bg-light border-light rounded" placeholder="Search...">
                                <i class="uil uil-search search-icon"></i>
                            </div>
                        </div>
                    </div>

                    <!-- 그룹/컨택트 리스트 자리 (샘플 내용 제거) -->
                    <div class="pb-3">
                        <div class="chat-message-list" data-simplebar>
                            <div class="p-4 border-top">
                                <h5 class="font-size-16 mb-3"><i class="uil uil-users-alt me-1"></i> Groups</h5>
                                <ul class="list-unstyled chat-list group-list">
                                    <!-- 그룹 데이터 동적 출력 -->
                                </ul>
                            </div>

                            <div class="p-4 border-top">
                                <h5 class="font-size-16 mb-3"><i class="uil uil-user me-1"></i> Contacts</h5>
                                <ul class="list-unstyled chat-list">
                                    <!-- 연락처 데이터 동적 출력 -->
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- End chat-leftsidebar -->

                <!-- 채팅 영역 -->
                <div class="w-100 user-chat mt-4 mt-sm-0 ms-lg-1">
                 <input type="text" id="sender" placeholder="이름 입력" class="form-control mb-2">
                    <div class="card">
                        <div class="p-3 px-lg-4 border-bottom">
                            <div class="row">
                                <div class="col-md-4 col-6">
                                    <h5 class="font-size-16 mb-1 text-truncate">
                                        <a href="#" class="text-reset ">채팅방 이름</a>
                                    </h5>
                                    <p class="text-muted text-truncate mb-0">
                                        <i class="uil uil-users-alt me-1"></i> 인원수
                                    </p>
                                </div>
                            </div>
                        </div>

						<!-- 채팅 카드 -->
						<div class="chat-card">
						    <!-- 대화 내용 영역 -->
						    <div class="chat-conversation">
						        <ul class="list-unstyled mb-0 chat-conversation-message px-3" data-simplebar id="chatBox">
						            <!-- 메시지가 여기에 append 됨 -->
						        </ul>
						    </div>
						
						    <!-- 메시지 입력 -->
						    <div class="p-3 chat-input-section">
						        <div class="row">
						            <div class="col">
						                <div class="position-relative">
						                    <input type="text" id="content" class="form-control chat-input rounded"
						                           placeholder="Enter Message...">
						                </div>
						            </div>
						            <div class="col-auto">
						                <button type="button" class="btn btn-primary chat-send w-md waves-effect waves-light"
						                        onclick="sendMessage()">
						                    <span class="d-none d-sm-inline-block me-2">보내기</span>
						                    <i class="mdi mdi-send float-end"></i>
						                </button>
						            </div>
						        </div>
						    </div>
						</div>
                    </div>
                </div>
                <!-- End user-chat -->
            </div>
        </div>
    </div>
</div>

<script>
    let stompClient = null;
    let currentUserId = null; // 사용자 ID 저장 변수 추가

    function connect() {
        const socket = new SockJS("/ws-stomp");
        stompClient = Stomp.over(socket);

        stompClient.connect({}, function () {
            console.log("Connected");

            // 구독 메시지
            stompClient.subscribe("/topic/public", function (msg) {
                const chat = JSON.parse(msg.body);

                // 내가 보낸 메시지는 이미 추가했으니 무시
                if (String(chat.chatroomUserId).trim() === String(currentUserId).trim()) {
				    return;
				}

                showMessage(
                    { sender: chat.chatroomUserId, content: chat.chatMessageContent },
                    false
                );
            });
        });
    }

    function sendMessage() {
        const sender = document.getElementById("sender").value.trim();
        const content = document.getElementById("content").value.trim();

        if (!sender || !content) {
            alert("이름과 메시지를 입력하세요.");
            return;
        }

        // 현재 로그인 사용자 ID 저장
        currentUserId = sender;

        const chatObj = {
            chatroomUserId: sender,
            chatMessageContent: content,
            chatMessageStatus: "SENT"
        };

        // 서버로 전송
        stompClient.send("/app/chat.send", {}, JSON.stringify(chatObj));

        // 내가 보낸 것도 바로 추가
        showMessage({ sender: sender, content: content }, true);

        document.getElementById("content").value = "";
    }

    // 메시지 출력 함수
    function showMessage(message, isMine = false) {
        const box = document.getElementById("chatBox"); // ← id로 직접 선택

        const li = document.createElement("li");
        if (isMine) {
            li.classList.add("right"); // 내가 보낸 거면 오른쪽
        } else {
            li.classList.add("left");  // 남이 보낸 거면 왼쪽
        }

        // 템플릿 (JSP 충돌 방지 → JS 문자열 연결)
        li.innerHTML =
            '<div class="conversation-list">' +
                '<div class="ctext-wrap">' +
                    '<div class="ctext-wrap-content">' +
                        '<h5 class="font-size-14 conversation-name">' +
                            '<a href="#" class="text-reset ">' + message.sender + '</a>' +
                            '<span class="d-inline-block font-size-12 text-muted ms-2">' +
                                new Date().toLocaleTimeString([], {hour:"2-digit", minute:"2-digit"}) +
                            '</span>' +
                        '</h5>' +
                        '<p class="mb-0">' + message.content + '</p>' +
                    '</div>' +
                '</div>' +
            '</div>';


        box.appendChild(li);
        box.scrollTop = box.scrollHeight;
    }

    // 페이지 로드 시 WebSocket 연결 실행
    window.onload = connect;
</script>

<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
</body>
</html>
