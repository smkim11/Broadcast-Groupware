//============================근태============================
(function(){
  // (초보자용) 문서가 준비되면 실행
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const wrap = document.getElementById('att-donuts');
    if(!wrap) return; // 근태 섹션이 없으면 종료

    // (스프링 시큐리티 대비) CSRF 토큰/헤더 가져오기 - 없으면 빈값
    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    const ctx  = window.CTX || ''; // 컨텍스트 경로(있으면)
    const days = 30;               // 기준 일수(요구: 30일)
    
    // 1) 최근 30일 요약 + 오늘 시간 호출
    fetch(`${ctx}/api/attendance/summary?days=${days}`, {
      method: 'GET',
      credentials: 'same-origin',
      headers: { [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .catch(() => demo())                         // 백엔드 미구현 → 데모 데이터
    .then(raw => renderAtt(normalize(raw)))      // ★ 호출명 변경
    .catch(err => console.error('[att] render error:', err));

    // 2) 응답 표준화(형태가 달라도 여기서 한 번에 정리)
    function normalize(p){
      const d = Number(p?.days ?? days);
      const c = p?.counts || p || {};
      const t = p?.today  || {};
      return {
        days: d,
        inCount   : Number(c?.checkin  ?? c?.in       ?? 0),
        outCount  : Number(c?.checkout ?? c?.out      ?? 0),
        fieldCount: Number(c?.field    ?? c?.outside  ?? 0),
        inTime    : t?.checkinTime   ?? t?.in          ?? '--:--',
        outTime   : t?.checkoutTime  ?? t?.out         ?? '--:--',
        fieldTime : t?.fieldTime     ?? t?.outsideTime ?? '-'
      };
    }

    // 3) 데모 데이터(화면 테스트 용)
    function demo(){
      return {
        days: 30,
        counts: { checkin: 12, checkout: 21, field: 5 },
        today:  { checkinTime: '09:12', checkoutTime: '18:03', fieldTime: '14:10' }
      };
    }

    // 4) 렌더링: 도넛 3개 + 오늘 시간 텍스트
    function renderAtt(v){                         // ★ 함수명 변경
      // (a) 아래 작은 글씨(오늘 시각) 채우기
      document.getElementById('att-in-time').textContent    = v.inTime;
      document.getElementById('att-out-time').textContent   = v.outTime;
      document.getElementById('att-field-time').textContent = v.fieldTime;

      // (b) 예약 카드처럼 각각 "완료/남음" 도넛으로 표현(중앙 숫자 라벨 사용)
      drawDonut('#att-donut-in',    v.inCount,    v.days, getCssColor('--bs-success'));
      drawDonut('#att-donut-out',   v.outCount,   v.days, getCssColor('--bs-primary'));
      drawDonut('#att-donut-field', v.fieldCount, v.days, getCssColor('--bs-warning'));
    }

    // 부트스트랩 CSS 변수 칼라 읽기(다크 테마 대응)
    function getCssColor(varName){
      return getComputedStyle(document.documentElement).getPropertyValue(varName).trim();
    }

    // 공용: 미니 도넛 그리기 (예약과 동일하게 중앙 숫자 라벨 사용)
	function drawDonut(targetSel, value, max, color, centerText){
	  const el  = document.querySelector(targetSel);
	  if(!el) return;

	  const box = el.closest?.('.resv-donut') || el.parentElement || document.body;
	  const cs  = getComputedStyle(box);
	  const DONUT_HEIGHT = parseInt(cs.getPropertyValue('--donut-height')) || 110;
	  const DONUT_HOLE   = (cs.getPropertyValue('--donut-hole') || '69%').trim();

	  // 완료/남음 계산
	  const done = Math.max(0, Math.min(Number(value||0), Number(max||0)));
	  const rest = Math.max(0, Number(max||0) - done);
	  const sDone = (done === 0 && rest > 0) ? 0.0001 : done;

	  const options = {
	    chart:   { type: 'donut', height: DONUT_HEIGHT, sparkline: { enabled: true } },
	    series:  [sDone, rest],
	    labels:  ['완료','남음'],
	    colors:  [color, getCssColor('--bs-gray-300') || '#dee2e6'],
	    dataLabels: { enabled: false },
	    stroke:     { width: 0 },                 // ★ 예약과 동일
	    legend:     { show: false },
	    tooltip:    { enabled: false },
	    plotOptions:{ pie: { donut: {
	      size: DONUT_HOLE,                       // ★ 예약과 동일 두께
	      labels: { show: false }                 // ★ Apex 중앙 라벨 끔(두께 영향 제거)
	    } } }
	  };

	  if (el.__apex__) el.__apex__.destroy();
	  const chart = new ApexCharts(el, options);
	  chart.render();
	  el.__apex__ = chart;

	  // 중앙 텍스트(출근/퇴근/외근) 오버레이
	  let center = el.querySelector('.att-center');
	  if (!center) {
	    center = document.createElement('div');
	    center.className = 'att-center';
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
    .catch(() => demo(y))                   // 실패/미구현 → 데모
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

    // 4) 데모 데이터
    function demo(year){
      return { year, total:16, remaining:10, approvalPending:0 };
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
    .catch(() => demo())         // 실패/미구현 → 데모
    .then(payload => render(payload))
    .catch(err => console.error('[docs] render error:', err));

    // 2) 렌더
    function render(p){
      // p 형태 허용: {counts:{PROGRESS:3,PENDING:3,DONE:3}} 또는 items:[{key,count},...]
      const counts = normalize(p);

      // 행 배열(표시 순서 고정)
      const rows = [
        { key:'PROGRESS', label:'진행함',  icon:'mdi-archive-outline',  href:'/docs?status=in_progress' },
        { key:'PENDING',  label:'미결함',  icon:'mdi-archive-outline',  href:'/docs?status=pending'     },
        { key:'DONE',     label:'완료함',  icon:'mdi-archive-outline',  href:'/docs?status=done'        }
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

    // 3) 데모 데이터
    function demo(){
      return { counts: { PROGRESS:3, PENDING:3, DONE:3 } };
    }

    // 간단 XSS 방지
    function esc(s){ return String(s).replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
  });
})();



/* ================== 예약 ================== */
(function(){
  // DOMContentLoaded 유틸
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const el = {
      meeting: document.getElementById('donut-meeting'),
      edit   : document.getElementById('donut-edit'),
      vehicle: document.getElementById('donut-vehicle')
    };
    // 도넛 컨테이너 없으면 종료
    if (!el.meeting || !el.edit || !el.vehicle) return;

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // 1) 데이터 로드
    fetch((window.CTX||'') + '/api/reservations/home-summary?days=7', {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .catch(() => demoPayload())     // 백엔드 미구현/에러 → 데모
    .then(payload => {
      // totals를 우선, 없으면 series 맨 마지막 값으로 추론
      const getToday = key => {
        if (payload.totals && payload.totals[key] != null) return payload.totals[key];
        const s = (payload.series||[]).find(x => x.key === key || x.name === key);
        return s && Array.isArray(s.data) && s.data.length ? s.data[s.data.length-1] : 0;
      };

      renderDonut(el.meeting, getToday('MEETING'), '회의실', '#0d6efd'); // primary
      renderDonut(el.edit,    getToday('EDIT'   ), '편집실', '#6f42c1'); // purple
      renderDonut(el.vehicle, getToday('VEHICLE'), '차량'  , '#20c997'); // teal
    })
    .catch(err => console.error('[resv.donut] render fail:', err));

	// 2) 도넛 렌더러 (예약/근태 공통 크기 변수 사용)
	function renderDonut(target, count, label, color){
	  const box = target.closest?.('.resv-donut') || target.parentElement || document.body;
	  const cs  = getComputedStyle(box);
	  const DONUT_HEIGHT   = parseInt(cs.getPropertyValue('--donut-height')) || 110;
	  const DONUT_HOLE     = (cs.getPropertyValue('--donut-hole') || '69%').trim();
	  const VALUE_FONTSIZE = (cs.getPropertyValue('--donut-font') || '20px').trim();

	  const opt = {
	    chart:   { type: 'donut', height: DONUT_HEIGHT, sparkline: { enabled: true } },
	    series:  [Number(count) || 0],
	    labels:  [label],
	    colors:  [color],
	    legend:  { show: false },
	    tooltip: { enabled: false },
	    dataLabels: { enabled: false },
	    stroke:   { width: 0 },                 // ★ 틈(하얀 경계) 제거 → 근태와 동일
	    plotOptions: { pie: { donut: {
	      size: DONUT_HOLE,                     // ★ 공통 두께
	      labels: {
	        show: true,                         // 중앙 숫자
	        name:  { show: false },
	        value: {
	          show: true,
	          fontSize: VALUE_FONTSIZE,
	          fontWeight: 700,
	          color: '#212529',
	          formatter: () => String(Number(count) || 0)
	        },
	        total: { show: false }              // 레이아웃 영향 제거
	      }
	    } } }
	  };

	  if (target.__apex__) target.__apex__.destroy();
	  const chart = new ApexCharts(target, opt);
	  chart.render();
	  target.__apex__ = chart;
	}

    // 3) 데모 페이로드(백엔드 준비 전 임시 표시)
    function demoPayload(){
      // 최근 7일 라벨과 랜덤 값
      const today = new Date();
      const days = [...Array(7)].map((_,i)=>{
        const d = new Date(today); d.setDate(today.getDate() - (6-i));
        return d.toISOString().slice(0,10); // YYYY-MM-DD
      });
      const rnd = (min,max)=> Math.floor(Math.random()*(max-min+1))+min;
      const m = days.map(()=> rnd(1,6));
      const e = days.map(()=> rnd(0,4));
      const v = days.map(()=> rnd(0,3));
      return {
        totals: { MEETING: m.at(-1), EDIT: e.at(-1), VEHICLE: v.at(-1) },
        labels: days,
        series: [
          { key:'MEETING', name:'회의실', data: m },
          { key:'EDIT'   , name:'편집실', data: e },
          { key:'VEHICLE', name:'차량'  , data: v }
        ]
      };
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
  function renderTop4(list){
    if (!list.length){
      wrap.innerHTML = `<div class="text-muted">이번 달 일정이 없습니다.</div>`;
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


// ======================================= 공지사항 =============================
// ============================ [공지사항] ============================
(function(){
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }

  ready(function(){
    const rowsEl = document.getElementById('home-notice-rows');
    if(!rowsEl) return;

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';
    const ctx = window.CTX || '';

    // 1) 데이터 로드 (없으면 데모)
    fetch(`${ctx}/api/notices?limit=6`, {
      method:'GET', credentials:'same-origin', headers:{ [CSRF_HEADER]: CSRF_TOKEN }
    })
    .then(r => r.ok ? r.json() : Promise.reject(r.status))
    .catch(() => demo())                // 백엔드 미구현/에러 → 데모
    .then(payload => render(normalize(payload)))
    .catch(err => console.error('[notice] render error:', err));

    // 2) 표준화: 어떤 응답이 와도 [{title,dateStr,timeStr,badgeLabel,badgeClass,href}] 로 변환
    function normalize(p){
      let list = [];
      if (Array.isArray(p?.items)) list = p.items;
      else if (Array.isArray(p))   list = p;
      else if (p?.content && Array.isArray(p.content)) list = p.content; // 페이징 형태 대응

      const pad = n => String(n).padStart(2,'0');

      return list.map(n => {
        const title = n.title || n.subject || n.name || '제목 없음';
        const category = n.category || n.board || n.boardName || n.type || ''; // 게시판/분류
        const urgent = !!(n.urgent || n.isUrgent || n.priority==='HIGH' || n.level==='EMERGENCY' || n.emergency===true);

        const whenRaw = n.createdAt || n.created_at || n.regDate || n.writeDate || n.date || n.updatedAt;
        const d = whenRaw ? new Date(whenRaw) : null;
        const dateStr = d ? `${d.getFullYear()}.${pad(d.getMonth()+1)}.${pad(d.getDate())}` : '';
        const timeStr = d ? `${pad(d.getHours())}:${pad(d.getMinutes())}` : '';

        const href = n.href || n.url || (n.id!=null ? `/board/notice/${n.id}` : '#');

        return {
          title,
          dateStr, timeStr, href,
          badgeLabel: urgent ? '긴급' : (category || '공지'),
          badgeClass: urgent ? 'bg-danger' : 'bg-secondary'
        };
      });
    }

    // 3) 렌더: 최대 4행
    function render(list){
      if (!list.length){
        rowsEl.innerHTML = `<div class="text-muted">공지사항이 없습니다.</div>`;
        return;
      }
      rowsEl.innerHTML = list.slice(0,4).map(r => rowHtml(r)).join('');
    }

    function rowHtml(r){
      return `
        <a class="n-row" role="listitem" href="${escAttr(r.href)}">
          <div class="n-badge"><span class="badge ${r.badgeClass}">${esc(r.badgeLabel)}</span></div>
          <div class="n-title" title="${escAttr(r.title)}">${esc(r.title)}</div>
          <div class="n-date">${esc(r.dateStr)}</div>
          <div class="n-time">${esc(r.timeStr)}</div>
        </a>`;
    }

    // 4) 데모 데이터 (API 준비 전 화면 테스트용)
    function demo(){
      const now = new Date();
      const iso = d => new Date(d).toISOString();
      return {
        items: [
          { id: 101, title:'정전 점검으로 오늘 20시 서버 점검', urgent:true, regDate: iso(now) },
          { id: 102, title:'9월 연차 사용 안내', boardName:'인사', regDate: iso(now) },
          { id: 103, title:'보안 패치 완료 공지', boardName:'시스템', regDate: iso(now) },
          { id: 104, title:'사내 메일 점검 안내', boardName:'IT지원', regDate: iso(now) },
          { id: 105, title:'추석 연휴 근무표 안내', boardName:'총무', regDate: iso(now) }
        ]
      };
    }

    // XSS 안전 이스케이프
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
  const SPEED = 100;

  const DEMO_NOTICES = [
    { id: 101, title: '정전 점검으로 오늘 20시 서버 점검', label: '긴급', createdAt: '2025.08.28 19:50', url: '/board/notice/101' },
    { id: 102, title: '사내 메일 장애 복구 안내',           label: '긴급', createdAt: '2025.08.28 18:30', url: '/board/notice/102' },
    { id: 103, title: '보안 패치 완료 공지',                 label: '긴급시스템', createdAt: '2025.08.28 11:50', url: '/board/notice/103' },
  ];

  const list = DEMO_NOTICES.filter(it => String(it.label).toUpperCase().includes('긴급'));
  if (!list.length) return;

  // 테스트 중엔 숨김 이력 무시 (주석 풀면 다시 동작)
  // const dismissedAt = +localStorage.getItem('urgentTickerDismissedAt') || 0;
  // if (Date.now() - dismissedAt < 12*60*60*1000) return;

  const root  = document.getElementById('urgent-ticker');
  if (!root) return;

  const track = root.querySelector('.ticker-track');
  const view  = root.querySelector('.ticker-viewport');

  root.classList.remove('hide');
  track.innerHTML = list.map(it => {
    const label = it.label ? `[${it.label}] ` : '';
    const dt    = it.createdAt ? ` · ${it.createdAt}` : '';
    const text  = `${label}${it.title}${dt}`;
    return `<a class="item" href="${escAttr(it.url||'#')}" title="${escAttr(text)}">${esc(text)}</a>`;
  }).join('');

  function applyAnim(){
    const w  = track.scrollWidth;
    const vw = view.clientWidth;
    const dist = w + vw;
    const sec  = Math.max(10, dist / SPEED);
    // duration만 바꾸면 안 먹는 경우가 있어서 전체 shorthand로 지정
    track.style.animation = `ticker-rtl ${sec}s linear infinite`;		// ltr: 왼쪽 rtl: 오른쪽
  }
  applyAnim();
  window.addEventListener('resize', throttle(applyAnim, 150));

  root.addEventListener('mouseenter', ()=> root.classList.add('paused'));
  root.addEventListener('mouseleave', ()=> root.classList.remove('paused'));
  root.querySelector('.ticker-close')?.addEventListener('click', ()=>{
    root.classList.add('hide');
    localStorage.setItem('urgentTickerDismissedAt', String(Date.now()));
  });

  function throttle(fn, wait){ let t=0; return ()=>{ const n=Date.now(); if(n-t>wait){ t=n; fn(); } }; }
  function esc(s){ return String(s).replace(/[&<>"']/g, m=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;', "'":'&#39;' }[m])); }
  function escAttr(s){ return esc(s).replace(/"/g,'&quot;'); }
});



