// /resources/js/pages/weather.init.js  (버전 올리기: ?v=3)
(function($){
  const DEFAULT_CITY = '서울';
  let reqSeq = 0; // 최신 요청만 화면에 반영

  // ------ 반응형: 카드 폭에 따라 weather-sm/md/lg 적용 ------
  function mountWeatherResponsive(){
    const el = document.getElementById('weather-body');
    if (!el) return;

    // 관찰 대상: 날씨 카드의 바디(바로 부모가 보통 .card-body)
    const host = el.parentElement || el;

    const apply = () => {
      const w = host.clientWidth || el.clientWidth || 0;
      el.classList.remove('weather-sm','weather-md','weather-lg');
      el.classList.add(w >= 420 ? 'weather-lg' : w >= 320 ? 'weather-md' : 'weather-sm');
    };

    // 저장해 두고, 렌더 후에도 호출 가능하게
    el.__applyWeatherSize = apply;

    const ro = new ResizeObserver(apply);
    ro.observe(host);
    el.__weatherRO = ro;

    apply(); // 초기 1회
  }

  function renderWeather(data, displayCity){
    if (!data || !data.weather || !data.main) {
      $('#weather-body').html('<div class="text-danger">날씨 정보를 불러오지 못했습니다.</div>');
      return;
    }
    const icon = (data.weather[0]?.icon)
      ? 'https://openweathermap.org/img/wn/' + data.weather[0].icon + '@2x.png'
      : '';
    const desc  = data.weather[0]?.description || '';
    const temp  = (data.main.temp != null)        ? Math.round(Number(data.main.temp))        + '°C' : '-';
    const feels = (data.main.feels_like != null)  ? Math.round(Number(data.main.feels_like))  + '°C' : '-';
    const city  = displayCity || data.name || '';
    const hum   = (data.main.humidity != null)    ? data.main.humidity + '%' : '-';
    const wind  = (data.wind?.speed != null)      ? data.wind.speed + ' m/s' : '-';

    const $wb = $('#weather-body');
    // 크기 클래스는 여기서 강제하지 않음(ResizeObserver가 붙임)
    $wb.removeClass('weather-sm weather-md weather-lg').html(
      '<div class="d-flex align-items-center gap-3">'+
        (icon ? '<img src="'+icon+'" alt="아이콘" class="icon">' : '')+
        '<div>'+
          '<div class="temp-row">'+
            '<div class="temp">'+ temp +'</div>'+
            '<small class="city text-muted">'+ city +'</small>'+
          '</div>'+
          '<div class="desc">'+ desc +'</div>'+
          '<div class="meta">체감 '+ feels +' · 습도 '+ hum +' · 바람 '+ wind +'</div>'+
        '</div>'+
      '</div>'
    );

    // 렌더 후 현재 폭 기준으로 한 번 갱신
    document.getElementById('weather-body').__applyWeatherSize?.();
  }

  async function load(city){
    const seq = ++reqSeq;
    const q = (city && city.trim()) ? city.trim() : DEFAULT_CITY;

    $('#weather-body').html('<div class="text-muted">불러오는 중...</div>');
    try{
      const resp = await fetch('/api/weather/current?city=' + encodeURIComponent(q), {
        credentials: 'same-origin'
      });
      if (!resp.ok) throw new Error('HTTP '+resp.status);
      const data = await resp.json();
      if (seq !== reqSeq) return;

      renderWeather(data, q);

      // 검색 성공 후 입력칸 초기화 & 포커스
      const $input = $('#weather-city');
      $input.val('');
      $input.attr('placeholder', '도시 (예: 서울)');
      $input.focus();
    }catch(e){
      if (seq !== reqSeq) return;
      console.error(e);
      $('#weather-body').html('<div class="text-danger">날씨 정보를 불러오지 못했습니다.</div>');
    }
  }

  $(function(){
    // 입력창 placeholder
    $('#weather-city').attr('placeholder', '도시 (예: 서울)');

    // 반응형 장착(한 번만)
    mountWeatherResponsive();

    // 초기 로드
    load(DEFAULT_CITY);

    // Enter로 조회
    $('#weather-city').on('keydown', function(e){
      if (e.key === 'Enter') {
        e.preventDefault();
        load($(this).val());
      }
    });
  });
})(jQuery);
