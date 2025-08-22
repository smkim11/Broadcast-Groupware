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
    $('#invite-modal-body .invite-user[data-id="'+id+'"]').prop('checked', false);
    renderSelectedChips();
  });
  $(document).on('change','#invite-modal-body .invite-user',function(){
    const $c=$(this);
    const u = { id:Number($c.data('id')), name:String($c.data('name')||''), rank:String($c.data('rank')||''), deptPath:String($c.data('dept')||'') };
    if ($c.is(':checked')) STATE.selectedUsers.set(u.id, u);
    else STATE.selectedUsers.delete(u.id);
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
    try{
      const res = await fetch('/api/chat/org-tree', { credentials:'same-origin' });
      if(!res.ok) throw new Error('HTTP '+res.status);
      STATE.ORG_TREE_RAW = await res.json();

      // 초기화
      STATE.selectedUsers.clear();
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
    $('#invite-selected').empty().append('<small class="text-muted">선택한 사용자가 여기에 표시됩니다.</small>');
  });

  /*
  // ---- 초대 ----
  $('#invite-submit-btn').on('click', async function(){
    let ids = $('#invite-modal-body .invite-user:checked').map(function(){ return Number($(this).data('id')); }).get();
    if (ids.length === 0 && STATE.selectedUsers.size > 0) ids = Array.from(STATE.selectedUsers.keys());
    if (ids.length === 0) { alert('선택된 사용자가 없습니다.'); return; }

    const roomId = Number(document.getElementById('chat-meta')?.dataset.roomId || 1);
    const headers = { 'Content-Type': 'application/json' };
    const res = await fetch(`/api/rooms/${roomId}/invites`, { method:'POST', headers, body: JSON.stringify({ userIds: ids }) });
    if (!res.ok) { alert('초대에 실패했습니다.'); return; }

    const el = document.getElementById('inviteModal');
    const inst = window.bootstrap?.Modal.getInstance(el);
    if (inst) inst.hide();
  });
*/
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

// “초대” 버튼: 1명만 선택 → DM 생성
$(document).on('click', '#invite-submit-btn', async function(){
  let ids = $('#invite-modal-body .invite-user:checked').map(function(){
    return Number($(this).data('id'));
  }).get();

  if (ids.length === 0 && window.selectedUsers && window.selectedUsers.size > 0) {
    ids = Array.from(window.selectedUsers.keys());
  }
  if (ids.length === 0) { alert('선택된 사용자가 없습니다.'); return; }
  if (ids.length !== 1) { alert('지금은 1대1 대화만 지원합니다. 한 명만 선택해 주세요.'); return; }

  const targetUserId = ids[0];
  const headers = Object.assign({ 'Content-Type': 'application/json' }, getCsrfHeaders());

  try {
    const res = await fetch('/api/rooms/dm', {
      method: 'POST',
      headers,
      credentials: 'same-origin',
      body: JSON.stringify({ targetUserId })
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);

    const room = await res.json(); // { chatroomId, alreadyExists, ... }

    // 안내 메시지
    if (room.alreadyExists) {
      alert('이미 해당 사용자와 1:1 채팅방이 존재합니다. 기존 방으로 이동합니다.');
    }

    // 모달 닫기
    const modalEl = document.getElementById('inviteModal');
    const inst = (window.bootstrap && bootstrap.Modal) ? bootstrap.Modal.getInstance(modalEl) : null;
    if (inst) inst.hide();

    // DM 목록 한 번만 갱신
    if (typeof window.loadDmList === 'function') {
      await window.loadDmList();
    }

    // 방 전환 (chat.init.js에 정의된 전환 함수만 사용; 나머지 수동 재구독/히스토리 조작 삭제!)
    if (room && room.chatroomId && typeof window.openChatRoom === 'function') {
      window.openChatRoom(room.chatroomId);
    }
  } catch (err) {
    console.error('DM 생성 실패:', err);
    alert('DM 생성에 실패했습니다.');
  }
});
