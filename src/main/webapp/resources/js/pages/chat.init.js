// resources/js/pages/chat.init.js
(function (window, $) {
  'use strict';

  // ---- 엘리먼트 & 메타 ----
  const $status  = document.getElementById('ws-status');
  const $sendBtn = document.getElementById('send-btn');
  const $input   = document.getElementById('chat-input');
  const $list    = document.getElementById('chat-messages');

  const meta        = document.getElementById('chat-meta')?.dataset || {};
  let chatroomId    = Number(meta.roomId || 1);   // 🔴 const → let 변경
  const myUserId    = Number(meta.userId || 0);

  // ---- 상태 ----
  let stompClient = null;
  let lastMessageId = 0;
  let retry = 0;

  // ---- 유틸 ----
  function topicRoom(id){ return '/topic/rooms/' + id; }
  function topicRead(id){ return '/topic/rooms/' + id + '/read'; }
  function appSend(id){ return '/app/rooms/' + id + '/send'; }
  function appRead(id){ return '/app/rooms/' + id + '/read'; }

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

  // ---- 날짜 구분선 ----
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

  // ---- 렌더 ----
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

    const wrap = document.createElement('div');
    wrap.className = 'ctext-wrap d-flex align-items-end';

    const bubble = document.createElement('div');
    bubble.className = 'ctext-wrap-content';
    bubble.classList.add(isMine ? 'bg-primary-subtle' : 'bg-light');

    if (!isMine) {
      const nameDiv = document.createElement('div');
      nameDiv.className = 'sender-name fw-semibold mb-1';
      nameDiv.textContent = msg.fullName + (msg.senderRank ? ' ' + msg.senderRank : '');
      conv.appendChild(nameDiv);
    }

    const p = document.createElement('p');
    p.className = 'mb-0';
    p.innerHTML = (msg.content || '').replace(/\n/g, '<br>');

    const timeSpan = document.createElement('span');
    timeSpan.className = 'message-time small text-muted ms-2 me-2';
    timeSpan.textContent = formatTime(msg.createdAt);

    if (isMine) { wrap.appendChild(timeSpan); wrap.appendChild(bubble); }
    else        { wrap.appendChild(bubble);   wrap.appendChild(timeSpan); }

    bubble.appendChild(p);
    conv.appendChild(wrap);
    li.appendChild(conv);
    $list.appendChild(li);
    $list.parentElement.scrollTop = $list.parentElement.scrollHeight;
  }

  // ---- API ----
  function loadMessages(roomId) {
    $.getJSON('/api/rooms/' + roomId + '/messages?limit=50', function(messages) {
      $('#chat-messages').empty();
      messages.forEach(m => appendMessage(m));
    });
  }

  function markReadIfNeeded() {
    if (!stompClient || !stompClient.connected || lastMessageId === 0) return;
    stompClient.send(appRead(chatroomId),
      { 'content-type': 'application/json' },
      JSON.stringify({ chatMessageId: lastMessageId })
    );
  }

  function setConnected(connected) {
    if (connected) { $status && ($status.textContent = '연결됨'); $sendBtn && ($sendBtn.disabled = false); }
    else           { $status && ($status.textContent = '연결 끊김 - 재시도 중...'); $sendBtn && ($sendBtn.disabled = true); }
  }

  function connect() {
    setConnected(false);
    const socket = new SockJS('/ws-stomp', null, { withCredentials: true });
    stompClient = Stomp.over(socket);

    stompClient.connect({}, function onConnect(frame) {
      retry = 0;
      setConnected(true);
      stompClient.subscribe(topicRoom(chatroomId), function (message) {
        try { appendMessage(JSON.parse(message.body)); }
        catch (e) { console.error('메시지 파싱 실패', e, message.body); }
      });
      stompClient.subscribe(topicRead(chatroomId), function () { /* 읽음 UI 필요 시 */ });
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

  function sendMessage() {
    if (!stompClient || !stompClient.connected) return;
    const content = ($input?.value || '').trim();
    if (!content) return;
	console.log("📤 메시지 전송:", content, "→ 방 ID:", chatroomId); // 디버깅
    stompClient.send(appSend(chatroomId), {}, JSON.stringify({ chatMessageContent: content }));
    $input.value = ''; $input.focus();
  }

  // ---- 이벤트 ----
  $sendBtn && $sendBtn.addEventListener('click', sendMessage);
  $input && $input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  });
  window.addEventListener('focus', markReadIfNeeded);

  // ---- 부트 ----
  $(function () {
    loadMessages(chatroomId);
    connect();
  });

  // 🔴 방 전환 함수 (추가)
  window.openChatRoom = function(roomId){
    $('#chat-messages').empty();
    chatroomId = roomId;              // 방 ID 갱신
    loadMessages(roomId);             // 메시지 다시 로딩
    if (stompClient && stompClient.connected) {
      try { stompClient.disconnect(); } catch(e) {}
    }
    connect();                        // 새 방으로 연결
    $('.page-title-box h4').text('Chat Room #' + roomId);
  };

})(window, jQuery);


