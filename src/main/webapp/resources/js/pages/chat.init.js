/* =====================================================================
 * Chat init (drop-in)
 *  - 프로필 이미지가 바뀌면 사이드바/DM목록/채팅방 헤더까지 동기화
 * ===================================================================== */

/* 사이드바 로그인 영역 초기 동기화 */
(function syncLoginSidebar() {
  const meta  = document.getElementById('chat-meta')?.dataset || {};
  const name  = meta.userName || '';
  const rank  = meta.userRank || '';
  const ver   = meta.avatarVersion ? `?v=${meta.avatarVersion}` : '';
  const url   = (meta.avatarUrl && meta.avatarUrl.trim()) ? meta.avatarUrl : meta.avatarDefault;

  const nameEl   = document.getElementById('sidebar-login-name');
  const rankEl   = document.getElementById('sidebar-login-rank');
  const avatarEl = document.getElementById('sidebar-login-avatar');

  if (nameEl) nameEl.textContent = name || nameEl.textContent || 'Me';
  if (rankEl && rank) rankEl.textContent = `(${rank})`;
  if (avatarEl && url) avatarEl.src = url + ver;
})();

/* ✅ 같은 userId를 쓰는 모든 <img>의 아바타를 한번에 교체 */
window.patchAvatarAll = function (userId, avatarUrl, avatarVersion) {
  if (!userId || !avatarUrl) return;
  const bust = avatarVersion ? `?v=${avatarVersion}` : `?t=${Date.now()}`;
  const next = avatarUrl.replace(/\?.*$/, '') + bust;

  // 1) 모든 <img data-user-id="...">
  document.querySelectorAll(`img[data-user-id="${userId}"]`).forEach(img => { img.src = next; });

  // 2) DM 목록의 anchor 데이터셋 반영 + 썸네일 교체
  $(`.dm-item[data-peer-id="${userId}"]`)
    .attr('data-peer-avatar', next)
    .find('img[data-user-id="'+userId+'"]').attr('src', next);

  // 3) 현재 열려있는 방 헤더가 그 사용자면 교체
  const roomImg = document.getElementById('room-avatar');
  if (roomImg && String(roomImg.dataset.userId || '') === String(userId)) roomImg.src = next;

  // 4) 내가 바꾼 거면 사이드바 로그인 아바타도 교체
  const me = Number(document.getElementById('chat-meta')?.dataset.userId || 0);
  if (me && me === Number(userId)) {
    const meImg = document.getElementById('sidebar-login-avatar');
    if (meImg) meImg.src = next;
  }
};

/* 프로필 변경 콜백에서 호출(혹은 수동 호출) */
function updateMyAvatar(avatarUrl, avatarVersion){
  const me = Number(document.getElementById('chat-meta')?.dataset.userId || 0);
  if (!me) return;
  window.patchAvatarAll(me, avatarUrl, avatarVersion);
}

/* ✅ Topbar(헤더) 아바타 src 변경 자동 감지 → 전체 전파 (백업용) */
(function observeTopbarAvatar(){
  const topbar = Array.from(document.querySelectorAll('img.header-profile-user'))
                 .find(img => img.id !== 'room-avatar');
  if (!topbar) return;

  const me = Number(document.getElementById('chat-meta')?.dataset.userId || 0);
  const apply = () => {
    if (!me || !topbar.src) return;
    window.patchAvatarAll(me, topbar.src, Date.now());
  };

  apply(); // 최초 1회
  const mo = new MutationObserver((ml) => {
    if (ml.some(m => m.type==='attributes' && m.attributeName==='src')) apply();
  });
  mo.observe(topbar, { attributes: true, attributeFilter: ['src'] });
})();

