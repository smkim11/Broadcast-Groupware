<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta charset="UTF-8">
	<c:if test="${not empty sessionScope.loginUser}">
        <script>
            const role = '<c:out value="${sessionScope.loginUser.role}" />';
            console.log('User role from session:', role);
        </script>
    </c:if>
<title>Insert title here</title>
<style>
/* 날씨 카드 크게 보이게 */
#weather-body.weather-lg .icon   { width: 96px; height: 96px; }
#weather-body.weather-lg .city   { font-size: 1.1rem; font-weight: 600; }
#weather-body.weather-lg .desc   { font-size: 1.05rem; margin-top: .25rem; }
#weather-body.weather-lg .meta   { font-size: .95rem;  color: #6c757d; margin-top: .25rem; }

/* 온도 숫자만 폰트 교체 + 여유 라인하이트 */
#weather-body.weather-lg .temp {
  font-family: 'Noto Sans KR', Arial, 'Apple SD Gothic Neo', system-ui, sans-serif !important;
  font-weight: 700;
  font-size: 3rem;
  line-height: 1.05;
  padding-top: 0px;
}

/* ============ 공통 ============ */
#koj-chat-fab, #koj-chat-panel { z-index: 2147483647; }
/* 떠있는 버튼: 원형 + 회색 */
#koj-chat-fab{
  position: fixed; right: 20px; bottom: 20px;
  width: 80px; height: 80px;               /* 정사각형 → 원형 기준 */
  border-radius: 50%;                       /* 원형 만들기 */
  background: #6c757d;                      /* 회색(secondary) */
  color: #fff;                              /* 아이콘 색(흰색) */
  border: 0; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8px 24px rgba(0,0,0,.18);
  z-index: 2147483647;                      /* 다른 요소 위로 */
}
#koj-chat-fab .mdi{ font-size: 26px; line-height: 1; } /* 아이콘 크기 */
#koj-chat-fab:hover{ background:#5c636a; }             /* 살짝 진한 회색 */
#koj-chat-panel{
  position: fixed; right: 20px; bottom: 80px; width: 360px; max-width: calc(100% - 40px);
  background:#fff; border-radius: 0px; box-shadow: 0 16px 40px rgba(0,0,0,.2);
  display: flex; flex-direction: column; overflow: hidden;
  border:1px solid #e9ecef;
}
#koj-chat-panel.hide{ display:none; }

.chat-head{
  height: 48px; display:flex; align-items:center; justify-content:space-between;
  padding:0 12px; background:#f8f9fa; border-bottom:1px solid #e9ecef;
}
#koj-chat-close{ border:none; background:transparent; font-size:18px; cursor:pointer; }

