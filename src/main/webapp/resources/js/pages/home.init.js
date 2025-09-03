//============================근태============================
(function(){
  // (초보자) DOM 준비되면 실행
  function ready(fn){ document.readyState === 'loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const wrap = document.getElementById('att-donuts');
    if (!wrap) return; // 섹션 없으면 종료

    // CSRF (GET이지만 전역정책 대비)
    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // 컨텍스트 경로(예: /app). JSP에서 window.CTX 세팅해둠
    const ctx    = window.CTX || '';
    const days   = 30;                         // 기준 일수
    const userId = wrap.dataset.userId || '';  // 관리자 화면이면 data-user-id 넣기

    // 호출 URL 만들기 (ctx가 ''여도 안전)
    const url = new URL(`${ctx}/api/attendance/summary`, window.location.origin);
    url.searchParams.set('days', days);
    if (userId) url.searchParams.set('userId', userId);

    fetch(url.toString(), {
      method: 'GET',
      credentials: 'same-origin',
      headers: { [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => { if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); })
    .then(data => renderAtt(normalize(data)))
    .catch(err => {
      console.error('[att] fetch error:', err);
      // 실패 시 기본값 표시
      safeText('att-in-time',    '--:--');
      safeText('att-out-time',   '--:--');
      safeText('att-field-time', '--:--');
    });

    // === 서버 응답을 화면용으로 정리(널이면 기본값) ===
    function normalize(p){
      const c = p?.counts || {};
      const t = p?.today  || {};
      return {
        days: Number(p?.days ?? days),
        inCount   : Number(c.checkin  ?? 0),
        outCount  : Number(c.checkout ?? 0),
        fieldCount: Number(c.field    ?? 0),
        inTime    : t.checkinTime  || '--:--',
        outTime   : t.checkoutTime || '--:--',
        fieldTime : t.fieldTime    || '--:--'     // 외근 시간 기본표시
      };
    }

    // === 렌더 ===
    function renderAtt(v){
      safeText('att-in-time',    v.inTime);
      safeText('att-out-time',   v.outTime);
      safeText('att-field-time', v.fieldTime);

      // 색상: CSS 변수 없을 때 대비 기본값 포함
      const colorSuccess = cssVar('--bs-success', '#28a745');
      const colorPrimary = cssVar('--bs-primary', '#0d6efd');
      const colorWarning = cssVar('--bs-warning', '#ffc107');

      // 중앙 텍스트(선택): "12/30" 형태 보여주기
      drawDonut('#att-donut-in',    v.inCount,    v.days, colorSuccess);
      drawDonut('#att-donut-out',   v.outCount,   v.days, colorPrimary);
      drawDonut('#att-donut-field', v.fieldCount, v.days, colorWarning);
    }

    // === 작은 유틸 ===
    function safeText(id, txt){ const el = document.getElementById(id); if (el) el.textContent = txt; }
    function cssVar(name, fallback=''){
      const v = getComputedStyle(document.documentElement).getPropertyValue(name).trim();
      return v || fallback;
    }

    // ───────────────── ApexCharts 도넛 ─────────────────
    function drawDonut(targetSel, value, max, color, centerText){
      const el = document.querySelector(targetSel);
      if (!el) return;

      const box = el.closest?.('.resv-donut') || el.parentElement || document.body;
      const cs  = getComputedStyle(box);
      const DONUT_HEIGHT = parseInt(cs.getPropertyValue('--donut-height')) || 110;
      const DONUT_HOLE   = (cs.getPropertyValue('--donut-hole') || '69%').trim();

      const done = Math.max(0, Math.min(Number(value||0), Number(max||0)));
      const rest = Math.max(0, Number(max||0) - done);
      const sDone = (done === 0 && rest > 0) ? 0.0001 : done; // 0% 렌더링 버그 회피

      const gray = cssVar('--bs-gray-300', '#dee2e6');

      const options = {
        chart:   { type: 'donut', height: DONUT_HEIGHT, sparkline: { enabled: true } },
        series:  [sDone, rest],
        labels:  ['완료','남음'],
        colors:  [color, gray],
        dataLabels: { enabled: false },
        stroke:     { width: 0 },
        legend:     { show: false },
        tooltip:    { enabled: false },
        plotOptions:{ pie: { donut: { size: DONUT_HOLE, labels: { show: false } } } }
      };

      if (el.__apex__) el.__apex__.destroy();
      const chart = new ApexCharts(el, options);
      chart.render();
      el.__apex__ = chart;

      // 중앙 텍스트 오버레이
      let center = el.querySelector('.att-center');
      if (!center) {
        center = document.createElement('div');
        center.className = 'att-center';
        // 간단 스타일(필요시 CSS로 옮겨도 됨)
        center.style.position = 'absolute';
        center.style.inset = '0';
        center.style.display = 'flex';
        center.style.alignItems = 'center';
        center.style.justifyContent = 'center';
        center.style.fontWeight = '600';
        el.style.position = 'relative';
        el.appendChild(center);
      }
      center.textContent = centerText || '';
    }
  });
})();

//============================휴가 관리============================
(function(){
  // DOMContentLoaded 유틸
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const badge   = document.getElementById('vac-year-note');
    const totalEl = document.querySelector('#vac-total .vac-chip-value');
    const remainEl= document.querySelector('#vac-remaining .vac-chip-value');
    const apprEl  = document.querySelector('#vac-approval .vac-tile-value');
    if(!badge || !totalEl || !remainEl || !apprEl) return;

    const y = new Date().getFullYear();
    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // 1) 데이터 로드 (백엔드 없으면 데모)
    fetch((window.CTX||'') + '/api/vacation/home-summary?year=' + y, {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .then(data => render(normalize(data, y)))
    .catch(err => console.error('[vacation] render error:', err));

    // 2) 데이터 표준화: 어떤 응답이 와도 {year,total,remaining,approval} 구조로 변환
    function normalize(p, year){
      return {
        year      : Number(p?.year ?? year),
        total     : Number(p?.total ?? p?.totals?.all ?? 0),
        remaining : Number(p?.remaining ?? p?.totals?.remaining ?? 0),
        approval  : Number(p?.approvalPending ?? p?.pending ?? 0)
      };
    }

    // 3) 렌더링
    function render(v){
      badge.textContent = `${v.year}년 기준 연차`;
      totalEl.textContent  = v.total;
      remainEl.textContent = v.remaining;
      apprEl.textContent   = v.approval;

      // 클릭 이동(옵션)
      document.querySelectorAll('#vac-rows [data-href]').forEach(el=>{
        el.addEventListener('click', ()=> location.href = el.getAttribute('data-href'));
        el.addEventListener('keydown', e=>{ if(e.key==='Enter') el.click(); });
      });
    }

  });
})();



//==========================================문서관리===============================
(function(){
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const rowsEl = document.getElementById('doc-rows');
    if(!rowsEl) return;

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // 1) 데이터 로드 (백엔드 없으면 데모)
    fetch((window.CTX||'') + '/api/docs/home-summary', {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .then(payload => render(payload))
    .catch(err => console.error('[docs] render error:', err));

    // 2) 렌더
    function render(p){
      // p 형태 허용: {counts:{PROGRESS:3,PENDING:3,DONE:3}} 또는 items:[{key,count},...]
      const counts = normalize(p);

      // 행 배열(표시 순서 고정)
      const rows = [
        { key:'PENDING',  label:'대기함',  icon:'mdi-archive-outline',  href:'/approval/received/pending'     },
        { key:'PROGRESS', label:'진행함',  icon:'mdi-archive-outline',  href:'/approval/documents/in-progress' },
        { key:'DONE',     label:'완료함',  icon:'mdi-archive-outline',  href:'/approval/documents/completed'        }
      ];

      rowsEl.innerHTML = rows.map(r => rowHtml(r, counts[r.key] || 0)).join('');

      // 클릭 시 해당 필터 페이지 이동
      rowsEl.querySelectorAll('.d-row[data-href]').forEach(el => {
        el.addEventListener('click', () => location.href = el.getAttribute('data-href'));
        el.addEventListener('keydown', e => { if(e.key==='Enter') el.click(); });
      });
    }

    function rowHtml(r, count){
      return `
        <div class="d-row" role="listitem" tabindex="0" data-href="${r.href}">
          <div class="d-icon"><i class="mdi ${r.icon}"></i></div>
          <div class="d-label">${esc(r.label)}</div>
          <div class="d-count">${Number(count)||0}</div>
        </div>`;
    }

    function normalize(p){
      const out = { PROGRESS:0, PENDING:0, DONE:0 };
      if (p && p.counts){
        Object.assign(out, {
          PROGRESS: Number(p.counts.PROGRESS ?? p.counts.IN_PROGRESS ?? 0),
          PENDING : Number(p.counts.PENDING  ?? 0),
          DONE    : Number(p.counts.DONE     ?? 0)
        });
      } else if (p && Array.isArray(p.items)){
        p.items.forEach(it => {
          const k = String(it.key||'').toUpperCase();
          if (k.includes('PROGRESS')) out.PROGRESS = Number(it.count||0);
          else if (k.includes('PENDING')) out.PENDING = Number(it.count||0);
          else if (k.includes('DONE')) out.DONE = Number(it.count||0);
        });
      }
      return out;
    }


    // 간단 XSS 방지
    function esc(s){ return String(s).replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
  });
})();



/* ================== 예약 ================== */
(function(){
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const el = {
      meeting: document.getElementById('donut-meeting'),
      edit   : document.getElementById('donut-edit'),
      vehicle: document.getElementById('donut-vehicle')
    };
    if (!el.meeting || !el.edit || !el.vehicle) return;

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // ★ 추가: 공통 이동 유틸 + 바인딩 함수
    function go(href){
      if (!href) return;
      window.location.href = href; // 새 탭이면: window.open(href, '_blank');
    }
    function wireClick(boxEl){
      if (!boxEl) return;
      const href = boxEl.dataset.href;
      if (!href) return;

      // 도넛 아무 곳이나 클릭 → 이동
      boxEl.addEventListener('click', function(){ go(href); });

      // 중앙 숫자 클릭 안정화를 위한 투명 앵커(중복 생성 방지)
      if (!boxEl.querySelector('.donut-center-link')){
        const a = document.createElement('a');
        a.className = 'donut-center-link';
        a.href = href;
        a.setAttribute('aria-label','상세 목록으로 이동');
        boxEl.appendChild(a);
      }
    }

    // 1) 데이터 로드
    fetch((window.CTX||'') + '/api/reservations/home-summary', {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .then(payload => {
      const getToday = key => {
        if (payload.totals && payload.totals[key] != null) return payload.totals[key];
        const s = (payload.series||[]).find(x => x.key === key || x.name === key);
        return s && Array.isArray(s.data) && s.data.length ? s.data[s.data.length-1] : 0;
      };

      renderDonut(el.meeting, getToday('MEETING'), '회의실', '#0d6efd');
      renderDonut(el.edit,    getToday('EDIT'   ), '편집실', '#6f42c1');
      renderDonut(el.vehicle, getToday('VEHICLE'), '차량'  , '#20c997');

      // ★ 추가: 렌더 후 클릭 연결
      wireClick(el.meeting);
      wireClick(el.edit);
      wireClick(el.vehicle);
    })
    .catch(err => console.error('[resv.donut] render fail:', err));

    // 2) 도넛 렌더러
    function renderDonut(target, count, label, color){
      const box = target.closest?.('.resv-donut') || target.parentElement || document.body;
      const cs  = getComputedStyle(box);
      const DONUT_HEIGHT   = parseInt(cs.getPropertyValue('--donut-height')) || 110;
      const DONUT_HOLE     = (cs.getPropertyValue('--donut-hole') || '69%').trim();
      const VALUE_FONTSIZE = (cs.getPropertyValue('--donut-font') || '20px').trim();

      // ★ 추가: box의 링크를 가져와 차트 이벤트에서도 이동
      const href = box?.dataset?.href || '';

      const opt = {
        chart:   {
          type: 'donut',
          height: DONUT_HEIGHT,
          sparkline: { enabled: true },
          // ★ 추가: ApexCharts 자체 클릭 이벤트 (조각/배경 클릭 모두 커버)
          events: {
            click: function(){ if (href) go(href); },
            dataPointSelection: function(){ if (href) go(href); }
          }
        },
        series:  [Number(count) || 0],
        labels:  [label],
        colors:  [color],
        legend:  { show: false },
        tooltip: { enabled: false },
        dataLabels: { enabled: false },
        stroke:   { width: 0 },
        plotOptions: { pie: { donut: {
          size: DONUT_HOLE,
          labels: {
            show: true,
            name:  { show: false },
            value: {
              show: true,
              fontSize: VALUE_FONTSIZE,
              fontWeight: 700,
              color: '#212529',
              formatter: () => String(Number(count) || 0)
            },
            total: { show: false }
          }
        } } }
      };

      if (target.__apex__) target.__apex__.destroy();
      const chart = new ApexCharts(target, opt);
      chart.render();
      target.__apex__ = chart;
    }
  });
})();


// ================================= 일정 ==================================
document.addEventListener('DOMContentLoaded', async function () {
  const wrap = document.getElementById('home-agenda-rows');
  const card = document.getElementById('home-agenda-card');
  if (!wrap || !card) return;

  const ctx = window.APP_CTX
    || document.querySelector('meta[name="ctx"]')?.content
    || document.body.getAttribute('data-context-path')
    || '';

  const userId = document.getElementById('event-login-user')?.value || '';

  // ---- 유틸 ---------------------------------------------------
  const yoil=['일','월','화','수','목','금','토'];
  const pad = n => String(n).padStart(2,'0');

  const startOfMonth = d => new Date(d.getFullYear(), d.getMonth(),   1, 0,0,0,0);
  const endOfMonth   = d => new Date(d.getFullYear(), d.getMonth()+1, 0, 23,59,59,999);

  const timeRangeText = (ev) => {
    if (!ev.start || !ev.start.includes('T')) return '종일';
    const s=new Date(ev.start), e=ev.end?new Date(ev.end):null;
    let t=`${pad(s.getHours())}:${pad(s.getMinutes())}`;
    if (e && e.getTime()!==s.getTime()) t+=`~${pad(e.getHours())}:${pad(e.getMinutes())}`;
    return t;
  };

  const typeBadgeClass = t => t==='개인'?'bg-info'
                           : t==='팀'  ?'bg-success'
                           : t==='전체'?'bg-warning'
                           : 'bg-secondary';

  const escapeHtml = (s='') =>
    s.replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));

  async function fetchJson(url){
    try{
      const r = await fetch(url, {credentials:'same-origin'});
      const ct = r.headers.get('content-type') || '';
      if (!r.ok || !ct.includes('application/json')) return [];
      return await r.json();
    }catch(_){ return []; }
  }

  const mapApi = x => ({
    id: String(x.calendarId),
    title: x.calendarTitle,
    start: x.calendarStartTime,
    end:   x.calendarEndTime || null,
    extendedProps: {
      userId: x.userId,
      type: x.calendarType || '기타',
      memo: x.calendarMemo || '',
      location: x.calendarLocation || ''
    }
  });

  function inThisMonth(ev, now){
    const s = new Date(ev.start);
    const e = ev.end ? new Date(ev.end) : s;
    const m0 = startOfMonth(now);
    const m1 = endOfMonth(now);
    return s <= m1 && e >= m0; // 월과 겹치면 포함
  }

  // 공지사항 카드처럼 행 형태로 렌더 (최대 4개) → 문서 카드 스타일로 변경
  // 아이콘: fs-1로 크기 키우기, mb-2로 아래 여백
  // 아이콘 아래 텍스트
  function renderTop4(list){
    if (!list.length){
      wrap.innerHTML = `
	  <div class="d-flex flex-column align-items-center justify-content-center text-center py-4"> 
	         <i class="uil uil-github-alt fs-1 mb-2" aria-hidden="true"></i>
	         <div class="text-muted" style="margin-top:0.34rem">이번 달 일정이 없습니다.</div>
	       </div>`;
	  return;
    }

    wrap.innerHTML = list.slice(0,4).map(ev=>{
      const s = new Date(ev.start);
      const dateStr = `${s.getMonth()+1}/${s.getDate()}`;
      const timeStr = timeRangeText(ev);
      const type    = ev.extendedProps.type;
      const memo    = (ev.extendedProps.memo && ev.extendedProps.memo.trim())
                        ? ev.extendedProps.memo : (ev.title || '(제목없음)');
      const key     = ev.__key;

      return `
        <div class="a-row" role="listitem" tabindex="0" data-key="${key}">
          <div class="a-badge"><span class="badge ${typeBadgeClass(type)}">${type}</span></div>
          <div class="a-title" title="${escapeHtml(memo)}">${escapeHtml(memo)}</div>
          <div class="a-date">${dateStr}</div>
          <div class="a-time">${timeStr}</div>
        </div>`;
    }).join('');

    // 클릭 → 상세 모달(읽기 전용)
    wrap.querySelectorAll('.a-row').forEach(row=>{
      row.addEventListener('click', ()=>{
        const key = row.getAttribute('data-key');
        const ev = cache.find(x => x.__key === key);
        if (ev) openReadonlyModal(ev);
      });
      row.addEventListener('keydown', e => { if(e.key === 'Enter') row.click(); });
    });
  }

  function openReadonlyModal(ev){
    if (typeof eventClicked==='function' && document.getElementById('event-modal')){
      eventClicked();
      const fmt=d=>`${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
      document.getElementById('modal-title').textContent='일정상세';
      document.getElementById('eventid').value=ev.id;
      document.getElementById('event-title').value=ev.title||'';
      document.getElementById('event-location').value=ev.extendedProps.location||'';
      const sel=document.getElementById('event-type'), read=document.getElementById('event-type-read');
      if (sel&&read){ sel.style.display='none'; read.type='text'; read.readOnly=true; read.value=ev.extendedProps.type||''; }
      const s=new Date(ev.start), e=ev.end?new Date(ev.end):s;
      document.getElementById('event-start-time').value=fmt(s);
      document.getElementById('event-end-time').value=fmt(e);
      document.getElementById('event-memo').value=ev.extendedProps.memo||'';
      document.getElementById('edit-event-btn')?.setAttribute('hidden',true);
      document.getElementById('btn-delete-event')?.setAttribute('hidden',true);
      document.getElementById('btn-save-event')?.setAttribute('hidden',true);
      new bootstrap.Modal(document.getElementById('event-modal')).show();
      return;
    }
  }

  // ---- 데이터 로드 ---------------------------------------------------
  wrap.innerHTML = `<div class="text-muted">불러오는 중...</div>`;

  const base = (ctx && ctx !== '/') ? ctx.replace(/\/+$/,'') : '';
  const q = `?userId=${encodeURIComponent(userId)}`;
  const urls = [
    `${base}/selectPersonalCalendar${q}`,
    `${base}/selectTeamCalendar${q}`,
    `${base}/selectTotalCalendar${q}`
  ];

  const [personal, team, total] = await Promise.all(urls.map(fetchJson));
  const cache = [...personal, ...team, ...total].map(mapApi);

  const now = new Date();
  const month = cache.filter(ev => ev.start && inThisMonth(ev, now));

  // 중복 제거: (id + 시작시각)
  const uniqMap = new Map();
  month.forEach(ev=>{
    const key = `${ev.id}|${ev.start}`;
    if (!uniqMap.has(key)){
      ev.__key = key;
      uniqMap.set(key, ev);
    }
  });

  // 최신순(시작일 내림차순)
  const sorted = Array.from(uniqMap.values())
    .sort((a,b)=> new Date(b.start) - new Date(a.start));

  renderTop4(sorted);
});


// ============================공지사항 ============================
(function(){
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const card    = document.getElementById('home-notice-card');   // data-board-id 읽기
    const rowsEl  = document.getElementById('home-notice-rows');
    const emptyEl = document.getElementById('home-notice-empty');
    if (!rowsEl) return;

    // 컨텍스트/CSRF
    const ctx = (window.CTX
      || document.querySelector('meta[name="ctx"]')?.content
      || document.body.getAttribute('data-context-path')
      || '').trim();
    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // 특정 보드만 보기(옵션)
    const boardIdAttr = card?.getAttribute('data-board-id');
    const boardId = boardIdAttr && boardIdAttr.trim() ? Number(boardIdAttr) : null;

    const LIMIT = 4;

    // ---- 데이터 로드
    const params = new URLSearchParams({ limit: String(LIMIT) });
    if (boardId) params.set('boardId', String(boardId));

    fetch(`${ctx}/api/notices/home-top?` + params.toString(), {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .then(list => render(list))
    .catch(err => { console.error('[home-notice] fetch fail:', err); showEmpty(); });

	// ---- 렌더 (컬럼: n-badge | n-title | n-date | n-time)
	function render(list){
	  if (!Array.isArray(list) || list.length === 0) { showEmpty(); return; }
	  emptyEl?.classList.add('d-none');

	  rowsEl.innerHTML = list.slice(0, LIMIT).map(row => {
	    // row: postId, postTitle, userName, createDate, topFixed('Y'/'N')
	    const href   = detailUrl(row);
	    const title  = esc(row.postTitle || '제목 없음');
	    const dStr   = fmtDate(row.createDate); // yyyy.MM.dd
	    const tStr   = fmtTime(row.createDate); // HH:mm

	    // ★ topFixed 'Y'면 긴급, 아니면 일반 배지 (항상 표시)
	    const top = (row.topFixed || 'N'); // null 안전
	    const badgeHtml = (top === 'Y')
	      ? `<span class="badge bg-danger">긴급</span>`
	      : `<span class="badge bg-secondary">일반</span>`;

	    return `
	      <a class="n-row text-reset text-decoration-none"
	         role="listitem"
	         href="${escAttr(href)}"
			 target="_blank"                      
			 rel="noopener noreferrer" 
	         data-href="${escAttr(href)}"
	         title="${escAttr(row.postTitle||'')}">
	        <div class="n-badge">${badgeHtml}</div>
	        <div class="n-title" title="${escAttr(row.postTitle||'')}">${title}</div>
	        <div class="n-date">${esc(dStr)}</div>
	        <div class="n-time">${esc(tStr)}</div>
	      </a>`;
	  }).join('');

	  // 자식 클릭 오동작 방지용
	  rowsEl.addEventListener('click', function(e){
	    const a = e.target.closest('a.n-row');
	    if (!a) return;

	    // ★ 새 탭 조건이면 브라우저 기본 동작 유지
	    const tgt = a.getAttribute('target');
	    if (tgt === '_blank' || e.ctrlKey || e.metaKey || e.button === 1) {
	      return; // 기본 동작 = 새 탭 열림
	    }

	    // 같은 탭으로 강제 이동이 필요할 때만 남겨둠 (원하면 이 부분 삭제 가능)
	    e.preventDefault();
	    window.location.href = a.getAttribute('href');
	  });

	  // "더보기" 링크 세팅
	  const moreLink = card?.querySelector('[data-role="more-link"]');
	  if (moreLink) moreLink.href = moreUrl();
	}


    function showEmpty(){
      rowsEl.innerHTML = '';
      emptyEl?.classList.remove('d-none');
    }

    // ---- 라우팅
    function detailUrl(row){
		const bid = (row.boardId != null ? row.boardId : boardId);
		  let url = `${ctx}/post/detail?postId=${encodeURIComponent(row.postId)}`;
		  if (bid != null) url += `&boardId=${encodeURIComponent(bid)}`;
		  return url;
    }
    function moreUrl(){
      return boardId ? `${ctx}/board/${boardId}/list`
                     : `${ctx}/post/list`;
    }

    // ---- 유틸
    function fmtDate(iso){
      if (!iso) return '';
      const d = new Date(iso);
      if (Number.isNaN(d.getTime())) return String(iso).slice(0,10).replaceAll('-','.');
      const y=d.getFullYear(), m=String(d.getMonth()+1).padStart(2,'0'), da=String(d.getDate()).padStart(2,'0');
      return `${y}.${m}.${da}`;
    }
    function fmtTime(iso){
      if (!iso) return '';
      const d = new Date(iso);
      if (Number.isNaN(d.getTime())) return '';
      const h=String(d.getHours()).padStart(2,'0'), mi=String(d.getMinutes()).padStart(2,'0');
      return `${h}:${mi}`;
    }
    function esc(s){ return String(s).replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
    function escAttr(s){ return esc(s).replace(/'/g,'&#39;'); }
  });
})();



// ============================ [시청률] ============================
(function(){
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const chartEl = document.getElementById('rating-chart');
    const listEl  = document.getElementById('rating-list');
    if(!chartEl || !listEl) return;

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';
    const ctx         = window.CTX || '';
    const DAYS        = 1;
    const TOP_N       = 4; // 상위 N개만 표시

    // 1) 데이터 로드 (없으면 데모)
    fetch(`${ctx}/api/ratings/home-summary?days=${DAYS}`, {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .catch(() => demoRatings())
    .then(raw => render(normalize(raw)))
    .catch(err => console.error('[ratings] render error:', err));

    // 2) 응답 표준화 → [{name, value}] 높은 순 TOP_N
    function normalize(p){
      // 허용 형태: {items:[{program|name, rating|value}]}
      //          또는 {labels:[...], series:[{data:[...]}]}
      let items = [];
      if (Array.isArray(p?.items)) {
        items = p.items.map(x => ({
          name:  x.program || x.name || '프로그램',
          value: Number(x.rating ?? x.value ?? 0)
        }));
      } else if (Array.isArray(p?.labels) && Array.isArray(p?.series?.[0]?.data)) {
        items = p.labels.map((nm, i) => ({
          name:  String(nm || '프로그램'),
          value: Number(p.series[0].data[i] ?? 0)
        }));
      }

      // 내림차순 정렬 후 상위 N개
      items.sort((a,b) => b.value - a.value);
      return items.slice(0, TOP_N);
    }

    // 3) 렌더 (그래프 + 아래 리스트)
    function render(items){
      if (!items.length){
        chartEl.innerHTML = '<div class="text-muted">데이터가 없습니다.</div>';
        listEl.innerHTML  = '';
        return;
      }

      // 색상 팔레트 (부트스트랩 변수 우선 사용)
      const colors = [
        getCss('--bs-primary') || '#0d6efd',
        '#6f42c1',                           // purple
        getCss('--bs-success') || '#198754',
        getCss('--bs-warning') || '#ffc107',
        getCss('--bs-info')    || '#0dcaf0'
      ].slice(0, items.length);

      // ---- 그래프 (가로 막대)
      const height = 1 + items.length * 18; // 항목 수에 따른 높이
      const options = {
        chart:   { type: 'bar', height, toolbar: { show:false }, sparkline:{enabled:true} },
        series:  [{ name: '시청률', data: items.map(x => x.value) }],
        xaxis:   { labels: { show:false }, axisTicks:{show:false}, axisBorder:{show:false}, max: Math.max(10, Math.ceil(Math.max(...items.map(x=>x.value)) / 5) * 5) },
        yaxis:   { labels: { show:false } },
        plotOptions: {
          bar: { horizontal: true, barHeight: '60%', distributed:true }
        },
        dataLabels: {
          enabled: true,
          formatter: val => `${val.toFixed(1)}%`,
          offsetX: 6,
          style: { fontWeight: 700 }
        },
        colors,
        tooltip: { y: { formatter: v => `${v.toFixed(1)}%` } },
        grid: { show:false }
      };

      if (chartEl.__apex__) chartEl.__apex__.destroy();
      const chart = new ApexCharts(chartEl, options);
      chart.render();
      chartEl.__apex__ = chart;

      // ---- 리스트 (색 점 + 제목 + 값)
	   listEl.classList.add('rating-2col');     // ← 2열 스타일 적용
	  listEl.innerHTML = items.map((x,i)=>`
	    <div class="legend-item">
	      <div class="legend-left">
	        <span class="legend-dot" style="background:${colors[i] || '#999'}"></span>
	        <span class="legend-name">${esc(x.name)}</span>
	      </div>
	      <strong>${x.value.toFixed(1)}%</strong>
	    </div>
	  `).join('');
    }

    // 4) 데모
    function demoRatings(){
      return {
        items: [
          { name:'9시 뉴스',     rating: 12.3 },
          { name:'정오 뉴스',     rating: 9.8  },
          { name:'다큐 스페셜',   rating: 8.4  },
          { name:'저녁 토크쇼',   rating: 7.2  },
          { name:'주간 시사',     rating: 6.6  },
          { name:'스포츠 하이라이트', rating: 5.5 }
        ]
      };
    }

    // 유틸
    function getCss(varName){
      return getComputedStyle(document.documentElement).getPropertyValue(varName).trim();
    }
    function esc(s){ return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[m])); }
    function escAttr(s){ return esc(s).replace(/'/g,'&#39;'); }
  });
})();


//================================= 긴급 공지 나오면 애니메이션 =====================
document.addEventListener('DOMContentLoaded', function () {
  // ====== 설정값 ======
  const SPEED = 100;                  // 스크롤 속도(px/s)
  const HIDE_HOURS = 12;              // 닫은 후 숨김 지속시간(시간)

  // ====== 엘리먼트 ======
  const root  = document.getElementById('urgent-ticker');
  if (!root) return;                  // 루트 없으면 종료
  const track = root.querySelector('.ticker-track');
  const view  = root.querySelector('.ticker-viewport');

  // (옵션) 특정 보드만 긴급 공지를 띄우고 싶으면 루트에 data-board-id="숫자" 달기
  const boardIdAttr = root.getAttribute('data-board-id');
  const boardId = boardIdAttr && boardIdAttr.trim() ? Number(boardIdAttr) : null;

  // ====== 컨텍스트/CSRF (프로젝트 공통) ======
  const CTX = (window.CTX
    || document.querySelector('meta[name="ctx"]')?.content
    || document.body.getAttribute('data-context-path')
    || '').trim();
  const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
  const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

  // ====== 닫힘 유지(12시간) 체크 ======
  const dismissedAt = +localStorage.getItem('urgentTickerDismissedAt') || 0;
  if (Date.now() - dismissedAt < HIDE_HOURS * 60 * 60 * 1000) return;

  // ====== 데이터 로드: 누적 TopN에서 topFixed='Y'만 추림 ======
  // - 백엔드 응답 필드: postId, postTitle, createDate, topFixed('Y'/'N') ...
  // - 여기선 topFixed==='Y'인 것만 사용 (긴급)
  const LIMIT = 20; // 여유 있게 가져와서 그 중 긴급만 사용
  const params = new URLSearchParams({ limit: String(LIMIT) });
  if (boardId) params.set('boardId', String(boardId));

  fetch(`${CTX}/api/notices/home-top?` + params.toString(), {
    method: 'GET',
    credentials: 'same-origin',
    headers: { [CSRF_HEADER]: CSRF_TOKEN }
  })
  .then(r => r.ok ? r.json() : Promise.reject(r.status))
  .then(rows => {
    const urgent = Array.isArray(rows) ? rows.filter(r => (r.topFixed || 'N') === 'Y') : [];
    if (!urgent.length) return;       // 긴급 없으면 티커 노출 안 함

    // 보여주기
    root.classList.remove('hide');

    // 항목 렌더
    track.innerHTML = urgent.map(row => {
      const text = `[긴급] ${row.postTitle || ''} · ${fmtDateTime(row.createDate)}`;
      return `<a class="item" href="${escAttr(detailUrl(row))}" title="${escAttr(text)}">${esc(text)}</a>`;
    }).join('');

    // 애니메이션 적용
    applyAnim();
  })
  .catch(err => console.error('[urgent-ticker] fetch fail:', err));

  // ====== 애니메이션/이벤트 ======
  function applyAnim(){
    // 트랙 전체 너비 + 뷰포트 너비 만큼 이동 시간 계산
    const w  = track.scrollWidth;
    const vw = view.clientWidth;
    const dist = w + vw;
    const sec  = Math.max(10, dist / SPEED);
    // duration만 바꾸면 안 먹는 경우가 있어 shorthand 사용
    track.style.animation = `ticker-rtl ${sec}s linear infinite`; // rtl: 오른쪽→왼쪽
  }
  window.addEventListener('resize', throttle(applyAnim, 150));

  root.addEventListener('mouseenter', ()=> root.classList.add('paused'));
  root.addEventListener('mouseleave', ()=> root.classList.remove('paused'));

  root.querySelector('.ticker-close')?.addEventListener('click', ()=>{
    root.classList.add('hide');
    localStorage.setItem('urgentTickerDismissedAt', String(Date.now()));
  });

  // ====== 라우트 & 유틸 ======
  function detailUrl(row){
    // 보드 지정 시 보드 라우트, 아니면 전역 포스트 라우트
    return boardId ? `${CTX}/board/${boardId}/post/${row.postId}`
                   : `${CTX}/post/${row.postId}`;
  }
  function fmtDateTime(iso){
    if (!iso) return '';
    const d = new Date(iso); // 'YYYY-MM-DDTHH:mm:ss' 기대
    if (Number.isNaN(d.getTime())) {
      // 파싱 실패 시 대충 보정: 'YYYY-MM-DD HH:mm' 형태를 'YYYY.MM.DD HH:mm'로
      return String(iso).replace('T',' ').slice(0,16).replace(/-/g,'.');
    }
    const y = d.getFullYear(), m = String(d.getMonth()+1).padStart(2,'0'), da = String(d.getDate()).padStart(2,'0');
    const h = String(d.getHours()).padStart(2,'0'), mi = String(d.getMinutes()).padStart(2,'0');
    return `${y}.${m}.${da} ${h}:${mi}`;
  }
  function throttle(fn, wait){ let t=0; return ()=>{ const n=Date.now(); if(n-t>wait){ t=n; fn(); } }; }
  function esc(s){ return String(s).replace(/[&<>"']/g, m=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;', "'":'&#39;' }[m])); }
  function escAttr(s){ return esc(s).replace(/"/g,'&quot;'); }
});