/* ===================================================================== */

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

  const recentInbox = new Map();
  const recentEvt   = new Map();
  const lastMsgSeenByRoom = new Map();
  const inboxMsgSeen = new Map();
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
      if (evId) key = 'EID|' + evId;
      else if (msgId) key = 'MSG|' + roomId + '|' + msgId;
      else if (/GROUP_MEMBER|ROOM_MEMBER/.test(t)) key = 'MEM|' + roomId + '|' + (target || actor || 0) + '|' + t;
      else if (/READ/.test(t)) key = 'READ|' + roomId + '|' + actor + '|' + (evt?.lastMessageId ?? evt?.chatMessageId ?? '');
      else {
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
    } catch (e) { return false; }
  }

  // ---- 엘리먼트 & 메타 ----
  const $status  = document.getElementById('ws-status');
  const $sendBtn = document.getElementById('send-btn');
  const $input   = document.getElementById('chat-input');
  const $list    = document.getElementById('chat-messages');

  const meta        = document.getElementById('chat-meta')?.dataset || {};
  const __rawRoomId = (meta.roomId ?? '').trim();
  const initialRoomId = /^\d+$/.test(__rawRoomId) ? Number(__rawRoomId) : null; // 자동입장 막음
  let chatroomId    = null;
  const myUserId    = Number(meta.userId || 0);
  const ctx         = meta.contextPath || '';
  window.CONTEXT_PATH   = ctx;
  window.DEFAULT_AVATAR = meta.avatarDefault || '/resources/images/users/avatar-default.png';

  // ---- SimpleBar 스크롤 ----
  function resolveScroller() {
    const container = document.getElementById('messageScroll');
    if (window.SimpleBar) {
      if (container) {
        try {
          let sb = (SimpleBar.instances && SimpleBar.instances.get)
            ? SimpleBar.instances.get(container) : null;
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
  let currentRoomType = null;

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
    if (typeof msg.messageId === 'number') lastMessageId = Math.max(lastMessageId, msg.messageId);
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

    if (window.updateDmPreview) window.updateDmPreview(chatroomId, msg.content, msg.createdAt, {reorder:false});
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

  // ---- 인박스 핸들러 ----
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

    // ✅ 프리뷰/정상 메시지 묶어서 중복 배지 차단
    if (isMessage) {
      const content64 = String(evtRaw.preview ?? evtRaw.content ?? '').slice(0, 64);
      const senderId  = Number(evtRaw.senderUserId ?? evtRaw.userId ?? evtRaw.senderId ?? 0);
      const sig = [
        'SIGC|'  + content64,
        'SIGSC|' + senderId + '|' + content64,
        (evtRaw.eventId || evtRaw.uuid) ? ('EVID|' + String(evtRaw.eventId ?? evtRaw.uuid)) : null,
        hasMsgId ? ('MID|' + msgIdNum) : null
      ].filter(Boolean);
      for (const k of sig) if (seenInboxMsg(roomId, k, 60000)) return;
    }

    if (dedupeEvent(evtRaw)) return;
    if (!inboxDedupe(evtRaw)) return;

    if (isMessage) {
      lastMsgSeenByRoom.set(roomId, Date.now());
    } else {
      const last = lastMsgSeenByRoom.get(roomId) || 0;
      if (Date.now() - last < 2000) return;
    }

    // 프로필 업데이트 같은 시스템 이벤트를 받는다면 여기서 처리 가능
    if (t === 'USER_PROFILE_UPDATED') {
      window.patchAvatarAll(Number(evtRaw.userId||0), String(evtRaw.avatarUrl||''), evtRaw.avatarVersion);
      return;
    }

    const preview = (evtRaw.preview ?? evtRaw.content ?? '') || '';
    const createdAt = evtRaw.createdAt ?? evtRaw.createDate ?? evtRaw.created_at ?? '';

    const $lists = getAllListsEl();
    const $item  = $lists.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');
    currentRoomType = String($item.find('.dm-item').data('room-type') || '').toUpperCase();

    if ($item.length === 0) {
      loadDmList().then(function(){
        if (window.updateDmPreview) window.updateDmPreview(roomId, preview, createdAt, {reorder:true});
      });
      return;
    }

    if (roomId !== chatroomId) {
      if (window.updateDmPreview) window.updateDmPreview(roomId, preview, createdAt, {reorder:true});
      incrementUnread(roomId);
    }
  }

  // ---- 방 토픽 핸들러 ----
  function roomHandler(message){
    try {
      const evt = JSON.parse(message.body);
      const t = String(evt.type || evt.eventType || evt.kind || '').toUpperCase();

      if (t === 'GROUP_MEMBER_LEFT' || t === 'GROUP_MEMBER_JOINED' || t === 'ROOM_MEMBER_UPDATE') {
        if (dedupeEvent(evt)) return;
        const rid = Number(evt.roomId || evt.chatroomId || 0);
        if (!chatroomId || (rid && rid !== Number(chatroomId))) return;
        if (currentRoomType !== 'GROUP') return;

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

      appendMessage(evt);
    } catch(e){ console.error('메시지 파싱 실패', e); }
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

      try{ window[WS_KEY].subs.room?.unsubscribe(); }catch(e){}
      try{ window[WS_KEY].subs.read?.unsubscribe(); }catch(e){}

      if (chatroomId) {
        window[WS_KEY].subs.room = roomSub = client.subscribe(topicRoom(chatroomId), roomHandler);
        window[WS_KEY].subs.read = readSub = client.subscribe(topicRead(chatroomId), function(){});
      }

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

    if (window.updateDmPreview) window.updateDmPreview(chatroomId, content, new Date().toISOString(), {reorder:false});
    scrollToBottom();
  }

  // ---- 이벤트 ----
  $sendBtn && $sendBtn.addEventListener('click', sendMessage);
  $input && $input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  });
  window.addEventListener('focus', markReadIfNeeded);

  // 채팅방 나가기 (SweetAlert2)
  $(document).on('click', '#action-leave-room', async function(e){
    e.preventDefault();

    const roomId =
      (typeof window.CURRENT_ROOM_ID !== 'undefined' && window.CURRENT_ROOM_ID) ||
      (document.getElementById('chat-meta')?.dataset.roomId || null);

    if (!roomId) {
      Swal.fire({ title: '열린 채팅방이 없습니다.', icon: 'error', confirmButtonText: '확인', confirmButtonColor: '#34c38f' });
      return;
    }

    const result = await Swal.fire({
      title: '채팅방을 나가시겠습니까?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#34c38f',
      cancelButtonColor: '#f46a6a',
      confirmButtonText: '예',
      cancelButtonText: '아니요'
    });
    if (!result.isConfirmed) return;

    try {
      const res = await fetch(`/api/rooms/${roomId}/leave`, {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json' }
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);

      try { roomSub?.unsubscribe(); roomSub = null; } catch(e){}
      try { readSub?.unsubscribe(); readSub = null; } catch(e){}
      try { window.__CHAT_WS_SINGLETON__?.subs?.room?.unsubscribe(); } catch(e){}
      try { window.__CHAT_WS_SINGLETON__?.subs?.read?.unsubscribe(); } catch(e){}

      chatroomId = null;
      window.CURRENT_ROOM_ID = null;
      document.getElementById('chat-meta')?.setAttribute('data-room-id','');

      const $lists = getAllListsEl();
      $lists.find(`.dm-item[data-room-id="${roomId}"]`).closest('li').remove();

      $('#chat-messages').empty();
      showEmpty();
      if (typeof updateSendBtn === 'function') updateSendBtn();

      await loadDmList().catch(()=>{});

      Swal.fire({ title: '나갔습니다.', icon: 'success', confirmButtonText: '확인', confirmButtonColor: '#34c38f' });
    } catch (err) {
      console.error('leave error:', err);
      Swal.fire({ title: '나가기 실패', text: '잠시 후 다시 시도해주세요.', icon: 'error', confirmButtonText: '확인', confirmButtonColor: '#34c38f' });
    }
  });

  // ---- 부트 ----
  $(function () {
    showEmpty();
    loadDmList();
    connect();
  });

  // 🔵 방 전환
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

  function clearUnread(roomId){
    var $lists = getAllListsEl();
    var $item = $lists.find('.dm-item[data-room-id="'+roomId+'"]').closest('li');
    if ($item.length === 0) return;
    var $badge = $item.find('.dm-badge-unread');
    $badge.text('').hide();
  }

})(window, jQuery);

if (window.ChatNotify && typeof window.ChatNotify.clearBadge === 'function') {
  window.ChatNotify.clearBadge();
}

// ======================= Chat (DM 목록/클릭) =======================

function getContactsListEl() { return $('.chat-leftsidebar .chat-list').last(); }
function getAllListsEl() { return $('.chat-leftsidebar .chat-list'); }
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

/* ✅ DM/그룹 목록 렌더 (아바타에 peer-id/data-user-id 박음) */
function renderDmList(list) {
  var $dm  = getContactsListEl();
  var $grp = getGroupListEl();

  if ($grp[0] === $dm[0]) { $dm.empty(); }
  else { $grp.empty(); $dm.empty(); }

  if (!list || list.length === 0) {
    $dm.append('<li class="text-muted px-3">대화 상대가 없습니다.</li>');
    return;
  }

  list.forEach(function(item){
    var isGroup = String(item.roomType || '').toUpperCase() === 'GROUP';
    var name    = item.chatroomName || '(이름 없음)';
    var peerUserRank = isGroup ? '' : (item.peerUserRank || '');
    var peerId  = isGroup ? 0 : (item.peerUserId || 0); // ✅ 상대 id
    var avatar  = item.avatarUrl || (window.DEFAULT_AVATAR || '/resources/images/users/avatar-default.png');

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
          'data-peer-id="'   + peerId                + '" ' +         // ✅
          'data-peer-name="' + escapeHtml(name)     + '" ' +
          'data-peer-rank="' + escapeHtml(peerUserRank) + '" ' +
          'data-peer-avatar="'+ escapeHtml(avatar)  + '">' +
            '<div class="flex-shrink-0 me-3">' +
              '<div class="avatar-xs">' +
                '<img src="' + escapeHtml(avatar) + '" ' +
                     'class="rounded-circle avatar-img-fix" ' +
                     'data-user-id="' + peerId + '" ' +               // ✅
                     'alt="avatar" ' +
                     'onerror="this.onerror=null;this.src=\'' + (window.DEFAULT_AVATAR || '/resources/images/users/avatar-default.png') + '\'" />' +
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
  if (typeof window.CURRENT_ROOM_ID !== 'undefined' && Number(roomId) === Number(window.CURRENT_ROOM_ID)) {
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

  var btnRename  = document.getElementById('action-rename-room');
  var $membersLink = $('#room-members-link');
  var $membersCnt  = $('#room-members-count');
  var $membersWord = $('#room-members-word');

  if ($item.length) {
    var name     = $item.data('peer-name')   || '채팅방';
    var rank     = $item.data('peer-rank')   || '';
    var avatar   = $item.data('peer-avatar') || window.DEFAULT_AVATAR;
    var roomType = String($item.data('room-type') || '').toUpperCase();
    var peerId   = Number($item.data('peer-id') || 0);

    var fallback = window.DEFAULT_AVATAR || '/resources/images/users/avatar-default.png';
    $avatar.attr('src', avatar)
           .attr('data-user-id', peerId || '')
           .off('error').on('error', function(){ this.onerror=null; this.src = fallback; });

    $title.text(rank ? (name + ' ' + rank) : name);
    if (btnRename) btnRename.classList.toggle('d-none', roomType !== 'GROUP');
  } else {
    $avatar.attr('src', window.DEFAULT_AVATAR).removeAttr('data-user-id');
    $title.text('채팅방 #' + roomId);
    if (btnRename)  btnRename.classList.add('d-none');
    $('#room-members-link').addClass('d-none').off('click');
    $('#room-members-count').text('');
    $('#room-members-word').text('');
  }
}

// 채팅패널 on/off
const pane  = document.getElementById('chat-panel');
const empty = document.getElementById('chat-empty');
const send  = document.getElementById('send-btn');

function showEmpty(){ if (pane)  pane.classList.add('d-none'); if (empty) empty.classList.remove('d-none'); if (send)  send.disabled = true; }
function showPane(){  if (empty) empty.classList.add('d-none');   if (pane)  pane.classList.remove('d-none');  if (send)  send.disabled = false; }

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

/* ===== 멤버 목록 모달 & 헤더 멤버수 ===== */

async function refreshMemberCount(roomId){
  var $item = getAllListsEl().find('.dm-item[data-room-id="'+roomId+'"]').first();
  var type  = String($item.data('room-type') || '').toUpperCase();
  const isGroup = (type === 'GROUP');

  const $link  = $('#room-members-link');
  const $count = $('#room-members-count');
  const $word  = $('#room-members-word');
  if (!$link.length || !$count.length || !roomId) return;

  $count.text('0');
  $word.text('Members');
  $link.css('cursor','pointer').attr('title','멤버 보기');

  function normalizeMembers(list){
    const byId = new Map();
    (list || []).forEach(u => {
      const id = Number(u.userId ?? u.id ?? u.chatroomUserId ?? 0);
      if (!id) return;
      const status = String(u.status ?? u.membershipStatus ?? '').toUpperCase();
      const left   = !!(u.leftAt || u.kickedAt || /LEFT|KICKED/.test(status));
      const isBot  = !!(u.isBot || /bot|system/i.test(String(u.fullName||'')));
      if (left || isBot) return;
      if (!byId.has(id)) byId.set(id, u);
    });
    let arr = Array.from(byId.values());
    if (!isGroup && arr.length > 2) arr = arr.slice(0, 2);
    return arr;
  }

  try{
    const res = await fetch('/api/rooms/' + roomId + '/members', { credentials: 'same-origin' });
    if (res.status === 403) { $link.off('click').css('cursor','default').removeAttr('title'); return; }
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
    var avatar =
      u.avatarUrl ? u.avatarUrl :
      (u.avatarPath ? (ctx + '/resources/images/users/' + u.avatarPath)
                    : (window.DEFAULT_AVATAR || '/resources/images/users/avatar-default.png'));
    return (
      '<li class="list-group-item d-flex align-items-center">' +
        '<img src="'+ escapeHtml(avatar) +'" class="rounded-circle me-2" ' +
             'style="width:32px;height:32px;object-fit:cover;" alt="avatar" ' +
             'onerror="this.onerror=null;this.src=\'' + (window.DEFAULT_AVATAR || '/resources/images/users/avatar-default.png') + '\'">' +
        '<div class="flex-grow-1 text-truncate">' +
          '<div class="fw-semibold text-truncate">'+ escapeHtml(u.fullName || '') +'</div>' +
          (u.userRank ? '<small class="text-muted">'+ escapeHtml(u.userRank) +'</small>' : '') +
        '</div>' +
      '</li>'
    );
  }).join('');
  $('#membersList').html(html || '<li class="list-group-item text-muted">멤버 없음</li>');
}

// “멤버 목록 보기” 버튼(별도 UI) – GROUP에서만
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
