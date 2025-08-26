//resources/js/pages/chat.init.js

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

  // 인박스 이벤트 중복 방지(짧은 윈도우)
  const recentInbox = new Map(); // key: roomId|msgId(or preview)|createdAt
  // 모든 채널 공용 디듀프(룸/인박스 교차)
  const recentEvt = new Map();   // key: synthetic key -> ts
  // 방별 마지막 메시지 등장 시각(시스템 이벤트 억제용)
  const lastMsgSeenByRoom = new Map(); // roomId -> ts
  // 인박스에서 받은 "같은 방, 같은 메시지ID" 재수신 차단
  const inboxMsgSeen = new Map(); // key: `${roomId}|${msgId}` -> ts
  function seenInboxMsg(roomId, msgId, ttlMs = 60000) {
    if (!roomId || !msgId) return false;
    const key = String(roomId) + '|' + String(msgId);
    const now = Date.now();
    const last = inboxMsgSeen.get(key);
    if (last && (now - last) < ttlMs) return true;
    inboxMsgSeen.set(key, now);
    if (inboxMsgSeen.size > 800) {
      for (const [k, ts] of inboxMsgSeen) if (now - ts > ttlMs * 2) inboxMsgSeen.delete(k);
    }
    return false;
  }

  function dedupeEvent(evt, ttlMs = 5000) {
    try {
      const t = String(evt?.type || evt?.eventType || evt?.kind || '').toUpperCase();
      const roomId = Number(evt?.roomId ?? evt?.chatroomId ?? evt?.chatRoomId ?? evt?.groupId ?? evt?.id ?? 0);
      const actor  = Number(evt?.userId ?? evt?.inviterUserId ?? evt?.senderUserId ?? 0);
      const target = Number(evt?.targetUserId ?? evt?.invitedUserId ?? 0);
      const msgId  = String(evt?.messageId ?? evt?.chatMessageId ?? '');
      const evId   = String(evt?.eventId ?? evt?.uuid ?? '');

      let key = '';
      if (evId) {
        key = 'EID|' + evId;
      } else if (msgId) {
        key = 'MSG|' + roomId + '|' + msgId;
      } else if (/GROUP_MEMBER|ROOM_MEMBER/.test(t)) {
        key = 'MEM|' + roomId + '|' + (target || actor || 0) + '|' + t;
      } else if (/READ/.test(t)) {
        const lastId = String(evt?.lastMessageId ?? evt?.chatMessageId ?? '');
        key = 'READ|' + roomId + '|' + actor + '|' + lastId;
      } else {
        const payload = String(evt?.preview ?? evt?.content ?? '').slice(0, 64);
        key = 'GEN|' + t + '|' + roomId + '|' + actor + '|' + target + '|' + payload;
      }

      const now = Date.now();
      const last = recentEvt.get(key);
      if (last && (now - last) < ttlMs) return true;

      recentEvt.set(key, now);
      if (recentEvt.size > 400) {
        for (const [k, ts] of recentEvt) if (now - ts > ttlMs * 3) recentEvt.delete(k);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ---- 엘리먼트 & 메타 ----
  const $status  = document.getElementById('ws-status');
  const $sendBtn = document.getElementById('send-btn');
  const $input   = document.getElementById('chat-input');
  const $list    = document.getElementById('chat-messages');

  const meta        = document.getElementById('chat-meta')?.dataset || {};
  const __rawRoomId   = (meta.roomId ?? '').trim();
  const initialRoomId = /^\d+$/.test(__rawRoomId) ? Number(__rawRoomId) : null; // 참고용(자동입장 막음)
  let chatroomId      = null; // 항상 null로 시작(자동입장 방지)
  const myUserId    = Number(meta.userId || 0);
  const ctx = meta.contextPath || '';
  window.CONTEXT_PATH   = ctx;
  window.DEFAULT_AVATAR = meta.avatarDefault || '/resources/images/users/avatar-default.png';

  // ---- SimpleBar 스크롤 ----
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

  // ---- 상태변수 ----
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

  // ---- 토픽 util ----
  function topicRoom(id){ return '/topic/rooms/' + id; }
  function topicRead(id){ return '/topic/rooms/' + id + '/read'; }
  function appSend(id){ return '/app/rooms/' + id + '/send'; }
  function appRead(id){ return '/app/rooms/' + id + '/read'; }
  function topicInbox(uid){ return '/topic/user.' + uid + '/inbox'; }

  // ---- 포맷/정규화 ----
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

  // ---- 메시지 렌더 ----
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

    // 목록 프리뷰 즉시 갱신(정렬X)
    if (window.updateDmPreview) {
      window.updateDmPreview(chatroomId, msg.content, msg.createdAt, {reorder:false});
    }

    scrollToBottom();
  }

  // ---- 인박스용 짧은 디듀프 ----
  function inboxDedupe(evt) {
    const roomId    = evt.roomId ?? evt.chatroomId ?? evt.id ?? '';
    const msgId     = evt.messageId ?? evt.chatMessageId ?? '';
    const preview   = evt.preview ?? evt.content ?? '';
    const createdAt = evt.createdAt ?? evt.createDate ?? '';
    const key = roomId + '|' + (msgId || preview) + '|' + createdAt;
    const now = Date.now();
    const last = recentInbox.get(key);
    if (last && now - last < 1500) return false;
    recentInbox.set(key, now);
    if (recentInbox.size > 200) {
      for (const [k, t] of recentInbox) if (now - t > 60000) recentInbox.delete(k);
    }
    return true;
  }

  // ---- 인박스 핸들러 (알림/프리뷰/배지 전담) ----
  function inboxHandler(frame){
    const evtRaw = JSON.parse(frame.body);

    const t = String(evtRaw.type || evtRaw.eventType || evtRaw.kind || '').toUpperCase();
    const roomId = Number(evtRaw.roomId ?? evtRaw.chatroomId ?? evtRaw.id ?? 0);
    if (!roomId) return;

    const msgIdNum  = Number(evtRaw.messageId ?? evtRaw.chatMessageId ?? 0);
    const hasMsgId  = msgIdNum > 0;
    const hasContent= !!(evtRaw.content && String(evtRaw.content).trim()) ||
                      !!(evtRaw.preview && String(evtRaw.preview).trim());
    const isMessage = hasMsgId || /MESSAGE/.test(t);

	// 🔧 [FIX] 프리뷰( msgId 없음 )와 정상( msgId 있음 )을 같은 메시지로 묶는다.
	// - 프리뷰는 senderId가 비어있거나 createdAt이 다를 수 있으므로
	//   (1) 내용만으로 만든 키, (2) 보낸사람+내용 키, (3) evId, (4) msgId
	//   네 가지를 모두 60초 동안 캐시해서 어느 경로로 와도 한 번만 카운트되게 함.
	{
	  if (isMessage) {
	    const content64 = String(evtRaw.preview ?? evtRaw.content ?? '').slice(0, 64);
	    const senderId  = Number(evtRaw.senderUserId ?? evtRaw.userId ?? evtRaw.senderId ?? 0);

	    // ① 내용 전용 키 (프리뷰에 senderId가 없는 케이스 커버)
	    const sigContent       = 'SIGC|'  + content64;
	    // ② 보낸사람+내용 키 (다중 발신자 동일 내용 구분)
	    const sigSenderContent = 'SIGSC|' + senderId + '|' + content64;
	    // ③ 이벤트 ID 키
	    const evKey = (evtRaw.eventId || evtRaw.uuid) ? ('EVID|' + String(evtRaw.eventId ?? evtRaw.uuid)) : null;
	    // ④ 메시지 ID 키
	    const midKey = hasMsgId ? ('MID|' + msgIdNum) : null;

	    // seenInboxMsg는 "조회 + 저장"을 동시에 함.
	    // 첫 이벤트(프리뷰든 정상든)는 키들을 저장만 하고 통과,
	    // 뒤이어 오는 짝 이벤트는 여기서 true가 되어 바로 리턴 → 배지 +1이 한 번만 됨.
	    const dup =
	      seenInboxMsg(roomId, sigContent,       60000) ||
	      seenInboxMsg(roomId, sigSenderContent, 60000) ||
	      (evKey && seenInboxMsg(roomId, evKey,  60000)) ||
	      (midKey && seenInboxMsg(roomId, midKey,60000));

	    if (dup) return;
	  }
	}


    // 룸/인박스 교차 디듀프 + 짧은 윈도우 디듀프
    if (dedupeEvent(evtRaw)) return;
    if (!inboxDedupe(evtRaw)) return;

    // 메시지면 최근 메시지 시각 기록, 시스템 이벤트는 메시지 직후 2초 억제
    if (isMessage) {
      lastMsgSeenByRoom.set(roomId, Date.now());
    } else {
      const last = lastMsgSeenByRoom.get(roomId) || 0;
      if (Date.now() - last < 2000) return;
    }

    // 시스템 이벤트(멤버십 등): 현재 방 헤더 갱신 정도만
    if (!isMessage) {
      if (t === 'GROUP_MEMBER_LEFT' || t === 'GROUP_MEMBER_JOINED' || t === 'ROOM_MEMBER_UPDATE') {
        if (roomId === Number(chatroomId)) refreshMemberCount(chatroomId);
      }
      return;
    }

    const preview   = (evtRaw.preview ?? evtRaw.content ?? '') || '';
    const createdAt = evtRaw.createdAt ?? evtRaw.createDate ?? evtRaw.created_at ?? '';

    const $lists = getAllListsEl();
    const $item  = $lists.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');

    if ($item.length === 0) {
		loadDmList().then(function(){
		       // 목록은 서버 unreadCount로 이미 정확함. 여기서 추가 증가 금지.
		       if (window.updateDmPreview) {
		         // 정렬만 보장하고 싶으면 유지(사실 없어도 됨)
		         window.updateDmPreview(roomId, preview, createdAt, {reorder:true});
		       }
		     });
      return;
    }

    if (roomId !== chatroomId) {
      if (window.updateDmPreview) window.updateDmPreview(roomId, preview, createdAt, {reorder:true});
      incrementUnread(roomId);
    }
  }

  // ---- 방 토픽 핸들러(메시지 렌더 전담) ----
  function roomHandler(message){
    try {
      const evt = JSON.parse(message.body);
      const t = String(evt.type || evt.eventType || evt.kind || '').toUpperCase();

      // 멤버십 이벤트: 내가 그 방을 보고 있을 때만 헤더 갱신
      if (t === 'GROUP_MEMBER_LEFT' || t === 'GROUP_MEMBER_JOINED' || t === 'ROOM_MEMBER_UPDATE') {
        if (dedupeEvent(evt)) return;
        const rid = Number(evt.roomId || evt.chatroomId || 0);
        if (!chatroomId || (rid && rid !== Number(chatroomId))) return;

		     if (rtype !== 'GROUP') return;
        if (typeof evt.memberCount === 'number') {
          const $count = $('#room-members-count');
          const $word  = $('#room-members-word');
          $count.text(evt.memberCount);
          $word.text(evt.memberCount === 1 ? 'Member' : 'Members');
        } else {
          refreshMemberCount(chatroomId);
        }
        return;
      }

      // 일반 메시지 렌더
      appendMessage(evt);
    } catch(e){
      console.error('메시지 파싱 실패', e);
    }
  }

  // ---- API ----
  function loadMessages(roomId) {
    $.getJSON('/api/rooms/' + roomId + '/messages?limit=50', function(messages) {
      $('#chat-messages').empty();
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
    stompClient.send(appRead(chatroomId),
      { 'content-type': 'application/json' },
      JSON.stringify({ chatMessageId: lastMessageId })
    );
  }

  function updateSendBtn(){
    if ($sendBtn) $sendBtn.disabled = !(stompClient && stompClient.connected && chatroomId);
  }
  function setConnected(connected){
    if ($status) $status.textContent = connected ? '연결됨' : '연결 끊김 - 재시도 중...';
    updateSendBtn();
  }

  function connect() {
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
      stompClient = client;
      setConnected(true);

      // 이전 구독 해제
      try{ window[WS_KEY].subs.room?.unsubscribe(); }catch(e){}
      try{ window[WS_KEY].subs.read?.unsubscribe(); }catch(e){}

      if (chatroomId) {
        window[WS_KEY].subs.room = roomSub = client.subscribe(topicRoom(chatroomId), roomHandler);
        window[WS_KEY].subs.read = readSub = client.subscribe(topicRead(chatroomId), function(){});
      }

      // 인박스는 세션당 1개
      try{ window[WS_KEY].subs.inbox?.unsubscribe(); }catch(e){}
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

    if (window.updateDmPreview) {
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

    var roomId = (typeof window.CURRENT_ROOM_ID !== 'undefined' && window.CURRENT_ROOM_ID)
                   ? window.CURRENT_ROOM_ID
                   : (document.getElementById('chat-meta')?.dataset.roomId || null);

    if (!roomId) { alert('열린 채팅방이 없습니다.'); return; }
    if (!confirm('이 대화방을 나가시겠습니까?')) return;

    fetch('/api/rooms/' + roomId + '/leave', {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' }
    })
    .then(function(res){
      if (res.status === 204) {
        try { roomSub?.unsubscribe(); roomSub = null; } catch(e){}
        try { readSub?.unsubscribe(); readSub = null; } catch(e){}
        try { if (window.__CHAT_WS_SINGLETON__?.subs?.room) { window.__CHAT_WS_SINGLETON__.subs.room.unsubscribe(); window.__CHAT_WS_SINGLETON__.subs.room = null; } } catch(e){}
        try { if (window.__CHAT_WS_SINGLETON__?.subs?.read) { window.__CHAT_WS_SINGLETON__.subs.read.unsubscribe(); window.__CHAT_WS_SINGLETON__.subs.read = null; } } catch(e){}

        chatroomId = null;
        window.CURRENT_ROOM_ID = null;
        var metaEl = document.getElementById('chat-meta');
        if (metaEl) metaEl.setAttribute('data-room-id','');

        var $lists = getAllListsEl();
        $lists.find('.dm-item[data-room-id="'+roomId+'"]').closest('li').remove();

        $('#chat-messages').empty();
        showEmpty();
        updateSendBtn();

        loadDmList().catch(function(){});
        if (document.getElementById('chat-header-title')) {
          document.getElementById('chat-header-title').textContent = '채팅방을 선택하세요';
        }
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
    showEmpty();      // 빈 화면부터
    loadDmList();     // 좌측 목록 로딩
    connect();        // WS 연결(방 구독은 선택 후)
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

    clearUnread(roomId);
    applyRoomHeaderFromList(roomId);
    refreshMemberCount(roomId);

    if (window[WS_KEY].connected) {
      try{ roomSub?.unsubscribe(); }catch(e){} roomSub = null;
      try{ readSub?.unsubscribe(); }catch(e){} readSub = null;
      roomSub = window[WS_KEY].subs.room = window[WS_KEY].client.subscribe(topicRoom(chatroomId), roomHandler);
      readSub = window[WS_KEY].subs.read = window[WS_KEY].client.subscribe(topicRead(chatroomId), function(){});
    } else {
      connect();
    }
    $('.page-title-box h4').text('Chat Room #' + roomId);
    updateSendBtn();
    setTimeout(markReadIfNeeded, 50);
  };

  // 현재 방의 '읽지 않음' 배지 제거
  function clearUnread(roomId){
    var $lists = getAllListsEl();
    var $item = $lists.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');
    if ($item.length === 0) return;
    var $badge = $item.find('.dm-badge-unread');
    $badge.text('').hide();
  }

})(window, jQuery);

// ======================= Chat (DM 목록/클릭) =======================

function getContactsListEl() {
  return $('.chat-leftsidebar .chat-list').last();
}

function getAllListsEl() {
  return $('.chat-leftsidebar .chat-list');
}
function getGroupListEl() {
  var $lists = getAllListsEl();
  return $lists.length > 1 ? $lists.first() : $lists.last();
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
  var $dm  = getContactsListEl();
  var $grp = getGroupListEl();

  if ($grp[0] === $dm[0]) { $dm.empty(); }
  else { $grp.empty(); $dm.empty(); }

  if (!list || list.length === 0) {
    $dm.append('<li class="text-muted px-3">대화 상대가 없습니다.</li>');
    return;
  }

  var ctx = window.CONTEXT_PATH || '';

  list.forEach(function(item){
    var isGroup = String(item.roomType || '').toUpperCase() === 'GROUP';
    var name    = item.chatroomName || '(이름 없음)';
    var peerUserRank = isGroup ? '' : (item.peerUserRank || '');

    var avatar = window.DEFAULT_AVATAR;
    if (!isGroup && item.peerAvatarPath) {
      avatar = ctx + '/resources/images/users/' + item.peerAvatarPath;
    } else if (isGroup && item.groupAvatarPath) {
      try { var arr = JSON.parse(item.groupAvatarPath); if (Array.isArray(arr) && arr.length) avatar = arr[0]; } catch(e){}
    }

    var unread = (item.unreadCount != null ? Number(item.unreadCount) : 0);
    var when   = formatWhen(item.lastMessageAt || item.lastActivityAt || item.updatedAt || item.createdAt);
    var lastMsg= item.lastMessage ? String(item.lastMessage) : '';
    var unreadText = unread > 0 ? String(Math.min(99, unread)).padStart(2, '0') : '';
    var badgeHtml =
      '<span class="badge rounded-pill dm-badge-unread ms-2"' +
      (unread > 0 ? '' : ' style="display:none"') + '>' + unreadText + '</span>';

    var html =
      '<li>' +
        '<a href="#" class="d-flex align-items-center dm-item" ' +
          'data-room-id="'   + item.chatroomId      + '" ' +
          'data-room-type="' + (item.roomType || '') + '" ' +
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

    (isGroup ? $grp : $dm).append(html);
  });
}

function loadDmList() {
  return fetch('/api/rooms/dm', { credentials: 'same-origin' })
    .then(function(res){ if(!res.ok) throw new Error('HTTP '+res.status); return res.json(); })
    .catch(function(){ return []; })
    .then(function(dmList){
      return fetch('/api/rooms/group', { credentials: 'same-origin' })
        .then(function(res){ return res.ok ? res.json() : []; })
        .catch(function(){ return []; })
        .then(function(groupList){
          var list = [].concat(dmList || [], groupList || []);
          list.sort(function(a, b){
            function ts(x){ return new Date(String(x||'')).getTime() || 0; }
            var ai = ts(a.lastIncomingAt || a.last_message_at || a.lastMessageAt);
            var bi = ts(b.lastIncomingAt || b.last_message_at || b.lastMessageAt);
            if (ai !== bi) return bi - ai;
            var al = ts(a.lastMessageAt || a.lastActivityAt || a.updatedAt || a.createdAt);
            var bl = ts(b.lastMessageAt || b.lastActivityAt || b.updatedAt || b.createdAt);
            if (al !== bl) return bl - al;
            return (Number(b.chatroomId||0) - Number(a.chatroomId||0));
          });
          renderDmList(list);
          return list;
        });
    })
    .catch(function(err){
      console.error('목록 로딩 실패:', err);
      var $ul = getContactsListEl();
      $ul.empty().append('<li class="text-danger px-3">목록 로딩 실패</li>');
      return [];
    });
}

// 현재 방 외의 DM 항목 프리뷰/시간 갱신
function updateDmPreview(roomId, lastMsg, lastAt, opts) {
  opts = opts || {};
  var shouldReorder = !!opts.reorder;
  if (typeof window.CURRENT_ROOM_ID !== 'undefined' &&
      Number(roomId) === Number(window.CURRENT_ROOM_ID)) {
    shouldReorder = false;
  }

  var $lists = getAllListsEl();
  var $item  = $lists.find('.dm-item[data-room-id="' + roomId + '"]').closest('li');
  if ($item.length === 0) return;

  var when  = formatWhen(lastAt || '');
  $item.find('.dm-last').text(String(lastMsg || ''));
  $item.find('.dm-when').text(when);

  if (shouldReorder) $item.parent().prepend($item);
}

// (보조) 미확인 배지 증가
function incrementUnread(roomId) {
  var $lists = getAllListsEl();
  var $item  = $lists.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');
  if ($item.length === 0) return;
  var $badge = $item.find('.dm-badge-unread');
  if ($badge.length === 0) {
    var $h5 = $item.find('h5');
    $h5.after('<span class="badge rounded-pill dm-badge-unread ms-2">01</span>');
  } else {
    var n = parseInt($badge.text(), 10) || 0;
    n = Math.min(99, n + 1);
    $badge.text(String(n).padStart(2,'0')).show();
  }
  $item.parent().prepend($item);
}

// Contacts 항목 클릭 → 방 이동
$(document).on('click', '.dm-item', function(e){
  e.preventDefault();
  var roomId = $(this).data('room-id');
  if (roomId) window.openChatRoom(roomId);
});

function applyRoomHeaderFromList(roomId){
  var $item = $('.chat-leftsidebar .group-list .dm-item, .chat-leftsidebar .chat-list .dm-item')
                .filter('[data-room-id="'+ roomId +'"]').first();

  var $avatar = $('#room-avatar');
  var $title  = $('#room-title');

  var btnRename  = document.getElementById('action-rename-room');  // 이름 변경
   var $membersLink = $('#room-members-link');
   var $membersCnt  = $('#room-members-count');
   var $membersWord = $('#room-members-word');

  if ($item.length) {
    var name     = $item.data('peer-name')   || '채팅방';
    var rank     = $item.data('peer-rank')   || '';
    var avatar   = $item.data('peer-avatar') || window.DEFAULT_AVATAR;
    var roomType = String($item.data('room-type') || '').toUpperCase();

    $avatar.attr('src', avatar);
    $title.text(rank ? (name + ' ' + rank) : name);

    if (btnRename)  btnRename.classList.toggle('d-none',  roomType !== 'GROUP');
  } else {
    $avatar.attr('src', window.DEFAULT_AVATAR);
    $title.text('채팅방 #' + roomId);
    if (btnRename)  btnRename.classList.add('d-none');
	   // 방 정보를 못 찾으면 멤버 UI도 안전하게 감춤
	   $('#room-members-link').addClass('d-none').off('click');
	   $('#room-members-count').text('');
	   $('#room-members-word').text('');
  }
}

// 채팅패널 on/off
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
  try { window.__CHAT_WS_SINGLETON__?.subs?.room?.unsubscribe(); } catch(e){}
  try { window.__CHAT_WS_SINGLETON__?.subs?.read?.unsubscribe(); } catch(e){}
  try { window.__CHAT_WS_SINGLETON__?.subs?.inbox?.unsubscribe(); } catch(e){}
  try { window.__CHAT_WS_SINGLETON__?.client && window.__CHAT_WS_SINGLETON__.client.disconnect(()=>{}); } catch(e){}
  window.__CHAT_WS_SINGLETON__.subs = { room:null, read:null, inbox:null };
  window.__CHAT_WS_SINGLETON__.client = null;
  window.__CHAT_WS_SINGLETON__.connected = false;
  window.__CHAT_WS_SINGLETON__.connecting = false;
});

// ===== 멤버 목록 모달 & 헤더 멤버수 =====

// GROUP에서만 멤버수 표시/조회
async function refreshMemberCount(roomId){
  var $item = getAllListsEl().find('.dm-item[data-room-id="'+roomId+'"]').first();
  var type  = String($item.data('room-type') || '').toUpperCase();
  const isGroup = (type === 'GROUP'); // DM도 멤버 표시하므로 early return 제거

  const $link  = $('#room-members-link');
  const $count = $('#room-members-count');
  const $word  = $('#room-members-word');
  if (!$link.length || !$count.length || !roomId) return;

  $count.text('0');
  $word.text('Members');
  $link.css('cursor','pointer').attr('title','멤버 보기');
  
    // 중복/탈퇴/봇 제거 유틸
    function normalizeMembers(list){
      const byId = new Map();
      (list || []).forEach(u => {
        const id = Number(u.userId ?? u.id ?? u.chatroomUserId ?? 0);
        if (!id) return;
        const status = String(u.status ?? u.membershipStatus ?? '').toUpperCase();
        const left   = !!(u.leftAt || u.kickedAt || /LEFT|KICKED/.test(status));
        const isBot  = !!(u.isBot || /bot|system/i.test(String(u.fullName||'')));
        if (left || isBot) return;
        if (!byId.has(id)) byId.set(id, u);   // 중복 제거
      });
      let arr = Array.from(byId.values());
      // DM이면 혹시 서버가 잘못 3명 이상 주어도 2명으로 보정
      if (!isGroup && arr.length > 2) arr = arr.slice(0, 2);
      return arr;
    }

  try{
    const res = await fetch('/api/rooms/' + roomId + '/members', { credentials: 'same-origin' });
    if (res.status === 403) {
      $link.off('click').css('cursor','default').removeAttr('title');
      return;
    }
    if (!res.ok) throw new Error('HTTP ' + res.status);
	    const raw  = await res.json();
	    const list = normalizeMembers(raw);
	    const n    = list.length;

    $count.text(n);
    $word.text(n === 1 ? 'Member' : 'Members');

    $link.off('click').on('click', function(e){
      e.preventDefault();
      renderMembers(list);
      const el = document.getElementById('membersModal');
      const inst = (window.bootstrap && bootstrap.Modal)
        ? bootstrap.Modal.getOrCreateInstance(el)
        : null;
      if (inst) inst.show();
      else if (typeof $('#membersModal').modal === 'function') $('#membersModal').modal('show');
    });
  }catch(e){
    console.error('refreshMemberCount error:', e);
    $count.text('0');
    $word.text('Members');
  }
}

function renderMembers(list){
  var ctx = window.CONTEXT_PATH || '';
  var html = (list || []).map(function(u){
    var avatar = u.avatarPath ? (ctx + '/resources/images/users/' + u.avatarPath)
                              : (window.DEFAULT_AVATAR || '/resources/images/users/avatar-default.png');
    return (
      '<li class="list-group-item d-flex align-items-center">' +
        '<img src="'+ escapeHtml(avatar) +'" class="rounded-circle me-2" ' +
             'style="width:32px;height:32px;object-fit:cover;" alt="avatar">' +
        '<div class="flex-grow-1 text-truncate">' +
          '<div class="fw-semibold text-truncate">'+ escapeHtml(u.fullName || '') +'</div>' +
          (u.userRank ? '<small class="text-muted">'+ escapeHtml(u.userRank) +'</small>' : '') +
        '</div>' +
      '</li>'
    );
  }).join('');
  $('#membersList').html(html || '<li class="list-group-item text-muted">멤버 없음</li>');
}

// “멤버 목록 보기” 버튼(별도 UI)에서도 GROUP일 때만 동작
$(document).on('click', '#action-show-members', async function(e){
  e.preventDefault();

  var roomId = (typeof window.CURRENT_ROOM_ID !== 'undefined' && window.CURRENT_ROOM_ID)
             ? window.CURRENT_ROOM_ID
             : (document.getElementById('chat-meta')?.dataset.roomId || null);
  if (!roomId){ alert('열린 채팅방이 없습니다.'); return; }

  var $item = getAllListsEl().find('.dm-item[data-room-id="'+roomId+'"]').first();
  var type  = String($item.data('room-type') || '').toUpperCase();
  if (type !== 'GROUP') return;

  try{
    var res = await fetch('/api/rooms/' + roomId + '/members', { credentials: 'same-origin' });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    var list = await res.json();
    renderMembers(list);

    var el = document.getElementById('membersModal');
    var inst = (window.bootstrap && bootstrap.Modal) ? bootstrap.Modal.getOrCreateInstance(el) : null;
    if (inst) inst.show();
  }catch(err){
    console.error('멤버 로딩 실패:', err);
    alert('멤버 목록을 불러오지 못했습니다.');
  }
});

