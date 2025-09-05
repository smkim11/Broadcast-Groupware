<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta name="ctx" content="${pageContext.request.contextPath}">
<meta charset="UTF-8">
<script>window.CTX = document.querySelector('meta[name="ctx"]')?.content || '';</script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
	<c:if test="${not empty sessionScope.loginUser}">
        <script>
            const role = '<c:out value="${sessionScope.loginUser.role}" />';
            console.log('User role from session:', role);
        </script>
    </c:if>
<title>Insert title here</title>
 <style>
    #urgent-ticker{
      position: fixed; left:0; right:0; bottom:0;
      z-index:2147482000; background:#f8d7da; color:#842029;
      border-top:1px solid #f1aeb5; padding:8px 48px 8px 12px; font-weight:600;
    }
    html[data-bs-theme="dark"] #urgent-ticker{
      background:#2b171a; border-top-color:#6b3138; color:#ffdce0;
    }
    #urgent-ticker.hide{ display:none; }
    #urgent-ticker .ticker-close{
      position:absolute; right:10px; top:50%; transform:translateY(-50%);
      border:0; background:transparent; color:inherit; font-size:20px; line-height:1; opacity:.7; cursor:pointer;
    }
    #urgent-ticker .ticker-close:hover{ opacity:1; }
    #urgent-ticker .ticker-viewport{ overflow:hidden; white-space:nowrap; }
    #urgent-ticker .ticker-track{
      display:inline-block; will-change:transform;
      /* duration 포함한 shorthand — 기본 25s */
      animation: ticker-ltr 25s linear infinite;
    }
    #urgent-ticker.paused .ticker-track{ animation-play-state:paused; }
    #urgent-ticker .item{ display:inline-block; margin-right:48px; color:inherit; text-decoration:none; }
    #urgent-ticker .item:hover{ text-decoration:underline; }

    @keyframes ticker-ltr{
      0%   { transform: translateX(-100%); }
      100% { transform: translateX(100%); }
    }
  </style>
</head>
<body>
	<input type="hidden" id="event-login-user" value="${sessionScope.loginUser.userId}" />
<div>
    <jsp:include page ="../views/nav/header.jsp"></jsp:include>
