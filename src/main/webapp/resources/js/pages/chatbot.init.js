// /resources/js/pages/chatbot.init.js
(function initChat(){
  function ready(fn){
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn);
    else fn();
  }

  ready(function(){
    // ==== DOM ====
    const fab   = document.getElementById('koj-chat-fab');      // 떠있는 버튼
    const panel = document.getElementById('koj-chat-panel');    // 대화창
    const head  = panel?.querySelector('.chat-head');           // 패널 잡고 끄는 손잡이

    // 전송/입력/로그/닫기 요소도 잡아야 전송이 동작함
    const txt   = panel?.querySelector('#koj-chat-text');
    const send  = panel?.querySelector('#koj-chat-send');
    const logEl = panel?.querySelector('#koj-chat-log');
    const close = panel?.querySelector('#koj-chat-close');

    if(!fab || !panel || !head || !txt || !send || !logEl || !close){
      console.warn('[chatbot] elements not found'); return;
    }

    // ==== CSRF(있으면 사용) ====
    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // ------------------------------------------------------------
    // 1) 공통 유틸
    // ------------------------------------------------------------
    const clamp = (v, min, max) => Math.max(min, Math.min(max, v));

    function makeDraggable(el, handle, {onMove} = {}){
      handle = handle || el;
      let sx=0, sy=0, sl=0, st=0, dragging=false, moved=false;
      const key = 'drag:'+el.id;

      // 위치 복원
      try{
        const saved = JSON.parse(localStorage.getItem(key) || 'null');
        if(saved){
          el.style.left = saved.left+'px';
          el.style.top  = saved.top +'px';
          el.style.right='auto'; el.style.bottom='auto';
        }
      }catch(_){}

      function down(e){
        const r = el.getBoundingClientRect();
        el.style.left = r.left+'px';
        el.style.top  = r.top +'px';
        el.style.right='auto'; el.style.bottom='auto';

        sx = ('touches' in e? e.touches[0].clientX: e.clientX);
        sy = ('touches' in e? e.touches[0].clientY: e.clientY);
        sl = r.left; st = r.top; dragging=true; moved=false;

        document.addEventListener('mousemove', move);
        document.addEventListener('mouseup',   up);
        document.addEventListener('touchmove', move, {passive:false});
        document.addEventListener('touchend',  up);
        e.preventDefault();
      }
      function move(e){
        if(!dragging) return;
        const cx = ('touches' in e? e.touches[0].clientX: e.clientX);
        const cy = ('touches' in e? e.touches[0].clientY: e.clientY);
        const maxX = window.innerWidth  - el.offsetWidth;
        const maxY = window.innerHeight - el.offsetHeight;
        const left = clamp(sl + (cx - sx), 0, Math.max(0,maxX));
        const top  = clamp(st + (cy - sy), 0, Math.max(0,maxY));
        el.style.left = left+'px';
        el.style.top  = top +'px';
        moved = true;
        onMove && onMove(left, top);
        if('touches' in e) e.preventDefault();
      }
      function up(){
        if(!dragging) return;
        dragging=false;
        const left = parseFloat(el.style.left)||0;
        const top  = parseFloat(el.style.top)||0;
        localStorage.setItem(key, JSON.stringify({left, top}));
        document.removeEventListener('mousemove', move);
        document.removeEventListener('mouseup',   up);
        document.removeEventListener('touchmove', move);
        document.removeEventListener('touchend',  up);
      }
      handle.addEventListener('click', (e)=>{ /* 드래그 후 클릭 오작동 방지 */
        if(moved){ e.preventDefault(); e.stopPropagation(); moved=false; }
      }, true);
      handle.addEventListener('mousedown', down);
      handle.addEventListener('touchstart', down, {passive:false});
    }

    // ------------------------------------------------------------
    // 2) 패널을 버튼 옆에 배치
    // ------------------------------------------------------------
    function placePanelNextToFab(){
      const wasHidden = panel.classList.contains('hide');
      if(wasHidden){ panel.classList.remove('hide'); panel.style.visibility='hidden'; }

      const gap = 12;
      const fabRect   = fab.getBoundingClientRect();
      const panelRect = panel.getBoundingClientRect();
      const panelW = panelRect.width;
      const panelH = panelRect.height;

      let left = fabRect.left - gap - panelW;
      if(left < 0) left = fabRect.right + gap;
      let top  = fabRect.bottom - panelH;

      left = clamp(left, 0, window.innerWidth  - panelW);
      top  = clamp(top , 0, window.innerHeight - panelH);

      panel.style.left = left+'px';
      panel.style.top  = top +'px';
      panel.style.right='auto'; panel.style.bottom='auto';

      if(wasHidden){ panel.classList.add('hide'); panel.style.visibility=''; }
    }

    // ------------------------------------------------------------
    // 3) 열기/닫기 + 드래그 연동 (토글)
    // ------------------------------------------------------------
    fab.addEventListener('click', () => {
      const isOpen = !panel.classList.contains('hide');
      if (isOpen) {
        panel.classList.add('hide');
        fab.setAttribute('aria-expanded', 'false');
      } else {
        panel.classList.remove('hide');
        placePanelNextToFab();
        fab.setAttribute('aria-expanded', 'true');
        txt.focus();
      }
    });
    close.addEventListener('click', ()=> {
      panel.classList.add('hide');
      fab.setAttribute('aria-expanded', 'false');
    });

    makeDraggable(fab, null, { onMove(){ if(!panel.classList.contains('hide')) placePanelNextToFab(); } });
    makeDraggable(panel, head);
    window.addEventListener('resize', ()=>{ if(!panel.classList.contains('hide')) placePanelNextToFab(); });

    // ------------------------------------------------------------
    // 4)  전송 로직 추가 (이게 빠져 있어서 전송이 안 됐던 것)
    // ------------------------------------------------------------
    send.addEventListener('click', onSend);
    txt.addEventListener('keydown', (e)=>{
      if(e.key === 'Enter'){ e.preventDefault(); onSend(); }
    });

    function onSend(){
      const msg = (txt.value || '').trim();
      if(!msg) return;
      addMsg('user', msg);     // 사용자 말풍선
      txt.value = '';

      const t = msg.replace(/\s+/g,'');
      if(/[출근퇴근외근복귀]/.test(t)) return askAttendance(msg);  // 근태 API
      if(t.includes('날씨')) return addMsg('bot', '오늘의 날씨는 화창합니다. (데모)');
      addMsg('bot', '예) "이번달 외근 몇개", "어제 출근시간"');
    }

    // 말풍선/시간/escape
    function addMsg(who, text, html){
      const row = document.createElement('div');
      row.className = 'row ' + (who==='user' ? 'user' : 'bot');
      const bubble = document.createElement('div');
      bubble.className = 'bubble';
      if(html){ bubble.innerHTML = html; } else { bubble.textContent = text; }
      const time = document.createElement('div');
      time.className = 'time';
      time.textContent = nowStr();
      row.appendChild(bubble);
      row.appendChild(time);
      logEl.appendChild(row);
      logEl.scrollTop = logEl.scrollHeight;
    }
    function nowStr(){
      const d=new Date(), h=d.getHours(), m=String(d.getMinutes()).padStart(2,'0');
      return `${h<12?'오전':'오후'} ${(h%12)||12}:${m}`;
    }
    function escapeHtml(s){ return String(s).replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }

    // 근태 검색 API
    async function askAttendance(query){
		const API_BASE = window.location.origin + (window.CTX || '');
		
      try{
        const resp = await fetch((window.CTX||'') + '/api/search/attendance', {
          method:'POST',
          headers:{ 'Content-Type':'application/json', [CSRF_HEADER]: CSRF_TOKEN },
          credentials:'same-origin',
          body: JSON.stringify({ q: query })
        });
        if(!resp.ok){ addMsg('bot', `요청 실패: ${resp.status}`); return; }
        const data = await resp.json();
        if(!data.items || data.items.length===0){ addMsg('bot', '관련 근태 기록이 없습니다.'); return; }
        const top = data.items.slice(0,3);
        const html = `
          <div>관련 항목 ${data.count}건 중 상위 ${top.length}건입니다.</div>
          <ul>${top.map(it => `<li><a href="${it.url}">${escapeHtml(it.title)}</a></li>`).join('')}</ul>`;
        addMsg('bot','', html);
      }catch(e){
        console.error(e);
        addMsg('bot', '오류가 발생했습니다.');
      }
    }

    console.log('[chatbot] ready: panel follows fab & send works');
  });
})();
