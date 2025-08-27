// /resources/js/pages/weather.init.js  (버전 올리기: ?v=2)
(function($){
  const DEFAULT_CITY = '서울';
  let reqSeq = 0; // 최신 요청만 화면에 반영하기 위한 시퀀스

  function renderWeather(data, displayCity){
    if (!data || !data.weather || !data.main) {
      $('#weather-body').html('<div class="text-danger">날씨 정보를 불러오지 못했습니다.</div>');
      return;
    }
    const icon = (data.weather[0]?.icon)
      ? 'https://openweathermap.org/img/wn/' + data.weather[0].icon + '@2x.png'
      : '';
    const desc = data.weather[0]?.description || '';
    const temp = (data.main.temp != null) ? Math.round(Number(data.main.temp)) + '°C' : '-';
    const feels= (data.main.feels_like != null) ? Math.round(Number(data.main.feels_like)) + '°C' : '-';
    const city = displayCity || data.name || '';
    const hum  = (data.main.humidity != null) ? data.main.humidity + '%' : '-';
    const wind = (data.wind?.speed != null) ? data.wind.speed + ' m/s' : '-';

	$('#weather-body').addClass('weather-lg').html(
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

      //  검색 성공 후 입력칸 초기화 & 포커스
      const $input = $('#weather-city');
      $input.val('');              // 비우기
      $input.attr('placeholder', '도시 (예: 서울)'); // placeholder 유지
      $input.focus();              // 바로 다시 입력 가능
    }catch(e){
      if (seq !== reqSeq) return;
      console.error(e);
      $('#weather-body').html('<div class="text-danger">날씨 정보를 불러오지 못했습니다.</div>');
      // 실패 시에는 사용자가 수정할 수 있게 값을 유지
    }
  }

  $(function(){
    // 입력창 초기값
    $('#weather-city').attr('placeholder', '도시 (예: 서울)');

    // 초기 1회만 로드
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