</div>
	<div class="main-content">

     <div class="page-content">
         <div class="container-fluid">

           <!-- start page title -->
           <!-- 상단 위치 경로 -->
             <div class="row">
                 <div class="col-12">
                     <div class="page-title-box d-flex align-items-center justify-content-between">
                         <h4 class="mb-0">Home</h4>
                         
                          <div class="page-title-right">
                             <ol class="breadcrumb m-0">
                                 <li class="breadcrumb-item"><a href="javascript: void(0);">KOJ</a></li>
                                 <li class="breadcrumb-item active">Home</li>
                             </ol>
                         </div>
                     </div>
                 </div>
             </div>
             <!-- 위치경로 닫기 -->
             
               <!-- end page title -->
				<!-- 상단 4개 카드 내용 -->
			<div class="row">
			  <div class="col-md-6 col-xl-3">
			    <div class="card" id="card-att">
			      <div class="card-body">
			            <a href="${pageContext.request.contextPath}/attendance" 
         class="stretched-link" 
         aria-label="근태 페이지로 이동"></a>
			        <div class="d-flex align-items-center justify-content-between mb-1">
			        <div class="d-flex align-items-center mb-2">
			          <h4 class="card-title mb-1"><i class="uil-stopwatch me-1"></i>근태</h4>
			          <span id="resv-range-label" class="title-inline-note ms-2">30일 기준</span>
			        </div>
			        </div>
			
			        <!-- 도넛 그래프 영역 -->
	    		 <!-- ▽ 도넛 3개가 가로로 나란히 -->
				<div class="row text-center g-2" id="att-donuts">
				  <!-- 출근 -->
				  <div class="col-4">
				    <div class="resv-donut position-relative">
				      <div id="att-donut-in"></div>                  <!-- ApexCharts가 들어갈 자리 -->
				      <div class="att-center">출근</div>              <!-- 도넛 중앙 라벨 -->
				    </div>
				    <div class="small text-muted mt-1"><span id="att-in-time">--:--</span></div>
				  </div>
				  <!-- 퇴근 -->
				  <div class="col-4">
				    <div class="resv-donut position-relative">
				      <div id="att-donut-out"></div>
				      <div class="att-center">퇴근</div>
				    </div>
				    <div class="small text-muted mt-1"><span id="att-out-time">--:--</span></div>
				  </div>
				  <!-- 외근 -->
				  <div class="col-4">
				    <div class="resv-donut position-relative">
				      <div id="att-donut-outside"></div>
				      <div class="att-center">외근</div>
				    </div>
				    <div class="small text-muted mt-1"><span id="att-outside-time">--:--</span></div>
				  </div>
				</div>
			  </div>
			  </div>
			  </div>
                 <!-- end col-->
                 
				<div class="col-md-6 col-xl-3">
				  <div class="card" id="card-vac">
				    <div class="card-body">
				      <!-- 제목 + 연차 기준 뱃지 + 전체보기(오른쪽) -->
				      <div class="d-flex align-items-center justify-content-between">
				        <div class="d-flex align-items-center">
				         <h4 class="card-title mb-1"><i class="uil-plane-departure me-1"></i>휴가</h4>
				          <span id="vac-year-note" class="title-inline-note ms-2">—</span>
				        </div>
				      </div>
				
				      <!-- 내용 : 칩 2개 + 타일 1개 -->
				      <div class="d-flex align-items-stretch gap-2 mt-2" id="vac-rows">
				        <div class="vac-chip flex-fill text-center" id="vac-total" role="button" data-href="${pageContext.request.contextPath}/attendance">
				          <i class="bx bxs-plane-alt vac-chip-icon" aria-hidden="true"></i>  <!-- ✈ 전체 -->
				          <div class="vac-chip-label">전체</div>
				          <div class="vac-chip-value">0</div>
				        </div>
				        <div class="vac-chip flex-fill text-center" id="vac-remaining" role="button" data-href="${pageContext.request.contextPath}/attendance">
				         <i class="bx bx-hourglass vac-chip-icon" aria-hidden="true"></i>  
				          <div class="vac-chip-label">잔여</div>
				          <div class="vac-chip-value">0</div>
				        </div>
				        <div class="vac-tile flex-fill text-center" id="vac-approval" role="button" data-href="${pageContext.request.contextPath}/approval/documents/in-progress">
				          <i class="mdi mdi-file-check-outline vac-tile-icon" aria-hidden="true"></i>
				          <div class="vac-tile-label">결재중</div>
				          <div class="vac-tile-value">0</div>
				        </div>
				      </div>
				    </div>
				  </div>
				</div>
                 <!-- end col-->
                 
                 <div class="col-md-6 col-xl-3">
                     <div class="card">
                         <div class="card-body">
                             <div class="d-flex align-items-center mb-2">
					      		<h4 class="card-title mb-1"><i class="uil-folder-question me-1"></i>문서</h4>
							</div>
							 <div id="doc-rows" class="doc-rows mt-2" role="list" aria-label="문서 상태별 개수"></div>
                         </div>
                     </div>
                 </div> 
                 <!-- end col-->
                 
					   <div class="col-md-6 col-xl-3">
					  <div class="card" id="card-resv">
					    <div class="card-body">
					    <div class="d-flex align-items-center mb-2">
					      <h4 class="card-title mb-1"><i class="uil-clock-three me-1"></i>예약</h4>
						</div>
					
					      <!-- ▽ 도넛 3개가 가로로 나란히 -->
					     <div class="row text-center g-2" id="resv-donuts">
					  <div class="col-4">
					    <div id="donut-meeting" class="resv-donut" data-href="${pageContext.request.contextPath}/user/meetingroom"></div>
					    <div class="small text-muted mt-1">회의실</div>
					  </div>
					  <div class="col-4">
					    <div id="donut-edit" class="resv-donut" data-href="${pageContext.request.contextPath}/user/cuttingroom"></div>
					    <div class="small text-muted mt-1">편집실</div>
					  </div>
					  <div class="col-4">
					    <div id="donut-vehicle" class="resv-donut"  data-href="${pageContext.request.contextPath}/user/car"></div>
					    <div class="small text-muted mt-1">차량</div>
					  </div>
					</div>
					
					    </div>
					  </div>
					</div>
                 <!-- end col-->
               </div>
               <!--  상단 4개카드 닫기 -->
                 
                 <!-- 중간 내용 2개 카드 -->