// ======================= Chat (DM 목록/클릭) =======================

function getContactsListEl() {
  return $('.chat-leftsidebar .chat-list').last();
}

function formatWhen(s) {
  if (!s) return '';
  var hhmm = (s.match(/\d{2}:\d{2}/) || [])[0];
  if (!hhmm) return s;
  var day = s.slice(0,10);
  var today = new Date().toISOString().slice(0,10);
  return (day === today) ? hhmm : day;
}

function escapeHtml(str){
  return String(str||'').replace(/[&<>"]/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]); });
}

function renderDmList(list) {
  var $ul = getContactsListEl();
  $ul.empty();

  if (!list || list.length === 0) {
    $ul.append('<li class="text-muted px-3">대화 상대가 없습니다.</li>');
    return;
  }

  list.forEach(function(item){
    var name = item.chatroomName || '(이름 없음)';
    var initial = name.trim().charAt(0) || 'U';
    var unread = (item.unreadCount != null ? Number(item.unreadCount) : 0);
    var when = formatWhen(item.lastMessageAt);
    var lastMsg = item.lastMessage ? String(item.lastMessage) : '';

    var badgeHtml = unread > 0
      ? '<span class="badge bg-danger-subtle text-danger ms-2">'+ unread +'</span>'
      : '';

    var html =
      '<li>' +
        '<a href="#" class="d-flex align-items-center dm-item" data-room-id="' + item.chatroomId + '">' +
          '<div class="flex-shrink-0 me-3">' +
            '<div class="avatar-xs">' +
              '<span class="avatar-title rounded-circle bg-primary-subtle text-primary">' + escapeHtml(initial) + '</span>' +
            '</div>' +
          '</div>' +
          '<div class="flex-grow-1">' +
            '<h5 class="font-size-14 mb-0">' + escapeHtml(name) + badgeHtml + '</h5>' +
            '<small class="text-muted">' + escapeHtml(when) + (lastMsg ? ' · ' + escapeHtml(lastMsg) : '') + '</small>' +
          '</div>' +
        '</a>' +
      '</li>';

    $ul.append(html);
  });
}

function loadDmList() {
  return fetch('/api/rooms/dm', { credentials: 'same-origin' })
    .then(res => { if(!res.ok) throw new Error('HTTP '+res.status); return res.json(); })
    .then(list => { renderDmList(list); return list; })
    .catch(err => {
      console.error('DM 목록 로딩 실패:', err);
      var $ul = getContactsListEl();
      $ul.empty().append('<li class="text-danger px-3">DM 목록 로딩 실패</li>');
      return [];
    });
}

// Contacts 항목 클릭 → 방 이동
$(document).on('click', '.dm-item', function(e){
  e.preventDefault();
  var roomId = $(this).data('room-id');
  if (roomId) window.openChatRoom(roomId);
});

$(function(){ loadDmList(); });
