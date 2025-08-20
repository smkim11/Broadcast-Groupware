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
                 data-room-id="${empty chatroomId ? 1 : chatroomId}"
                 data-user-id="${empty loginUserId ? 0 : loginUserId}"
                 data-user-name="${empty loginUserName ? '' : loginUserName}">
            </div>

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

                            <!-- 1대1 리스트 -->
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
                <div class="w-100 user-chat mt-4 mt-sm-0 ms-lg-1"id="chat-panel">
                    <div class="card">
                        <!-- 채팅방 헤더 -->
                        <div class="p-3 px-lg-4 border-bottom">
                            <div class="row">
                                <div class="col-md-6 col-6">
                                    <h5 class="font-size-16 mb-1 text-truncate">
                                        <a href="#" class="text-reset">Chat Room</a>
                                    </h5>
                                    <!-- 연결 상태 표시 -->
                                    <small id="ws-status" class="text-muted">연결 시도중...</small>
                                </div>
                                <div class="col-md-6 col-6 text-end">
                                    <button class="btn nav-btn dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                        <i class="uil uil-ellipsis-h"></i>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- 채팅 메시지 영역 -->
                       <div class="chat-conversation py-3" data-simplebar style="height: 65vh;">
						  <ul class="list-unstyled chat-conversation-list mb-0 px-3" id="chat-messages"></ul>
						</div>

                        <!-- 입력창 -->
                        <div class="p-3 chat-input-section">
                            <div class="row">
                                <div class="col">
                                    <div class="position-relative">
                                        <input type="text" class="form-control chat-input rounded" id="chat-input" placeholder="Enter Message...">
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <button type="button" id="send-btn" class="btn btn-primary chat-send w-md" disabled>
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
  // =========================
  // 기본 셋업
  // =========================
  let stompClient = null;
  let lastMessageId = 0;
  let retry = 0;

  const $status  = document.getElementById('ws-status');
  const $sendBtn = document.getElementById('send-btn');
  const $input   = document.getElementById('chat-input');
  const $list    = document.getElementById('chat-messages');

  // 메타 읽기 (서버에서 주입)
  const meta        = document.getElementById('chat-meta').dataset;
  const chatroomId  = Number(meta.roomId || 1);
  const myUserId    = Number(meta.userId || 0);
  const myName      = meta.userName || 'Me';

  // 경로 빌더
  function topicRoom(id){ return '/topic/rooms/' + id; }
  function topicRead(id){ return '/topic/rooms/' + id + '/read'; }
  function appSend(id){ return `/app/rooms/${id}/send`; }
  function appRead(id){ return `/app/rooms/${id}/read`; }

  // CSRF 헤더(옵션)
  function getCsrfHeaders() {
    const tokenMeta = document.querySelector('meta[name="_csrf"]');
    const headerMeta = document.querySelector('meta[name="_csrf_header"]');
    if (tokenMeta && headerMeta) {
      return { [headerMeta.getAttribute('content')]: tokenMeta.getAttribute('content') };
    }
    return {};
  }
  
	//=========================
	//메시지 로드 (새로고침 시 DB에서 불러옴)
	//=========================
	function loadMessages(chatroomId) {
	 $.getJSON(`/api/rooms/${chatroomId}/messages?limit=50`, function(messages) {
	   $("#chat-messages").empty();   
	   messages.forEach(m => appendMessage(m));
	 });
	}

  // 서버 → 프런트 키 정규화
  function normalizeMessage(raw){
    return {
      messageId:    raw.messageId ?? raw.chatMessageId ?? raw.id ?? 0,
      content:      raw.content ?? raw.chatMessageContent ?? raw.message ?? '',
      createdAt:    raw.createdAt ?? raw.createDate ?? raw.created_at ?? '',
      senderUserId: raw.senderUserId ?? raw.userId ?? raw.senderId ?? raw.chatroomUserId ?? (raw.sender && raw.sender.userId) ?? 0,
      fullName:     raw.fullName ?? (raw.sender && raw.sender.fullName) ?? '',
      senderRank:   raw.senderRank ?? raw.userRank ?? (raw.sender && raw.sender.rank) ?? ''
    };
  }

  // 시간 포맷: 'yyyy-MM-dd HH:mm:ss' → 'HH:mm'
  function formatTime(s) {
    if (!s) return '';
    const hhmm = (s.match(/\d{2}:\d{2}/) || [])[0];
    if (hhmm) return hhmm;
    const n = Number(s);
    if (!isNaN(n)) {
      const d = new Date(n);
      return String(d.getHours()).padStart(2,'0') + ':' + String(d.getMinutes()).padStart(2,'0');
    }
    return s;
  }

  // 날짜 구분선
  let lastDateLabel = '';
  function dateLabel(ts){
    if (!ts) return '';
    const d = ts.slice(0,10);
    const today = new Date().toISOString().slice(0,10);
    return (d === today) ? 'Today' : d;
  }
  function maybeAddDateSeparator(ts){
    const label = dateLabel(ts);
    if (label && label !== lastDateLabel) {
      lastDateLabel = label;
      const li = document.createElement('li');
      li.className = 'chat-day-title';
      const span = document.createElement('span');
      span.className = 'title';
      span.appendChild(document.createTextNode(label));
      li.appendChild(span);
      $list.appendChild(li);
    }
  }

  // =========================
  // 템플릿 스타일 말풍선 렌더
  // =========================
  function appendMessage(raw) {
    const msg = normalizeMessage(raw);

    if (typeof msg.messageId === 'number') {
      lastMessageId = Math.max(lastMessageId, msg.messageId);
    }

    maybeAddDateSeparator(msg.createdAt);

    const senderId = Number(
      msg.senderUserId ?? msg.userId ?? msg.chatroomUserId ?? (msg.sender && msg.sender.userId) ?? 0
    );
    const isMine = senderId === myUserId;

    const li = document.createElement('li');
    li.className = isMine ? 'right' : 'left';

    const conv = document.createElement('div');
    conv.className = 'conversation-list';

    const dd = document.createElement('div');
    dd.className = 'dropdown';
    dd.innerHTML =
      '<a class="dropdown-toggle" href="#" data-bs-toggle="dropdown" aria-expanded="false">' +
        '<i class="mdi mdi-dots-vertical"></i>' +
      '</a>' +
      '<div class="dropdown-menu dropdown-menu-end">' +
        '<a class="dropdown-item" href="#" data-action="copy">Copy</a>' +
        '<a class="dropdown-item" href="#" data-action="delete">Delete</a>' +
      '</div>';

    const wrap = document.createElement('div');
    wrap.className = 'ctext-wrap d-flex align-items-end';

    const bubble = document.createElement('div');
    bubble.className = 'ctext-wrap-content';

    if (isMine) {
      bubble.classList.add('bg-soft-primary', 'bg-primary-subtle');
    } else {
      bubble.classList.add('bg-light');
    }

    const h5 = document.createElement('h5');
    h5.className = 'conversation-name';

    const nameSpan = document.createElement('span');
    nameSpan.className = 'name fw-semibold';

    if (!isMine) {
      const nameDiv = document.createElement('div');
      nameDiv.className = 'sender-name fw-semibold mb-1';
      nameDiv.textContent = msg.fullName + (msg.senderRank ? ' ' + msg.senderRank : '');
      conv.appendChild(nameDiv);
    }

    const p = document.createElement('p');
    p.className = 'mb-0';
    p.innerHTML = (msg.content || '').replace(/\n/g, "<br>");

    h5.appendChild(nameSpan);
    bubble.appendChild(h5);
    bubble.appendChild(p);

    const timeSpan = document.createElement('span');
    timeSpan.className = 'message-time small text-muted ms-2 me-2';
    timeSpan.textContent = formatTime(msg.createdAt);

    if (isMine) {
      wrap.appendChild(timeSpan);
      wrap.appendChild(bubble);
    } else {
      wrap.appendChild(bubble);
      wrap.appendChild(timeSpan);
    }

    conv.appendChild(wrap);
    li.appendChild(conv);
    $list.appendChild(li);

    $list.parentElement.scrollTop = $list.parentElement.scrollHeight;
  }

  // =========================
  // 메시지 전송/읽음
  // =========================
  function sendMessage() {
    if (!stompClient || !stompClient.connected) return;
    const content = $input.value.trim();
    if (!content) return;
    
   // console.log('meta.roomId =', meta.roomId, 'chatroomId var =', chatroomId);
    const dest = appSend(chatroomId);
    //console.log('SEND to =>', dest);
   // console.log("보내는중:", chatroomId, content);

    stompClient.send(`/app/rooms/${chatroomId}/send`, {}, JSON.stringify({
        chatMessageContent: content
    }));
    
    $input.value = '';
    $input.focus();
  }

  function markReadIfNeeded() {
    if (!stompClient || !stompClient.connected || lastMessageId === 0) return;
    stompClient.send(appRead(chatroomId),
      { 'content-type': 'application/json' },
      JSON.stringify({ chatMessageId: lastMessageId })
    );
  }
  
  const dest = appRead(chatroomId);
  console.log('READ to =>', dest, ' lastMessageId=', lastMessageId);

  function setConnected(connected) {
    if (connected) {
      $status.textContent = '연결됨';
      $sendBtn.disabled = false;
    } else {
      $status.textContent = '연결 끊김 - 재시도 중...';
      $sendBtn.disabled = true;
    }
  }

  // =========================
  // STOMP 연결
  // =========================
  function connect() {
    setConnected(false);

    const socket = new SockJS("/ws-stomp", null, { withCredentials: true });
    stompClient = Stomp.over(socket);

    const headers = getCsrfHeaders();

    stompClient.connect(headers, function onConnect(frame) {
      retry = 0;
      setConnected(true);
      console.log('Connected: ' + frame);

      stompClient.subscribe(topicRoom(chatroomId), function (message) {
        try {
          appendMessage(JSON.parse(message.body));
        } catch (e) {
          console.error('메시지 파싱 실패', e, message.body);
        }
      });

      stompClient.subscribe(topicRead(chatroomId), function (message) {
        // 읽음 UI 반영 가능
      });

      if (document.hasFocus()) markReadIfNeeded();
    }, function onError(err) {
      console.error('STOMP error', err);
      setConnected(false);
      retry = Math.min(retry + 1, 5);
      const delay = Math.min(1000 * Math.pow(2, retry), 10000);
      setTimeout(connect, delay);
    });

    socket.onclose = function() { setConnected(false); };
  }
 
  document.getElementById('send-btn').addEventListener('click', sendMessage);
  document.getElementById('chat-input').addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  });
  window.addEventListener('focus', markReadIfNeeded);

  
//예: 페이지 열릴 때 호출
  
    $(document).ready(function () {
        loadMessages(chatroomId); // DB에서 이전 메시지 불러오기
        connect();                // WebSocket 연결
      });

</script>


<div><jsp:include page ="../nav/footer.jsp"></jsp:include></div>
<div><jsp:include page ="../nav/javascript.jsp"></jsp:include></div>
</body>
</html>