<div class="row">
  <!-- 왼쪽: 영상 (두 줄 높이를 차지) -->
  <div class="col-xl-6">
    <div class="ratio ratio-16x9">
      <iframe
        src="https://www.youtube.com/embed/FJfwehhzIhw?autoplay=1&mute=1"
        title="[LIVE] 대한민국 24시간 뉴스채널 YTN"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        allowfullscreen>
      </iframe>
    </div>
  </div>

  <!-- 오른쪽: 2×2 그리드 -->
  <div class="col-xl-6">
    <!-- xl 이상에서 2칸, 그보다 작으면 1칸으로 자동 줄바꿈 -->
    <div class="row row-cols-2 row-cols-xl-2">
      <!-- (1) 일정 -->
      <div class="col-3">
        <div class="card">
          <div class="card-body" id="home-agenda-card">
          <a href="${pageContext.request.contextPath}/calendar" 
         class="stretched-link" 
         aria-label="일정 페이지로 이동"></a>
              <div class="d-flex align-items-center mb-2">
	      		<h4 class="card-title mb-1"><i class="uil-calender me-1"></i>일정</h4>
			 </div>
           <div id="home-agenda-rows" class="agenda-rows mt-2" role="list" aria-label="일정 목록"></div>
          </div>
        </div>
      </div>

      <!-- (2) 시청률(예: 차트 자리) -->
     <div class="col-3">
		<div class="card">
		    <div class="card-body" id="home-broadcast-card">
		     <a href="${pageContext.request.contextPath}/broadcast/list" 
		         class="stretched-link" 
		         aria-label="방송목록 페이지로 이동"></a>
		      <div class="d-flex align-items-center mb-2">
		        <h4 class="card-title mb-1"><i class="uil uil-tv-retro me-1"></i>방송편성</h4>
		      </div>
		      <div id="home-broadcast-rows" class="broadcast-rows mt-2" role="list" aria-label="방송 목록"></div>
		    </div>
		  </div>
		</div>

      <!-- (3) 공지사항 -->
      <div class="col-3">
        <div class="card">
          <div class="card-body" id="home-notice-card">
          <a href="${pageContext.request.contextPath}/board/1" 
	         class="stretched-link" 
	         aria-label="공지사항 페이지로 이동"></a>
            <div class="d-flex align-items-center mb-2">
	      		<h4 class="card-title mb-1"><i class="uil-exclamation-circle me-1"></i>공지사항</h4>
			 </div>
            <div id="home-notice-rows" class="notice-rows mt-2" role="list" aria-label="공지 목록"></div>
          </div>
        </div>
      </div>

      <!-- (4) 날씨 -->
      <div class="col-3">
        <div class="card">
          <div class="card-body">
            <div class="d-flex align-items-center mb-2">
            <h4 class="card-title mb-1"><i class="uil-cloud-question me-1"></i>날씨</h4>
             <input id="weather-city" class="form-control form-control-sm ms-auto" style="max-width:160px" placeholder="도시 (예: Seoul)">
            </div>
            <div id="weather-body">
              <div class="text-muted">불러오는 중...</div>
            </div>
          </div>
        </div>
      </div>

    </div><!-- /row-cols -->
  </div><!-- /col-xl-6 오른쪽 -->
</div><!-- /row g-3 -->
                        <!-- 긴급 공지 티커 -->
<div id="urgent-ticker" data-board-id="1" class="hide" role="status" aria-live="polite">
  <button type="button" class="ticker-close" aria-label="닫기">×</button>
  <div class="ticker-viewport">
    <div class="ticker-track"></div>
  </div>
</div>
         </div> <!-- container-fluid -->
     </div>
   </div>
   
 </div>
 
                     <!-- KOJ AI 챗봇 : 떠있는 버튼 -->
<button id="koj-chat-fab" aria-label="1:1 챗봇">
 <i class="mdi mdi-robot mdi-48px" aria-hidden="true"></i></button>

<!-- KOJ AI 챗봇 : 패널 -->
<div id="koj-chat-panel" class="hide" aria-live="polite" aria-label="KOJ AI 챗봇">
  <div class="chat-head">
    <strong>KOJ AI 챗봇</strong>
    <button id="koj-chat-close" aria-label="닫기">✕</button>
  </div>

  <div id="koj-chat-log" class="chat-log">
    <!-- 초기 안내 메시지 (원하면 지워도 됨) -->
    <div class="row bot">
      <div class="bubble">무엇을 도와드릴까요? 예) <em>근태</em></div>
      <div class="time"></div>
    </div>
  </div>

  <div class="chat-input">
    <input id="koj-chat-text" type="text" placeholder="메시지를 입력하세요…" autocomplete="off">
    <button id="koj-chat-send">전송</button>
  </div>
</div>

<div>
    <jsp:include page ="../views/nav/footer.jsp"></jsp:include>
</div>
<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>

</body>
<script src="${pageContext.request.contextPath}/resources/libs/apexcharts/apexcharts.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/fullcalendar/index.global.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/weather.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/home.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/chatbot.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
</html>