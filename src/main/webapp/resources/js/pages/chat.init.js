// resources/js/pages/chat.init.js
(function (window, $) {
  'use strict';
  
  // ---- WS 싱글톤(탭 내 1개만) & 인박스 디듀프 ----
  const WS_KEY = '__CHAT_WS_SINGLETON__';
  if (!window[WS_KEY]) {
    window[WS_KEY] = {
      client: null,
      connected: false,
      connecting: false,
      subs: { room: null, read: null, inbox: null }
    };
  }
  // 인박스 이벤트 중복 방지용 (1.5초 윈도우)
  const recentInbox = new Map();

  // ---- 엘리먼트 & 메타 ----
  const $status  = document.getElementById('ws-status');
  const $sendBtn = document.getElementById('send-btn');
  const $input   = document.getElementById('chat-input');
  const $list    = document.getElementById('chat-messages');

  const meta        = document.getElementById('chat-meta')?.dataset || {};
  // 서버에서 roomId가 와도 "처음엔 무조건 미선택" 상태로 시작
    const __rawRoomId   = (meta.roomId ?? '').trim();
    const initialRoomId = /^\d+$/.test(__rawRoomId) ? Number(__rawRoomId) : null; // 필요 시 참고용
    let chatroomId      = null; //  자동입장 방지: 항상 null로 시작
  const myUserId    = Number(meta.userId || 0);
  const ctx = meta.contextPath || '';
  window.CONTEXT_PATH  = ctx;               // 전역에 저장
  window.DEFAULT_AVATAR = meta.avatarDefault || '/resources/images/users/avatar-default.png';	// 기본 이미지

  // ---- SimpleBar 스크롤 유틸 ----
  function resolveScroller() {
    const container = document.getElementById('messageScroll');
    if (window.SimpleBar) {
      if (container) {
        try {
          let sb = (SimpleBar.instances && SimpleBar.instances.get)
            ? SimpleBar.instances.get(container)
            : null;
          if (!sb) sb = new SimpleBar(container);
          if (sb && sb.getScrollElement) return sb.getScrollElement();
        } catch (e) {}
      }
      if ($list) {
        const content = $list.closest('.simplebar-content');
        if (content && content.parentElement && content.parentElement.classList.contains('simplebar-content-wrapper')) {
          return content.parentElement;
        }
      }
    }
    return $list ? $list.parentElement : null;
  }
  function scrollToBottom() {
    const el = resolveScroller();
    if (el) el.scrollTop = el.scrollHeight;
  }

  // ---- 상태변수  ----
  let stompClient = null;
  let lastMessageId = 0;
  let lastDateLabel = '';
  let retry = 0;
  let isConnecting = false;
  let reconnectTimer = null;

  // 구독 핸들
  let roomSub = null;
  let readSub = null;
  let inboxSub = null;

  // ---- 유틸 ----
  function topicRoom(id){ return '/topic/rooms/' + id; }
  function topicRead(id){ return '/topic/rooms/' + id + '/read'; }
  function appSend(id){ return '/app/rooms/' + id + '/send'; }
  function appRead(id){ return '/app/rooms/' + id + '/read'; }
  function topicInbox(uid){ return '/topic/user.' + uid + '/inbox'; }

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
    p.innerHTML = escapeHtml(msg.content || '').replace(/\n/g, '<br>');

    const timeSpan = document.createElement('span');
    timeSpan.className = 'message-time small text-muted ms-2 me-2';
    timeSpan.textContent = formatTime(msg.createdAt);

    if (isMine) { wrap.appendChild(timeSpan); wrap.appendChild(bubble); }
    else        { wrap.appendChild(bubble);   wrap.appendChild(timeSpan); }

    bubble.appendChild(p);
    conv.appendChild(wrap);
    li.appendChild(conv);
    $list.appendChild(li);

    // 목록 프리뷰 즉시 갱신
	if (window.updateDmPreview) {
	      // 현재 방 메시지 렌더 → 프리뷰만 갱신, 정렬 X
	  window.updateDmPreview(chatroomId, msg.content, msg.createdAt, {reorder:false});
   }

    scrollToBottom();
  }
  
  function inboxDedupe(evt) {
    const roomId    = evt.roomId ?? evt.chatroomId ?? evt.id ?? '';
    const msgId     = evt.messageId ?? evt.chatMessageId ?? '';
    const preview   = evt.preview ?? evt.content ?? '';
    const createdAt = evt.createdAt ?? evt.createDate ?? '';
    const key = roomId + '|' + (msgId || preview) + '|' + createdAt;
    const now = Date.now();
    const last = recentInbox.get(key);
    if (last && now - last < 1500) return false; // 1.5초 내 재수신 → 무시
    recentInbox.set(key, now);
    if (recentInbox.size > 200) {
      for (const [k, t] of recentInbox) if (now - t > 60000) recentInbox.delete(k);
    }
    return true;
  }

  function inboxHandler(frame){
    const evtRaw = JSON.parse(frame.body);
    if (!inboxDedupe(evtRaw)) return;

    const roomId    = evtRaw.roomId ?? evtRaw.chatroomId ?? evtRaw.id;
    const preview   = evtRaw.preview ?? evtRaw.content ?? '';
    const createdAt = evtRaw.createdAt ?? evtRaw.createDate ?? evtRaw.created_at ?? '';
    if (!roomId) return;

    const $ul   = getContactsListEl();
    const $item = $ul.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');

    if ($item.length === 0) {
      loadDmList().then(() => {
        if (window.updateDmPreview) window.updateDmPreview(roomId, preview, createdAt, {reorder:true});
       // incrementUnread(roomId);
      });
      return;
    }
    if (roomId !== chatroomId) {
      if (window.updateDmPreview) window.updateDmPreview(roomId, preview, createdAt, {reorder:true});
      incrementUnread(roomId);
    }
  }

  function roomHandler(message){
    try { appendMessage(JSON.parse(message.body)); } catch(e){ console.error('메시지 파싱 실패', e); }
  }

  // ---- API ----
  function loadMessages(roomId) {
    $.getJSON('/api/rooms/' + roomId + '/messages?limit=50', function(messages) {
      $('#chat-messages').empty();
      // 서버가 DESC로 보내면 필요 시 역정렬
      if (messages.length >= 2) {
        const a = messages[0], b = messages[messages.length - 1];
        const ida = a.chatMessageId || a.messageId || 0;
        const idb = b.chatMessageId || b.messageId || 0;
        if (ida > idb) messages.reverse();
      }
      messages.forEach(m => appendMessage(m));
      scrollToBottom();
    });
  }

  function markReadIfNeeded() {
    if (!stompClient || !stompClient.connected || lastMessageId === 0) return;
	if (!chatroomId) return; 
	if (lastMessageId === 0) return;
    stompClient.send(appRead(chatroomId),
      { 'content-type': 'application/json' },
      JSON.stringify({ chatMessageId: lastMessageId })
    );
  }

  
	 function updateSendBtn(){
	   $sendBtn && ($sendBtn.disabled = !(stompClient && stompClient.connected && chatroomId));
	}
	 function setConnected(connected){
	   if ($status) $status.textContent = connected ? '연결됨' : '연결 끊김 - 재시도 중...';
	   updateSendBtn();
	 }

	 function connect() {
	   // 이미 연결돼 있거나 연결 중이면 재진입 금지
	   if (window[WS_KEY].connected) { setConnected(true); return; }
	   if (window[WS_KEY].connecting) return;

	   window[WS_KEY].connecting = true;
	   isConnecting = true;

	   const socket = new SockJS('/ws-stomp', null, { withCredentials: true });
	   const client = Stomp.over(socket);
	   window[WS_KEY].client = client;

	   client.connect({}, () => {
	     window[WS_KEY].connecting = false;
	     window[WS_KEY].connected  = true;
	     stompClient = client; // 기존 코드 호환
	     setConnected(true);

	     // 방 구독(있을 때만). 이전 구독 있으면 해제
	     if (window[WS_KEY].subs.room) { try{ window[WS_KEY].subs.room.unsubscribe(); }catch(e){} }
	     if (window[WS_KEY].subs.read) { try{ window[WS_KEY].subs.read.unsubscribe(); }catch(e){} }

	     if (chatroomId) {
	       window[WS_KEY].subs.room = roomSub = client.subscribe(topicRoom(chatroomId), roomHandler);
	       window[WS_KEY].subs.read = readSub = client.subscribe(topicRead(chatroomId), function(){});
	     }

	     // 인박스는 세션당 정확히 1개만
	     if (window[WS_KEY].subs.inbox) { try{ window[WS_KEY].subs.inbox.unsubscribe(); }catch(e){} }
	     window[WS_KEY].subs.inbox = inboxSub = client.subscribe(topicInbox(myUserId), inboxHandler);

	     if (document.hasFocus()) markReadIfNeeded();
	     isConnecting = false;
	   }, (err) => {
	     console.error('STOMP error', err);
	     window[WS_KEY].connecting = false;
	     window[WS_KEY].connected  = false;
	     isConnecting = false;
	     setConnected(false);

	     retry = Math.min(retry + 1, 5);
	     if (!reconnectTimer) {
	       const delay = Math.min(1000 * Math.pow(2, retry), 10000);
	       reconnectTimer = setTimeout(() => { reconnectTimer = null; connect(); }, delay);
	     }
	   });

	   socket.onclose = function() {
	     window[WS_KEY].connected = false;
	     setConnected(false);
	   };
	 }

  function sendMessage() {
    if (!stompClient || !stompClient.connected) return;
    const content = ($input?.value || '').trim();
    if (!content) return;
    stompClient.send(appSend(chatroomId), {}, JSON.stringify({ chatMessageContent: content }));
    $input.value = ''; $input.focus();

    // 내 화면의 목록 프리뷰도 즉시 갱신
    if (window.updateDmPreview) {
	//내가 보낸 직후에도 정렬 X (프리뷰/시간만 갱신)
		window.updateDmPreview(chatroomId, content, new Date().toISOString(), {reorder:false});
  	}
    scrollToBottom();
  }

  
  
  // ---- 이벤트 ----
  $sendBtn && $sendBtn.addEventListener('click', sendMessage);
  $input && $input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  });
  window.addEventListener('focus', markReadIfNeeded);
  
  // 채팅방 나가기
  $(document).on('click', '#action-leave-room', function(e){
    e.preventDefault();

    // 항상 현재 열린 방 기준으로!
    var roomId = (typeof window.CURRENT_ROOM_ID !== 'undefined' && window.CURRENT_ROOM_ID)
                   ? window.CURRENT_ROOM_ID
                   : (document.getElementById('chat-meta')?.dataset.roomId || null);

    if (!roomId) {
      alert('열린 채팅방이 없습니다.');
      return;
    }

    if (!confirm('이 대화방을 나가시겠습니까?')) return;

    fetch('/api/rooms/' + roomId + '/leave', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
        // ,'X-CSRF-TOKEN': window.CSRF_TOKEN
      }
    })
    .then(function(res){
      if (res.status === 204) {
        // UI 갱신: 목록에서 제거/표시 변경 + 오른쪽 패널 비우기
		
		// 방 토픽 구독을 반드시 끊어야 함
		if (window.__CHAT_WS_SINGLETON__?.subs?.room) {
		  try { window.__CHAT_WS_SINGLETON__.subs.room.unsubscribe(); } catch(e){}
		  window.__CHAT_WS_SINGLETON__.subs.room = null;
		}
		if (window.__CHAT_WS_SINGLETON__?.subs?.read) {
		  try { window.__CHAT_WS_SINGLETON__.subs.read.unsubscribe(); } catch(e){}
		  window.__CHAT_WS_SINGLETON__.subs.read = null;
		}

		// 현재 방 상태도 해제
		if (typeof chatroomId !== 'undefined') chatroomId = null;
		window.CURRENT_ROOM_ID = null;
        // 항목 제거
        var $ul = getContactsListEl();
        $ul.find('.dm-item[data-room-id="'+roomId+'"]').closest('li').remove();
        // 패널 초기화
        showEmpty();
        $('#chat-messages').empty();
        window.CURRENT_ROOM_ID = null;
        alert('대화방에서 나갔습니다.');
        return;
      }
      return res.text().then(function(t){ throw new Error(t || ('HTTP '+res.status)); });
    })
    .catch(function(err){
      console.error('leave error:', err);
      alert('대화방 나가기에 실패했습니다.\n' + err.message);
    });
  });

  // ---- 부트 ----
  $(function () {
      showEmpty();       // ★ 무조건 빈화면부터
     loadDmList();      // 좌측 목록만 먼저 로딩
      connect();         // ws 연결 (방 구독은 선택 후)
    });

  // 🔵 방 전환: 연결 유지, room/read만 재구독
  window.openChatRoom = function(roomId){
	showPane();
    $('#chat-messages').empty();
    chatroomId = roomId;
    window.CURRENT_ROOM_ID = roomId;
    lastMessageId = 0;
    lastDateLabel = '';
    loadMessages(roomId);
	//  현재 방 배지 제거
    clearUnread(roomId);
	applyRoomHeaderFromList(roomId);

	if (window[WS_KEY].connected) {
	  if (roomSub) { try{ roomSub.unsubscribe(); }catch(e){} roomSub = null; }
	  if (readSub) { try{ readSub.unsubscribe(); }catch(e){} readSub = null; }
	  roomSub = window[WS_KEY].subs.room = window[WS_KEY].client.subscribe(topicRoom(chatroomId), roomHandler);
	  readSub = window[WS_KEY].subs.read = window[WS_KEY].client.subscribe(topicRead(chatroomId), function(){});
	} else {
	  connect(); // 완전히 끊겼을 때만 재연결
	}
    $('.page-title-box h4').text('Chat Room #' + roomId);
	 // 들어오자마자 읽음 서버전송
	 updateSendBtn();
	 setTimeout(markReadIfNeeded, 50);
  };
  
  // 현재 방의 '읽지 않음' 배지 제거
  function clearUnread(roomId){
    var $ul   = getContactsListEl();
    var $item = $ul.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');
    if ($item.length === 0) return;
	 var $badge = $item.find('.dm-badge-unread');                   // 오른쪽 배지 숨김
	 $badge.text('').hide();
  }

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
  var ctx = window.CONTEXT_PATH || '';
  $ul.empty();

  if (!list || list.length === 0) {
    $ul.append('<li class="text-muted px-3">대화 상대가 없습니다.</li>');
    return;
  }

  list.forEach(function(item){
     var name = item.chatroomName || '(이름 없음)';
     var peerUserRank = item.peerUserRank || '';
     var avatar = item.peerAvatarPath
       ? (ctx + '/resources/images/users/' + item.peerAvatarPath)
       : window.DEFAULT_AVATAR;

     var unread = (item.unreadCount != null ? Number(item.unreadCount) : 0);
     var when = formatWhen(item.lastMessageAt || item.lastActivityAt || item.updatedAt || item.createdAt);
     var lastMsg = item.lastMessage ? String(item.lastMessage) : '';
     var unreadText = unread > 0 ? String(Math.min(99, unread)).padStart(2,'0') : '';
     var badgeHtml =
       '<span class="badge rounded-pill dm-badge-unread ms-2"' +
       (unread > 0 ? '' : ' style="display:none"') + '>' + unreadText + '</span>';

     var html =
       '<li>' +
         '<a href="#" class="d-flex align-items-center dm-item" ' +
           'data-room-id="'   + item.chatroomId      + '" ' +
           'data-peer-name="' + escapeHtml(name)     + '" ' +
           'data-peer-rank="' + escapeHtml(peerUserRank) + '" ' +
           'data-peer-avatar="'+ escapeHtml(avatar)  + '">' +
             '<div class="flex-shrink-0 me-3">' +
               '<div class="avatar-xs">' +
                 '<img src="' + escapeHtml(avatar) + '" class="rounded-circle avatar-img-fix" alt="avatar">' +
               '</div>' +
             '</div>' +
             '<div class="flex-grow-1 w-100">' +
               '<div class="d-flex align-items-center">' +
			    '<h5 class="font-size-14 mb-0 flex-grow-1 text-truncate">' +
			      escapeHtml(peerUserRank ? (name + ' ' + peerUserRank) : name) +
			    '</h5>' +
                 badgeHtml +
               '</div>' +
               '<div class="d-flex align-items-center mt-1">' +
                 '<small class="text-muted dm-last text-truncate flex-grow-1">' + escapeHtml(lastMsg) + '</small>' +
                 '<small class="text-muted dm-when ms-2">' + escapeHtml(when) + '</small>' +
               '</div>' +
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

// 현재 방 외의 DM 항목 프리뷰/시간 갱신
function updateDmPreview(roomId, lastMsg, lastAt, opts) {
  opts = opts || {};
  var shouldReorder = !!opts.reorder; // 기본 false
    //  현재 열린 방이면 절대 정렬 금지 (안전 가드)
    if (typeof window.CURRENT_ROOM_ID !== 'undefined' &&
       Number(roomId) === Number(window.CURRENT_ROOM_ID)) {
      shouldReorder = false;
    }
  
  var $ul   = getContactsListEl();
  var $item = $ul.find('.dm-item[data-room-id="' + roomId + '"]').closest('li');
  if ($item.length === 0) return;

  var when  = formatWhen(lastAt || '');
  $item.find('.dm-last').text(String(lastMsg || ''));
  $item.find('.dm-when').text(when);

  // 받은 메시지로 들어온 경우에만 상단 이동
  if (shouldReorder) $ul.prepend($item);
}

// (보조) 미확인 배지 증가
function incrementUnread(roomId) {
  var $ul   = getContactsListEl();
  var $item = $ul.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');
  if ($item.length === 0) return;
    var $badge = $item.find('.dm-badge-unread');   // 윗줄 전용 배지
    if ($badge.length === 0) {
      var $h5 = $item.find('h5');
      $h5.after('<span class="badge rounded-pill dm-badge-unread ms-2">01</span>');
    } else {
      var n = parseInt($badge.text(), 10) || 0;
      n = Math.min(99, n + 1);
      $badge.text(String(n).padStart(2,'0')).show();
    }
  $ul.prepend($item);
}

// Contacts 항목 클릭 → 방 이동
$(document).on('click', '.dm-item', function(e){
  e.preventDefault();
  var roomId = $(this).data('room-id');
  if (roomId) window.openChatRoom(roomId);
});


function applyRoomHeaderFromList(roomId){
  var $ul   = getContactsListEl();
  var $item = $ul.find('.dm-item[data-room-id="' + roomId + '"]');
  if ($item.length === 0) return; // 아직 리스트가 안 그려졌으면 패스

  var name   = $item.data('peer-name')  || '채팅방';
  var rank   = $item.data('peer-rank')  || '';
  var avatar = $item.data('peer-avatar')|| window.DEFAULT_AVATAR;

  var $avatar = $('#room-avatar');
  var $title  = $('#room-title');

  $avatar.attr('src', avatar);
  $title.text(rank ? (name + ' ' + rank) : name);
}

// 채팅방 누르면 채팅방 아니면 빈화면
const pane  = document.getElementById('chat-panel');
const empty = document.getElementById('chat-empty');
const send  = document.getElementById('send-btn');

function showEmpty(){
  if (pane)  pane.classList.add('d-none');
  if (empty) empty.classList.remove('d-none');
  if (send)  send.disabled = true;
}
function showPane(){
  if (empty) empty.classList.add('d-none');
  if (pane)  pane.classList.remove('d-none');
  if (send)  send.disabled = false;
}

window.addEventListener('beforeunload', function(){
  try { if (window[WS_KEY].subs.room)  window[WS_KEY].subs.room.unsubscribe(); } catch(e){}
  try { if (window[WS_KEY].subs.read)  window[WS_KEY].subs.read.unsubscribe(); } catch(e){}
  try { if (window[WS_KEY].subs.inbox) window[WS_KEY].subs.inbox.unsubscribe(); } catch(e){}
  try { window[WS_KEY].client && window[WS_KEY].client.disconnect(()=>{}); } catch(e){}
  window[WS_KEY].subs = { room:null, read:null, inbox:null };
  window[WS_KEY].client = null;
  window[WS_KEY].connected = false;
  window[WS_KEY].connecting = false;
});

