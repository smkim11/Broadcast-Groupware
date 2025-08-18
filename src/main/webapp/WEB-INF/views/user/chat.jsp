<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
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
                                <li class="breadcrumb-item"><a href="javascript: void(0);">Apps</a></li>
                                <li class="breadcrumb-item active">Chat</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            <!-- end page title -->

            <div class="d-lg-flex mb-4">
                <!-- Sidebar -->
                <div class="chat-leftsidebar card">
                    <div class="p-3 px-4">
                        <div class="d-flex align-items-start">
                            <div class="flex-shrink-0 me-3 align-self-center">
                                <img src="assets/images/users/avatar-4.jpg" class="avatar-xs rounded-circle" alt="">
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
                                    <a href="javascript:void(0);" class="text-primary"><i class="mdi mdi-plus"></i> New Group</a>
                                </div>
                                <h5 class="font-size-16 mb-3"><i class="uil uil-users-alt me-1"></i> Groups</h5>
                                <ul class="list-unstyled chat-list group-list">
                                    <li class="active">
                                        <a href="#">
                                            <div class="d-flex align-items-center">
                                                <div class="flex-shrink-0 me-3">
                                                    <div class="avatar-xs">
                                                        <span class="avatar-title rounded-circle bg-primary-subtle text-primary">
                                                            G
                                                        </span>
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

                            <!-- 연락처 리스트 -->
                            <div class="p-4 border-top">
                                <div class="float-end">
                                    <a href="javascript:void(0);" class="text-primary"><i class="mdi mdi-plus"></i> New Contact</a>
                                </div>
                                <h5 class="font-size-16 mb-3"><i class="uil uil-user me-1"></i> Contacts</h5>
                                <ul class="list-unstyled chat-list">
                                    <!-- 추후 동적 렌더링 -->
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- end chat-leftsidebar -->

                <!-- Chat 영역 -->
                <div class="w-100 user-chat mt-4 mt-sm-0 ms-lg-1">
                    <div class="card">
                        <!-- 채팅방 헤더 -->
                        <div class="p-3 px-lg-4 border-bottom">
                            <div class="row">
                                <div class="col-md-6 col-6">
                                    <h5 class="font-size-16 mb-1 text-truncate">
                                        <a href="#" class="text-reset">Chat Room</a>
                                    </h5>
                                </div>
                                <div class="col-md-6 col-6 text-end">
                                    <!-- 옵션 메뉴 -->
                                    <button class="btn nav-btn dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                        <i class="uil uil-ellipsis-h"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- 채팅 메시지 영역 -->
                        <div>
                            <div class="chat-conversation py-3">
                                <ul class="list-unstyled mb-0 chat-conversation-message px-3" data-simplebar id="chat-messages">
                                    <!-- 실제 메시지가 append 되는 영역 -->
                                </ul>
                            </div>
                        </div>

                        <!-- 메시지 입력창 -->
                        <div class="p-3 chat-input-section">
                            <div class="row">
                                <div class="col">
                                    <div class="position-relative">
                                        <input type="text" class="form-control chat-input rounded" id="chat-input" placeholder="Enter Message...">
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <button type="button" id="send-btn" class="btn btn-primary chat-send w-md">
                                        <span class="d-none d-sm-inline-block me-2">Send</span> 
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

<script>
    let stompClient = null;
    let currentUserId = "Marcus"; // 로그인 유저 (추후 세션값 사용 가능)

    function connect() {
        const socket = new SockJS("/ws-stomp");
        stompClient = Stomp.over(socket);

        stompClient.connect({}, function () {
            console.log("Connected");

            // 구독
            stompClient.subscribe("/topic/public", function (msg) {
                const chat = JSON.parse(msg.body);

                if (String(chat.chatroomUserId).trim() === String(currentUserId).trim()) {
                    return; // 내가 보낸 건 무시
                }
                showMessage({ sender: chat.chatroomUserId, content: chat.chatMessageContent }, false);
            });
        });
    }

    function sendMessage() {
        const content = document.getElementById("chat-input").value.trim();
        if (!content) return;

        const chatObj = {
            chatroomUserId: currentUserId,
            chatMessageContent: content,
            chatMessageStatus: "SENT"
        };

        stompClient.send("/app/chat.send", {}, JSON.stringify(chatObj));
        showMessage({ sender: currentUserId, content: content }, true);

        document.getElementById("chat-input").value = "";
    }

    function showMessage(message, isMine = false) {
        const box = document.getElementById("chat-messages"); // 수정됨

        const li = document.createElement("li");
        li.classList.add(isMine ? "right" : "left");

        li.innerHTML = `
            <div class="conversation-list">
                <div class="ctext-wrap">
                    <div class="ctext-wrap-content">
                        <h5 class="font-size-14 conversation-name">
                            <a href="#" class="text-reset">${message.sender}</a>
                            <span class="d-inline-block font-size-12 text-muted ms-2">
                                \${new Date().toLocaleTimeString([], {hour:"2-digit", minute:"2-digit"})}
                            </span>
                        </h5>
                        <p class="mb-0">${message.content}</p>
                    </div>
                </div>
            </div>
        `;

        box.appendChild(li);
        box.scrollTop = box.scrollHeight;
    }

    // 버튼 이벤트 연결
    document.addEventListener("DOMContentLoaded", () => {
        connect();
        document.getElementById("send-btn").addEventListener("click", sendMessage);

        // 엔터키로 전송
        document.getElementById("chat-input").addEventListener("keypress", (e) => {
            if (e.key === "Enter") {
                sendMessage();
            }
        });
    });
</script>

<div><jsp:include page ="../nav/footer.jsp"></jsp:include></div>
<div><jsp:include page ="../nav/javascript.jsp"></jsp:include></div>
</body>
</html>
