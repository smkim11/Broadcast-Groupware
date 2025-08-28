(function (window, $) {
  'use strict';
  document.addEventListener('focusin', function (e) {
    // 모달이 떠 있고, 포커스가 스윗얼럿 컨테이너 안으로 들어오는 경우
    if (document.querySelector('.modal.show') && e.target.closest('.swal2-container')) {
      e.stopImmediatePropagation(); // 네이티브 stop, Bootstrap의 focusin 핸들러에 도달하지 못하게 함
    }
  }, true); // ← 반드시 capture=true

  const STATE = { selectedUsers: new Map() };

  // --- caret ---
  function setCaret(el, expanded){
    const caret = el.querySelector('.caret');
    if (!caret) return;
    caret.textContent = expanded ? '▾' : '▸';
  }
  function initCaret(){
    document.querySelectorAll('#invite-modal-body a.org-toggle').forEach(a=>{
      const target = document.querySelector(a.getAttribute('href'));
      const expanded = target && target.classList.contains('show');
      setCaret(a, expanded);
    });
  }
  document.addEventListener('shown.bs.collapse', e=>{
    const id = e.target.id;
    const toggle = document.querySelector(
      `#invite-modal-body a.org-toggle[aria-controls="${id}"], #invite-modal-body a.org-toggle[href="#${id}"]`
    );
    if (toggle) setCaret(toggle, true);
  });
  document.addEventListener('hidden.bs.collapse', e=>{
    const id = e.target.id;
    const toggle = document.querySelector(
      `#invite-modal-body a.org-toggle[aria-controls="${id}"], #invite-modal-body a.org-toggle[href="#${id}"]`
    );
    if (toggle) setCaret(toggle, false);
  });

  // --- 팀 체크 시 팀원 비활성 ---
  function setTeamUsersDisabled(teamId, disabled){
    document.querySelectorAll(`#invite-modal-body .user-chk[data-team-id="${teamId}"]`).forEach(chk=>{
      if (disabled) chk.checked = false;
      chk.disabled = disabled;
      const label = chk.closest('li.form-check')?.querySelector('label');
      if (label) label.classList.toggle('text-muted', disabled);
    });
  }
  document.addEventListener('change', function(e){
    if (e.target.classList.contains('team-chk')){
      setTeamUsersDisabled(e.target.dataset.teamId, e.target.checked);
    }
    if (e.target.classList.contains('user-chk')){
      const teamId = e.target.dataset.teamId;
      const teamChk = document.querySelector(`#invite-modal-body .team-chk[data-team-id="${teamId}"]`);
      if (teamChk && teamChk.checked) e.target.checked = false;
    }
  });

  // --- 선택 칩 동기화 ---
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
        .text(u.name + (u.rank ? ' ('+u.rank+')':'')); 
      $chip.append('<button type="button" class="btn-close ms-1 chip-remove" aria-label="Remove" style="width:.6em;height:.6em;opacity:.7;"></button>');
      $box.append($chip);
    });
  }
  $(document).on('change', '#invite-modal-body .user-chk', function(){
    const $c = $(this);
    const u = {
      id: Number($c.data('id')),
      name: String($c.data('name')||''),
      rank: String($c.data('rank')||'')
    };
    if ($c.is(':checked')) STATE.selectedUsers.set(u.id, u);
    else STATE.selectedUsers.delete(u.id);
    renderSelectedChips();
  });
  $(document).on('click', '#invite-selected .chip-remove', function(){
    const id = Number($(this).closest('[data-id]').data('id'));
    STATE.selectedUsers.delete(id);
    $(`#invite-modal-body .user-chk[data-id="${id}"]`).prop('checked', false).trigger('change');
  });

  // --- 모달 오픈/클로즈 ---
  $('#open-invite').on('click', function(e){
    e.preventDefault();

    // 0) 선택 칩/상태 초기화
    STATE.selectedUsers.clear();
    renderSelectedChips();

    // 1) 검색창 초기화(+ 숨김 복구 트리거)
    $('#inviteSearch').val('').trigger('input');

    const body = document.getElementById('invite-modal-body');

    // 혹시 남아있는 숨김 제거
    body.querySelectorAll('li.d-none').forEach(li => li.classList.remove('d-none'));

    // 체크박스 상태 초기화
    // 개인 체크 해제
    $('#invite-modal-body .user-chk').prop('checked', false).prop('disabled', false)
      .each(function(){
        // 라벨 text-muted 제거
        const label = this.closest('li.form-check')?.querySelector('label');
        if (label) label.classList.remove('text-muted');
      });

    // 팀 체크 해제 + 개인 비활성 해제
    $('#invite-modal-body .team-chk').each(function(){
      this.checked = false;
      setTeamUsersDisabled(this.dataset.teamId, false);
    });

    // 접힘/펼침 상태 기본값으로
    // 부서(dept-...): 접힘, 팀(team-...): 접힘
    body.querySelectorAll('ul[id^="dept-"]').forEach(ul => ul.classList.remove('show'));
    body.querySelectorAll('ul[id^="team-"]').forEach(ul => ul.classList.remove('show'));

    // 토글의 aria-expanded & caret 동기화
    body.querySelectorAll('a.org-toggle').forEach(a=>{
      const target = document.querySelector(a.getAttribute('href'));
      const expanded = !!(target && target.classList.contains('show'));
      a.setAttribute('aria-expanded', expanded ? 'true' : 'false');
      setCaret(a, expanded);
    });

    // 모달 오픈
    new bootstrap.Modal(document.getElementById('inviteModal')).show();
  });	
  
  $('#inviteModal').on('hidden.bs.modal', function(){
	  STATE.selectedUsers.clear();
	  $('#invite-selected').empty().append('<small class="text-muted">선택한 사용자가 여기에 표시됩니다.</small>');
	  $('#inviteSearch').val('').trigger('input');
	  $('#invite-modal-body .user-chk, #invite-modal-body .team-chk').prop('checked', false).prop('disabled', false);
	});

  // --- 검색 (IIFE 안으로 이동!) ---
  function norm(s){ return (s||'').toString().toLowerCase().trim(); }
  $('#inviteSearch').on('input', function(){
    const q = norm(this.value);
    const body = document.getElementById('invite-modal-body');

    body.querySelectorAll('li').forEach(li => li.classList.remove('d-none'));

    if (!q){
      body.querySelectorAll('ul[id^="team-"]').forEach(teamUl=>{
        teamUl.classList.remove('show');
        const toggle = body.querySelector(`a.org-toggle[href="#${teamUl.id}"]`);
        if (toggle) setCaret(toggle, false);
      });
      return;
    }

    body.querySelectorAll('ul[id^="team-"]').forEach(teamUl=>{
      const teamLi     = teamUl.closest('li');
      const teamToggle = body.querySelector(`a.org-toggle[href="#${teamUl.id}"]`);
      const teamName   = (teamToggle?.textContent || '');
      const teamMatch  = norm(teamName).includes(q);

      let userMatch = false;
      teamUl.querySelectorAll('li.form-check').forEach(userLi=>{
        const input = userLi.querySelector('input.user-chk');
        const hay = norm([
          input?.dataset.name,
          input?.dataset.rank,
          input?.dataset.dept,
          input?.dataset.team
        ].join(' '));
        const hit = teamMatch || hay.includes(q);
        userLi.classList.toggle('d-none', !hit);
        if (hit) userMatch = true;
      });

      const hasAny = teamMatch || userMatch;
      if (hasAny){
        teamUl.classList.add('show');
        if (teamToggle) setCaret(teamToggle, true);
        teamLi.classList.remove('d-none');
      } else {
        teamLi.classList.add('d-none');
        if (teamToggle) setCaret(teamToggle, false);
      }
    });

    body.querySelectorAll('ul[id^="dept-"]').forEach(deptUl=>{
      const deptLi = deptUl.closest('li');
	  const anyVisibleTeam = Array.from(deptUl.children)
	    .some(li => !li.classList.contains('d-none'));
      deptLi.classList.toggle('d-none', !anyVisibleTeam);
      if (anyVisibleTeam){
        deptUl.classList.add('show');
        const deptToggle = body.querySelector(`a.org-toggle[href="#${deptUl.id}"]`);
        if (deptToggle) setCaret(deptToggle, true);
      }
    });
  });

  // --- 초대 버튼 ---
  $(document).on('click', '#invite-submit-btn', async function () {
    // 1) 개인 체크 수집
    const idSet = new Set();
    $('#invite-modal-body .user-chk:checked').each(function(){
      const id = Number(this.dataset.id);
      if (id) idSet.add(id);
    });

    // 2) 팀 전체 체크 → 해당 팀의 모든 구성원 추가
    $('#invite-modal-body .team-chk:checked').each(function(){
      const $teamUl = $(this).closest('ul'); // 이 체크박스가 들어있는 팀 UL( team-... )
      $teamUl.find('.user-chk').each(function(){
        const id = Number(this.dataset.id);
        if (id) idSet.add(id);
      });
    });

    const ids = Array.from(idSet);
    if (ids.length === 0){ 
      alert('선택된 사용자가 없습니다.'); 
      return; 
    }

    const headers = { 'Content-Type':'application/json' };

    try{
      if (ids.length === 1){
        // ===== DM (기존 로직 유지) =====
        const res = await fetch('/api/rooms/dm', {
          method:'POST', headers, credentials:'same-origin',
          body: JSON.stringify({ targetUserId: ids[0] })
        });
        if (!res.ok) throw new Error('HTTP '+res.status);
        const room = await res.json();
        bootstrap.Modal.getInstance(document.getElementById('inviteModal'))?.hide();
        if (typeof window.loadDmList === 'function') await window.loadDmList();
        if (room?.chatroomId && typeof window.openChatRoom === 'function') window.openChatRoom(room.chatroomId);
        return;
      }

      // ===== GROUP (SweetAlert로 방 이름 입력 + 생성) =====
      const me = Number(document.getElementById('chat-meta')?.dataset.userId || 0);
      const memberIds = Array.from(new Set([me, ...ids]));
      Swal.fire({
        title: '그룹방 이름을 입력하세요',
        input: 'text',
        inputPlaceholder: '그룹방 이름 (선택)',
        inputAttributes: { maxlength: 50 },
        showCancelButton: true,
        confirmButtonText: '생성',
        cancelButtonText: '취소',
        confirmButtonColor: '#34c38f',
        cancelButtonColor: '#f46a6a',
        showLoaderOnConfirm: true,
        allowOutsideClick: () => !Swal.isLoading(),
		didOpen: (popup) => { popup.querySelector('input')?.focus(); },
		stopKeydownPropagation: true,
		keydownListenerCapture: true,
		
        // 여기서 바로 그룹 생성까지 처리(성공/409/에러)
        preConfirm: (val) => {
          const roomName = String(val || '').trim(); // 빈 값 허용(선택 항목)
          if (roomName.length > 50) {
            Swal.showValidationMessage('이름은 50자 이내여야 합니다.');
            return false;
          }
		  
          return fetch('/api/rooms/group', {
            method:'POST',
            headers,
            credentials:'same-origin',
            body: JSON.stringify({ roomName, memberIds })
          })
          .then(async (res) => {
            if (res.status === 409) {
              // 같은 멤버 조합의 방이 이미 존재
              let rid = null; 
              try { const j = await res.json(); rid = j.existingRoomId; } catch {}
              // 모달을 닫고 후속 confirm을 띄우기 위해 '성공값'으로 conflict 표식 반환
              return { conflict: true, existingRoomId: rid, roomName };
            }
            if (!res.ok) {
              let msg = ''; try { msg = await res.text(); } catch {}
              throw new Error(msg || `HTTP ${res.status}`);
            }
            // 정상 생성
            let data = {};
            try { data = await res.json(); } catch {}
            return { 
              conflict: false,
              roomId:   data.roomId || data.chatroomId,
              roomName: data.roomName || roomName
            };
          })
          .catch((err) => {
            Swal.showValidationMessage(err.message || '그룹 생성에 실패했습니다.');
          });
        }
      }).then(async (result) => {
        if (!result.isConfirmed) return;
        const v = result.value || {};

        // 409 충돌: 기존 방으로 이동 여부 확인
        if (v.conflict && v.existingRoomId) {
          const move = await Swal.fire({
            icon: 'info',
            title: '같은 멤버의 그룹채팅이 이미 있습니다.',
            text: '기존 방으로 이동할까요?',
            showCancelButton: true,
            confirmButtonText: '이동',
            cancelButtonText: '취소',
            confirmButtonColor: '#34c38f',
            cancelButtonColor: '#f46a6a'
          });
          if (move.isConfirmed) {
            bootstrap.Modal.getInstance(document.getElementById('inviteModal'))?.hide();
            if (typeof window.loadDmList === 'function') await window.loadDmList();
            if (typeof window.openChatRoom === 'function') window.openChatRoom(v.existingRoomId);
          }
          return;
        }

        // 정상 생성 완료
        if (v.roomId) {
          bootstrap.Modal.getInstance(document.getElementById('inviteModal'))?.hide();
          if (typeof window.loadDmList === 'function') await window.loadDmList();
          if (typeof window.openChatRoom === 'function') window.openChatRoom(v.roomId);

          Swal.fire({
            icon: 'success',
            title: '그룹방이 생성되었습니다.',
            confirmButtonColor: '#34c38f'
          });
        }
      });

    }catch(err){
      console.error(err);
      alert('초대 처리 중 오류가 발생했습니다.');
    }
  });

})(window, jQuery);
