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
<div class="row align-items-center g-0 mt-3 agenda-row" data-key="${key}">
  <div class="col-sm-2">
    <span class="badge ${typeBadgeClass(type)}">${type}</span>
  </div>
  <div class="col-sm-6">
    <span class="d-inline-block text-truncate" style="max-width:100%"
          title="${escapeHtml(memo)}">${escapeHtml(memo)}</span>
  </div>
  <div class="col-sm-2 text-muted" style="font-size:.9rem;">${dateStr}</div>
  <div class="col-sm-2 text-muted" style="font-size:.9rem;">${timeStr}</div>
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

  // ✅ 최신순(시작일 내림차순)
  const sorted = Array.from(uniqMap.values())
    .sort((a,b)=> new Date(b.start) - new Date(a.start));

  renderTop4(sorted);
});
