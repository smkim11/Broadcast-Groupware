(function(){
  function ready(fn){
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', fn);
    else fn();
  }

  ready(function(){
    const rowsEl = document.getElementById('home-notice-rows');
    const moreBtn = document.getElementById('home-notice-more');
    if(!rowsEl) return;

    // ---- 설정값 ----
    const PAGE_SIZE = 6;
    let cursor = null;     // 다음 페이지 커서
    let loadedOnce = false;

    const CSRF_TOKEN  = document.querySelector('meta[name="_csrf"]')?.content || '';
    const CSRF_HEADER = document.querySelector('meta[name="_csrf_header"]')?.content || 'X-CSRF-TOKEN';

    // 최초 로딩
    loadNotices(false);

    // 더보기
    moreBtn?.addEventListener('click', function(){
      loadNotices(true);
    });

    async function loadNotices(append){
      try{
        const q = new URLSearchParams({ limit: String(PAGE_SIZE) });
        if (cursor) q.set('cursor', cursor);

        const resp = await fetch((window.CTX||'') + '/api/notices?' + q.toString(), {
          method: 'GET', credentials: 'same-origin',
          headers: { [CSRF_HEADER]: CSRF_TOKEN }
        });

        let data;
        if (resp.ok){
          data = await resp.json();
        }else{
          // 백엔드 미구현/오류 시 데모 데이터로 보여주기(개발 편의용)
          console.warn('[notice] api error => demo data fallback');
          data = demoPayload();
        }

        render(data.items || [], append);
        cursor = data.nextCursor || null;
        toggleMoreBtn(Boolean(cursor));

      }catch(e){
        console.error(e);
        if (!loadedOnce){
          render(demoPayload().items, false);
          toggleMoreBtn(false);
        }
      }
      loadedOnce = true;
    }

    function render(items, append){
      if (!append) rowsEl.innerHTML = '';

      if (!items.length){
        if (!append) rowsEl.innerHTML = `<div class="n-empty">공지 없음</div>`;
        return;
      }

      const html = items.map(it => rowHtml(it)).join('');
      rowsEl.insertAdjacentHTML('beforeend', html);

      // 접근성/키보드: Enter키로 열기
      rowsEl.querySelectorAll('.n-row[tabindex="0"]').forEach(el => {
        el.addEventListener('keydown', e => {
          if (e.key === 'Enter') el.click();
        });
      });
    }

    function rowHtml(it){
      // it: { id, urgent:boolean, boardName, title, url, createdAt(ISO) }
      const d = it.createdAt ? new Date(it.createdAt) : new Date();
      const dateStr = fmtDate(d); // YYYY.MM.DD
      const timeStr = fmtTime(d); // HH:mm

      const leftBadge = it.urgent
        ? `<span class="badge bg-danger-subtle text-danger">긴급</span>`
        : `<span class="badge bg-secondary-subtle text-secondary">${esc(it.boardName||'게시판')}</span>`;

      const url = it.url || ((window.CTX||'') + '/board/notice/' + it.id);

      return `
      <div class="n-row" role="listitem" tabindex="0" data-id="${it.id||''}" onclick="location.href='${url}'" title="${esc(it.title||'')}">
        <div class="n-board">${leftBadge}</div>
        <div class="n-title">${esc(it.title || '제목 없음')}</div>
        <div class="n-date">${dateStr}</div>
        <div class="n-time">${timeStr}</div>
      </div>`;
    }

    function toggleMoreBtn(show){
      if (!moreBtn) return;
      moreBtn.classList.toggle('d-none', !show);
    }

    // 날짜/시간 포맷
    function pad2(n){ return String(n).padStart(2,'0'); }
    function fmtDate(d){ return `${d.getFullYear()}.${pad2(d.getMonth()+1)}.${pad2(d.getDate())}`; }
    function fmtTime(d){ return `${pad2(d.getHours())}:${pad2(d.getMinutes())}`; }

    // XSS 방지용 이스케이프
    function esc(s){ return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }

    // 데모 페이로드(백엔드 준비 전 임시 표시)
    function demoPayload(){
      const now = new Date();
      const d = (offsetMin)=> new Date(now.getTime() - offsetMin*60000).toISOString();
      return {
        items: [
          { id:101, urgent:true , boardName:'전사공지', title:'정전 점검으로 오늘 20시 서버 점검', url:'#', createdAt: d(20) },
          { id:102, urgent:false, boardName:'인사'   , title:'9월 연차 사용 안내', url:'#', createdAt: d(120) },
          { id:103, urgent:false, boardName:'보안'   , title:'이메일 피싱 주의 공지', url:'#', createdAt: d(360) },
          { id:104, urgent:false, boardName:'총무'   , title:'사무실 에어컨 점검 일정', url:'#', createdAt: d(720) },
          { id:105, urgent:false, boardName:'개발'   , title:'스프린트 회고 일정 공지', url:'#', createdAt: d(1440) },
          { id:106, urgent:false, boardName:'홍보'   , title:'사내 뉴스레터 9월호 배포', url:'#', createdAt: d(2880) },
        ],
        nextCursor: null
      };
    }
  });
})();