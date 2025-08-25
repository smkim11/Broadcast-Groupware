// resources/js/pages/chat-org.init.js
(function (window, $) {
  'use strict';

  // ---- 모듈 상태 ----
  const STATE = {
    ORG_TREE_RAW: [],
    selectedUsers: new Map()
  };

  // ---- 유틸 ----
  const escapeHtml = s => String(s||'').replace(/[&<>"]/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m]));
  function makeHiliter(q){
    const needle = (q||'').trim();
    if (!needle) return t => escapeHtml(t);
    const re = new RegExp('(' + needle.replace(/[.*+?^$()|[\]{}\\]/g,'\\$&') + ')','ig');
    return t => escapeHtml(t).replace(re,'<mark>$1</mark>');
  }
  const isUser = n => (String(n.kind||n.type||'').toUpperCase()==='USER') || (!!n.userId && !n.users && !n.children);
  const kids   = n => n.children || n.users || n.members || n.subs || n.teams || [];
  const userOf = n => ({ id: n.id ?? n.userId ?? n.empId ?? 0, name: n.name ?? n.fullName ?? n.username ?? '', rank: n.userRank ?? n.rank ?? n.title ?? '' });

  // ---- 칩 렌더 ----
  function renderSelectedChips(){
    const $box = $('#invite-selected').empty();
    if (STATE.selectedUsers.size === 0) {
      $box.append('<small class="text-muted">선택한 사용자가 여기에 표시됩니다.</small>');
      return;
    }
    STATE.selectedUsers.forEach(u=>{
      const $chip = $('<span>')
        .addClass('badge bg-primary-subtle text-primary border me-1 mb-1')
        .attr('data-id', u.id)
        .attr('style','border-radius:9999px; padding:.4rem .6rem; font-weight:600;')
        .text((u.name||'') + (u.rank ? ' ('+u.rank+')' : ''));
      $chip.append('<button type="button" class="btn-close ms-1 chip-remove" aria-label="Remove" style="width:.6em;height:.6em;opacity:.7;"></button>');
      $box.append($chip);
    });
  }
  $(document).on('click','#invite-selected .chip-remove',function(){
    const id = Number($(this).closest('[data-id]').data('id'));
    STATE.selectedUsers.delete(id);
	if (window.selectedUsers) window.selectedUsers.delete(id);
    $('#invite-modal-body .invite-user[data-id="'+id+'"]').prop('checked', false);
    renderSelectedChips();
  });
  $(document).on('change','#invite-modal-body .invite-user',function(){
    const $c=$(this);
    const u = { id:Number($c.data('id')), name:String($c.data('name')||''), rank:String($c.data('rank')||''), deptPath:String($c.data('dept')||'') };
    if ($c.is(':checked')) STATE.selectedUsers.set(u.id, u);
    else STATE.selectedUsers.delete(u.id);
	// 전역 Map도 동일하게 유지
	   window.selectedUsers = window.selectedUsers || new Map();
	   if ($c.is(':checked')) window.selectedUsers.set(u.id, u);
	   else window.selectedUsers.delete(u.id);
    renderSelectedChips();
  });

  // ---- 검색: 이름만 ----
  function hasMatchingUser(nodes, q){
    q = q.toLowerCase();
    return (nodes||[]).some(n => isUser(n) ? userOf(n).name.toLowerCase().includes(q) : hasMatchingUser(kids(n), q));
  }

  function renderTree(nodes, $parent, opts){
    opts = opts || { query:'', path:'' };
    const q = (opts.query||'').trim().toLowerCase();
    const hilite = makeHiliter(opts.query);

    (nodes||[]).forEach(n=>{
      if (isUser(n)){
        const u = userOf(n);
        if (q && !u.name.toLowerCase().includes(q)) return;

        const $li  = $('<li class="ms-3">');
        const $chk = $('<input type="checkbox" class="invite-user me-1">')
          .attr('data-id', u.id).attr('data-name', u.name).attr('data-rank', u.rank).attr('data-dept', opts.path||'');
        if (STATE.selectedUsers.has(u.id)) $chk.prop('checked', true);
        const $label = $('<label class="ms-1">').html(hilite(u.name) + (u.rank ? ' <small class="text-muted">(' + escapeHtml(u.rank) + ')</small>' : ''));
        $li.append($chk, $label);
        $parent.append($li);
      } else {
        const name = n.name || n.deptName || n.teamName || '';
        const children = kids(n);
        const ok = !q || hasMatchingUser(children, q); // 그룹명은 무시
        if (!ok) return;

        const $li = $('<li>');
        const $details = $('<details>');
        $details.append($('<summary>').text(name));
        const nextPath = (opts.path ? opts.path + ' / ' : '') + name;
        const $ul = $('<ul class="list-unstyled ms-3">');
        renderTree(children, $ul, { query: opts.query||'', path: nextPath });
        $details.append($ul);
        if (q) $details.attr('open', true);
        $li.append($details);
        $parent.append($li);
      }
    });
  }

  // ---- 검색 인풋 X버튼(클리어) ----
  $(function(){
    const $s = $('#inviteSearch');
    if ($s.length){
      $s.wrap('<div class="position-relative mb-2"></div>');
      const $btn = $('<button type="button" class="btn btn-sm position-absolute top-50 end-0 translate-middle-y me-2 text-muted" aria-label="Clear" style="line-height:1;">×</button>');
      $s.after($btn);
      $btn.on('click', function(){ $s.val(''); $s.trigger('input'); $s.focus(); });
    }
  });

  // ---- 디바운스 검색 ----
  const onSearch = (function(){ let t; return function(){
    clearTimeout(t);
    t = setTimeout(function(){
      const q = $('#inviteSearch').val() || '';
      const $root = $('#invite-modal-body').empty();
      renderTree(STATE.ORG_TREE_RAW, $root, { query:q });
    }, 200);
  };})();
  $(document).on('input','#inviteSearch', onSearch);

  // ---- 모달 열기/닫기 ----
  $(document).on('click','#open-invite', async function(e){
    e.preventDefault();
	e.stopImmediatePropagation(); // 다른 핸들러 차단
    try{
      const res = await fetch('/api/chat/org-tree', { credentials:'same-origin' });
      if(!res.ok) throw new Error('HTTP '+res.status);
      STATE.ORG_TREE_RAW = await res.json();

      // 초기화
      STATE.selectedUsers.clear();
	  window.selectedUsers = new Map();
      renderSelectedChips();
      $('#inviteSearch').val('');
      const $root = $('#invite-modal-body').empty();
      renderTree(STATE.ORG_TREE_RAW, $root, { query:'' });

      const el = document.getElementById('inviteModal');
      if (window.bootstrap?.Modal) new bootstrap.Modal(el).show();
      else if (typeof $('#inviteModal').modal === 'function') $('#inviteModal').modal('show');
    }catch(err){
      console.error('조직도 로딩 실패:', err);
      alert('조직도 로딩에 실패했습니다.');
    }
  });

  $('#inviteModal').on('hidden.bs.modal', function(){
    $('#inviteSearch').val('');
    $('#invite-modal-body').empty();
    STATE.selectedUsers.clear();
	window.selectedUsers = new Map();
    $('#invite-selected').empty().append('<small class="text-muted">선택한 사용자가 여기에 표시됩니다.</small>');
  });

})(window, jQuery);

// ======================= 조직도(DM 생성) =======================

// 전역 선택 상태(Map)는 이전 파일에서 만든 걸 재사용한다고 가정
window.selectedUsers = window.selectedUsers || new Map();

function getCsrfHeaders() {
  try {
    var tokenMeta  = document.querySelector('meta[name="_csrf"]');
    var headerMeta = document.querySelector('meta[name="_csrf_header"]');
    if (tokenMeta && headerMeta) {
      var h = {};
      h[headerMeta.getAttribute('content')] = tokenMeta.getAttribute('content');
      return h;
    }
  } catch (e) {}
  return {};
}

// “초대” 버튼: 1명 → DM 생성, 2명 이상 → 그룹방 생성(이름 입력)
$(document).on('click', '#invite-submit-btn', async function () {
  // 1) 선택된 사용자 ID 수집 (체크박스 우선, 없으면 전역 Map 보조)
  let ids = $('#invite-modal-body .invite-user:checked')
      .map(function(){ return Number($(this).data('id')); })
      .get();
    // DOM에서 사라진(필터로 숨겨진) 선택들도 반영
    if (window.selectedUsers && window.selectedUsers.size > 0) {
      ids = ids.concat(Array.from(window.selectedUsers.keys()));
    }
    // 중복 제거
    ids = Array.from(new Set(ids));
  if (ids.length === 0) { alert('선택된 사용자가 없습니다.'); return; }

  const headers = Object.assign({ 'Content-Type': 'application/json' }, getCsrfHeaders());

  try {
    // 2) 분기: 1명이면 DM, 2명 이상이면 그룹
    if (ids.length === 1) {
      const targetUserId = ids[0];
      const res = await fetch('/api/rooms/dm', {
        method: 'POST',
        headers,
        credentials: 'same-origin',
        body: JSON.stringify({ targetUserId })
      });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const room = await res.json(); // { chatroomId, alreadyExists, ... }

      if (room.alreadyExists) {
        alert('이미 해당 사용자와 1:1 채팅방이 있습니다. 기존 방으로 이동합니다.');
      }

      // 모달 닫기
      const modalEl = document.getElementById('inviteModal');
      const inst = (window.bootstrap && bootstrap.Modal) ? bootstrap.Modal.getInstance(modalEl) : null;
      if (inst) inst.hide();

      // DM 목록 갱신(있으면 한 번만)
      if (typeof window.loadDmList === 'function') await window.loadDmList();

      // 방 전환
      if (room && room.chatroomId && typeof window.openChatRoom === 'function') {
        window.openChatRoom(room.chatroomId);
      }
      return; // DM 분기 종료 (그룹 로직 타지 않도록)
    } else {
      // 여기서부터는 2명 이상(그룹) 분기
      const me = Number(document.getElementById('chat-meta')?.dataset.userId || 0);
      const memberIds = Array.from(new Set([me, ...ids]));

      // 2) 없으면 새 그룹 생성
      const roomName = prompt('그룹방 이름(선택):', '');
      if (roomName === null) return;

      const res = await fetch('/api/rooms/group', {
        method: 'POST',
        headers,
        credentials: 'same-origin',
        body: JSON.stringify({ roomName, memberIds })
      });

      // 3) (폴백) 서버가 중복 금지라 409를 주면 본문에서 existingRoomId 파싱해 이동 처리
	  if (res.status === 409) {
	    let msg = ''; try { msg = await res.text(); } catch {}
	    let rid = null; try { const j = JSON.parse(msg); rid = j.existingRoomId; } catch {}
	    if (rid) {
	      if (confirm('같은 멤버의 그룹채팅이 이미 있습니다. 해당 방으로 이동할까요?')) {
	        if (typeof window.openChatRoom === 'function') window.openChatRoom(rid);
	      }
	      return;
	    }
	    alert('같은 멤버의 그룹채팅이 이미 있습니다.');
	    return;
	  }

      if (!res.ok) throw new Error('HTTP ' + res.status);
      const data = await res.json(); // { roomId, roomName }

      // 모달 닫기
      const modalEl = document.getElementById('inviteModal');
      const inst = (window.bootstrap && bootstrap.Modal) ? bootstrap.Modal.getInstance(modalEl) : null;
      if (inst) inst.hide();

      // 목록 갱신 후 새 방으로 이동
      if (typeof window.loadDmList === 'function') await window.loadDmList();
      if (data && data.roomId && typeof window.openChatRoom === 'function') {
        window.openChatRoom(data.roomId);
      }
    }
  } catch (err) {
    console.error('초대 처리 실패:', err);
    alert('초대 처리 중 오류가 발생했습니다.');
  }
});