.chat-log{
  height: 360px; overflow:auto; padding: 12px; background:#fafafa;
}
.chat-input{
  display:flex; gap:6px; padding: 10px; border-top:1px solid #e9ecef; background:#fff;
}
.chat-input input{ flex:1; padding:8px 10px; border:1px solid #dee2e6; border-radius:8px; }
.chat-input button{ padding:8px 12px; border:none; background:#0d6efd; color:#fff; border-radius:8px; cursor:pointer; }

/* ============ 말풍선 ============ */
.row{ display:flex; margin: 6px 0; }
.row.user{ justify-content: flex-end; }
.row.bot{  justify-content: flex-start; }

.bubble{
  max-width: 75%;
  padding: 8px 10px; border-radius: 14px;
  background:#e9ecef; color:#111; line-height:1.25;
  word-break: break-word; white-space: pre-wrap;
}
.row.user .bubble{ background:#0d6efd; color:#fff; }
.time{ align-self: flex-end; font-size:11px; color:#868e96; margin: 0 6px; min-width: 58px; }

/* 하이퍼링크 리스트가 들어오는 경우 보기 좋게 */
.bubble ul{ padding-left:18px; margin: 6px 0 0; }
.bubble a{ color:inherit; text-decoration: underline; }
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
                     <div class="card">
                         <div class="card-body">
                             <div class="float-end mt-2">
                                 <div id="total-revenue-chart" data-colors='["--bs-primary"]'></div>
                             </div>
                             <div>
                                 <h4 class="mb-1 mt-1">근태관리</h4>
                                 <p class="text-muted mb-0">Total Revenue</p>
                             </div>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                         </div>
                     </div>
                 </div>
                 <!-- end col-->
                 
                 <div class="col-md-6 col-xl-3">
                     <div class="card">
                         <div class="card-body">
                             <div class="float-end mt-2">
                                 <div id="total-revenue-chart" data-colors='["--bs-primary"]'></div>
                             </div>
                             <div>
                                 <h4 class="mb-1 mt-1">휴가관리</h4>
                                 <p class="text-muted mb-0">Total Revenue</p>
                             </div>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                              </p>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                         </div>
                     </div>
                 </div> 
                 <!-- end col-->
                 
                 <div class="col-md-6 col-xl-3">
                     <div class="card">
                         <div class="card-body">
                             <div class="float-end mt-2">
                                 <div id="total-revenue-chart" data-colors='["--bs-primary"]'></div>
                             </div>
                             <div>
                                 <h4 class="mb-1 mt-1">문서관리</h4>
                                 <p class="text-muted mb-0">Total Revenue</p>
                             </div>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                              </p>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                         </div>
                     </div>
                 </div> 
                 <!-- end col-->
                 
                 <div class="col-md-6 col-xl-3">
                     <div class="card">
                         <div class="card-body">
                             <div class="float-end mt-2">
                                 <div id="total-revenue-chart" data-colors='["--bs-primary"]'></div>
                             </div>
                             <div>
                                 <h4 class="mb-1 mt-1">예약현황</h4>
                                 <p class="text-muted mb-0">Total Revenue</p>
                             </div>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                              </p>
                             <p class="text-muted mt-3 mb-0"><span class="text-success me-1"><i class="mdi mdi-arrow-up-bold me-1"></i>2.65%</span> since last week
                             </p>
                         </div>
                     </div>
                 </div> 
                 <!-- end col-->
               </div>
               <!--  상단 4개카드 닫기 -->
                 
                 <!-- 중간 내용 2개 카드 -->
                  <div class="row">
                            <div class="col-xl-9">

                                     <div class="mt-1">
                                            <ul class="list-inline main-chart mb-0">
                                            <!-- 16:9 aspect ratio -->
                                        <div class="ratio ratio-21x9">
                                             <iframe src="https://www.youtube.com/embed/FJfwehhzIhw?autoplay=1&mute=1" 
                                             		 title="[LIVE] 대한민국 24시간 뉴스채널 YTN" 
                                             		 frameborder="0" 
                                             		 allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                                             		 referrerpolicy="strict-origin-when-cross-origin" 
                                             		 allowfullscreen>
                                             </iframe>
                                        </div>
                                         </ul>
                                       </div>

                                        <div class="mt-3">
                                            <div id="sales-analytics-chart" data-colors='["--bs-primary", "#dfe2e6", "--bs-warning"]' class="apex-charts" dir="ltr"></div>
                                        </div>
                            </div> <!-- end col-->
                            
                            <div class="col-xl-3">
                                <div class="card">
                                    <div class="card-body" id="home-agenda-card">

                                          <div class="d-flex align-items-center justify-content-between">
										      <h4 class="mb-1 mt-1">일정</h4>
										      <!-- 필요 없으면 이 링크는 지워도 됩니다 -->
										      <a href="/calendar" class="small text-muted">전체 보기</a>
										    </div>
										
										    <!-- 목록이 채워질 자리 -->
										    <div id="home-agenda-rows"></div>

                                    </div> <!-- end card-body-->
                                </div> <!-- end card-->
                            
                                <div class="card">
                                    <div class="card-body">
                                        <h4 class="card-title mb-4">공지사항</h4>

                                        <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-primary me-2"></i> Desktops </p>
                                            </div>
                                        </div> <!-- end row-->
                                  <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-info me-2"></i> iPhones </p>
                                            </div>
                                        </div> <!-- end row-->

                                        <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-success me-2"></i> Android </p>
                                            </div>
                                        </div> <!-- end row-->
                                        
                                         <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-success me-2"></i> Android </p>
                                            </div>
                                        </div> <!-- end row-->

                                    </div> <!-- end card-body-->
                                </div> <!-- end card-->
                                
                                    <div class="card">
                                    <div class="card-body">
                                        <div class="float-end">
                                        <input id="weather-city" class="form-control form-control-sm" style="max-width: 160px;" placeholder="도시 (예: Seoul)">
                                        </div>
                                        <h4 class="card-title mb-0">날씨</h4>
									  <div class="card-body" id="weather-body">
									    <div class="text-muted">불러오는 중...</div>
									  </div>

                                    </div> <!-- end card-body-->
                                </div> <!-- end card-->
                                
                                
                            </div> <!-- end Col -->
                        </div> <!-- end row-->
                        
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
      <div class="bubble">무엇을 도와드릴까요? 예) <em>이번달 외근 몇개</em>, <em>어제 출근시간</em></div>
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
<script src="${pageContext.request.contextPath}/resources/libs/fullcalendar/index.global.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/weather.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/home.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/chatbot.init.js"></script>
</html>