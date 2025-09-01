// resilient chat-notify (waits for libs, always exports singleton)
(function (w) {
  'use strict';

  // ---- meta ----
  const metaEl = document.getElementById('app-meta') || document.getElementById('chat-meta');
  if (!metaEl) { console.warn('[chat-notify] no #app-meta'); return; }
  const meta = metaEl.dataset || {};
  const uid  = Number(meta.userId || 0);
  const ctx  = meta.contextPath || '';
  if (!uid)  { console.warn('[chat-notify] no userId'); return; }


  // ---- helpers
  function topicInbox(id){ return `/user/queue/inbox`; } // 서버가 /user/queue/inbox라면 여기만 바꾸면 됨
  const cache = new Map();
  function dedupe(key, ttl=60000){
    const now = Date.now(), last = cache.get(key);
    if (last && now-last < ttl) return true;
    cache.set(key, now);
    if (cache.size > 800) for (const [k,t] of cache) if (now-t > ttl*2) cache.delete(k);
    return false;
  }
  function sanitize(s){ return String(s||'').replace(/[&<>"]/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m])); }
  function incBadge(){
    const el = document.getElementById('nav-chat-badge'); if (!el) return;
    let n = parseInt(el.textContent, 10) || 0; n = Math.min(99, n + 1);
    el.textContent = String(n); el.style.display = '';
  }
  function currentRoomId(){
    if (typeof w.CURRENT_ROOM_ID !== 'undefined' && w.CURRENT_ROOM_ID) return Number(w.CURRENT_ROOM_ID);
    const rid = document.getElementById('chat-meta')?.dataset?.roomId;
    return /^\d+$/.test(rid||'') ? Number(rid) : null;
  }
  function showToast({ roomId, senderName, preview, avatar }){
    if (typeof w.Swal !== 'function') return; // 스윗알럿 없으면 콘솔만
    const html =
      `<div style="display:flex;gap:10px;align-items:center;max-width:320px">
         <img src="${sanitize(avatar || ctx + '/resources/images/users/avatar-default.png')}"
              style="width:36px;height:36px;border-radius:50%;object-fit:cover" alt="">
         <div style="min-width:0">
           <div style="font-weight:600" class="text-truncate">${sanitize(senderName || '메시지')}</div>
           <div class="text-truncate" style="opacity:.8">${sanitize(preview || '')}</div>
         </div>
       </div>`;
    Swal.fire({
      toast: true, position: 'bottom-end', html,
      showConfirmButton: false, timer: 6000, timerProgressBar: true,
      customClass: { popup: 'shadow' },
      didOpen: (t) => t.addEventListener('click', () => {
        location.href = `${ctx}/user/chat?chatroomId=${roomId}`;
      })
    });
  }

  function onInbox(frame){
    let e = {}; try { e = JSON.parse(frame.body || '{}'); } catch(_) {}
    const t = String(e.type || e.eventType || e.kind || '').toUpperCase();
    const roomId = Number(e.roomId ?? e.chatroomId ?? e.id ?? 0);
    const msgId  = String(e.messageId ?? e.chatMessageId ?? '');
    const preview= (e.preview ?? e.content ?? '').trim();
    const sender = e.senderName || e.fullName || e.userName || '';
    const avatar = e.senderAvatar || (e.avatarPath ? (ctx + '/resources/images/users/' + e.avatarPath) : '');

    const looksLikeMessage = !!preview && !/READ|TYPING|JOIN|LEFT|KICK|UPDATE/i.test(t);
    if (!roomId || !looksLikeMessage) return;

    const sig = `R${roomId}|M${msgId||''}|${preview.slice(0,64)}`;
    if (dedupe(sig, 60000)) return;
    if (currentRoomId() === roomId) return;

    incBadge();
    showToast({ roomId, senderName: sender, preview, avatar });
  }

  function connect(){
    if (w[KEY].connected || w[KEY].connecting) return;
    w[KEY].connecting = true;

    const socket = new SockJS(ctx + '/ws-stomp', null, { withCredentials:true });
    const client = (typeof Stomp !== 'undefined' ? Stomp : StompJs).over(socket);
    w[KEY].client = client;

    client.connect({}, () => {
      w[KEY].connecting = false; w[KEY].connected  = true;
      try { w[KEY].subs.inbox?.unsubscribe(); } catch(e){}
      w[KEY].subs.inbox = client.subscribe(topicInbox(uid), onInbox);
      console.log('[chat-notify] connected:', topicInbox(uid));
    }, (err) => {
      w[KEY].connecting = false; w[KEY].connected  = false;
      console.error('[chat-notify] stomp error', err);
      setTimeout(connect, 3000);
    });

    socket.onclose = () => { w[KEY].connected = false; };
  }

  // 라이브러리 올라올 때까지 기다렸다가 시작
  (function waitForLibs(tries=0){
    const ok = (typeof SockJS !== 'undefined') && (typeof Stomp !== 'undefined' || typeof StompJs !== 'undefined');
    if (ok) return connect();
    if (tries === 0) console.warn('[chat-notify] waiting for SockJS/Stomp…');
    if (tries > 40)  return console.error('[chat-notify] libraries missing');
    setTimeout(() => waitForLibs(tries+1), 250);
  })();

})(window);
