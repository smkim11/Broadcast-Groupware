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

  // 공지사항 카드처럼 행 형태로 렌더 (최대 4개)
  function renderTop4(list){
    if (!list.length){
      wrap.innerHTML = `<div class="text-muted">이번 달 일정이 없습니다.</div>`;
      return;
    }
    wrap.innerHTML = list.slice(0,4).map(ev=>{
      const s=new Date(ev.start);
      const dateStr=`${s.getMonth()+1}/${s.getDate()}(${yoil[s.getDay()]})`;
      const timeStr=timeRangeText(ev);
      const type=ev.extendedProps.type;
      const memo=(ev.extendedProps.memo && ev.extendedProps.memo.trim()) ? ev.extendedProps.memo : (ev.title || '(제목없음)');
      const key = ev.__key;

      return `
<div class="row align-items-center g-0 mt-2 agenda-row" data-key="${key}">
  <div class="col-sm-2">
    <span class="badge ${typeBadgeClass(type)}">${type}</span>
  </div>
  <div class="col-sm-5">
    <span class="d-inline-block text-truncate" style="max-width:100%"
          title="${escapeHtml(memo)}">${escapeHtml(memo)}</span>
  </div>
  <div class="col-sm-2 text-muted" style="font-size:.9rem;">${dateStr}</div>
  <div class="col-sm-3 text-muted" style="font-size:.9rem;">${timeStr}</div>
</div>`;
    }).join('');

    // 클릭 → 상세 모달(읽기 전용)
    wrap.querySelectorAll('.agenda-row').forEach(row=>{
      row.addEventListener('click', ()=>{
        const key=row.getAttribute('data-key');
        const ev = cache.find(x=>x.__key===key);
        if (ev) openReadonlyModal(ev);
      });
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

    // 2) 도넛 렌더러
    function renderDonut(target, count, label, color){
		  // ★ 여기 숫자/퍼센트만 바꿔서 크기 조절
		  const DONUT_HEIGHT   = 70;   // 전체 지름(세로). 120~200 사이에서 조절
		  const DONUT_HOLE     = '68%'; // 구멍 크기. 값이 작을수록 링이 두꺼워짐(60~78% 추천).
		  const VALUE_FONTSIZE = '20px';// 중앙 숫자 폰트 크기
		  const NAME_SHOW      = false; // 중앙 상단 이름은 보통 숨김

		  const opt = {
		    chart: {
		      type: 'donut',
		      height: DONUT_HEIGHT,
		      sparkline: { enabled: true } // 축/툴팁 등 제거
		    },
		    series: [Number(count) || 0],
		    labels: [label],
		    colors: [color],
		    legend: { show: false },
		    tooltip: { enabled: false },
		    dataLabels: { enabled: false },
		    plotOptions: {
		      pie: {
		        donut: {
		          size: DONUT_HOLE,      // ← 링 두께 조절
		          labels: {
		            show: true,
		            name:  { show: NAME_SHOW },
		            value: {
		              show: true,
		              fontSize: VALUE_FONTSIZE,
		              fontWeight: 700,
		              color: '#212529',
		              formatter: () => String(Number(count) || 0) // 중앙 숫자
		            },
		            total: { show: true, label: label, color: '#6c757d', formatter: () => '' }
		          }
		        }
		      }
		    },
		    // 화면 너비에 따라 자동 축소 (옵션)
		    responsive: [
		      { breakpoint: 992,  options: { chart: { height: DONUT_HEIGHT - 10 }, plotOptions:{ pie:{ donut:{ size:'70%' }}} } },
		      { breakpoint: 576,  options: { chart: { height: DONUT_HEIGHT - 20 }, plotOptions:{ pie:{ donut:{ size:'72%' }}} ,
		                                      plotOptions:{ pie:{ donut:{ labels:{ value:{ fontSize:'18px' }}}}} } }
		    ]
		  };
		  new ApexCharts(target, opt).render();
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

//============================휴가 관리============================
(function(){
  // DOMContentLoaded 유틸
  function ready(fn){ document.readyState==='loading' ? document.addEventListener('DOMContentLoaded', fn) : fn(); }
  document.addEventListener('DOMContentLoaded', function(){
    const card  = document.getElementById('card-vac');
    const badge = document.getElementById('vac-year-badge'); // "2025년 기준 연차" 뱃지
    if (card && badge){
      // 뱃지 높이 + 여유 2~4px 만큼 올리기
      const lift = badge.offsetHeight + 10;   // 필요하면 +값 조정
      card.style.setProperty('--vac-lift', lift + 'px');
    }
  });

  ready(function(){
    const badge   = document.getElementById('vac-year-badge');
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
