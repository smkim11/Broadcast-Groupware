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
  <div class="card" id="card-vac">
    <div class="card-body">
      <!-- 제목 + 연차 기준 뱃지 + 전체보기(오른쪽) -->
      <div class="d-flex align-items-center justify-content-between">
        <div class="d-flex align-items-center">
         <h4 class="card-title mb-1">휴가</h4>
          <span id="vac-year-badge" class="badge bg-light text-body border ms-2">—</span>
        </div>
      </div>

      <!-- 내용 : 칩 2개 + 타일 1개 -->
      <div class="d-flex align-items-stretch gap-2 mt-2" id="vac-rows">
        <div class="vac-chip flex-fill text-center" id="vac-total" role="button" data-href="/vacation/summary">
          <div class="vac-chip-label">전체</div>
          <div class="vac-chip-value">0</div>
        </div>
        <div class="vac-chip flex-fill text-center" id="vac-remaining" role="button" data-href="/vacation/summary">
          <div class="vac-chip-label">잔여</div>
          <div class="vac-chip-value">0</div>
        </div>
        <div class="vac-tile flex-fill text-center" id="vac-approval" role="button" data-href="/vacation/approvals">
          <i class="mdi mdi-file-check-outline vac-tile-icon" aria-hidden="true"></i>
          <div class="vac-tile-label">결재</div>
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
					      		<h4 class="card-title mb-1">문서</h4>
					    			<span id="resv-range-label" class="title-inline-note ms-2">7일 기준</span>
					    			 <a href="/reservations" class="small text-muted ms-auto">전체 보기</a>
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
					      <h4 class="card-title mb-1">예약</h4>
					    	<span id="resv-range-label" class="title-inline-note ms-2">7일 기준</span>
						</div>
					
					      <!-- ▽ 도넛 3개가 가로로 나란히 -->
					     <div class="row text-center g-2" id="resv-donuts">
					  <div class="col-4">
					    <div id="donut-meeting" class="resv-donut"></div>
					    <div class="small text-muted mt-1">회의실</div>
					  </div>
					  <div class="col-4">
					    <div id="donut-edit" class="resv-donut"></div>
					    <div class="small text-muted mt-1">편집실</div>
					  </div>
					  <div class="col-4">
					    <div id="donut-vehicle" class="resv-donut"></div>
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
										      <h4 class="card-title mb-1">일정</h4>
										      <!-- 필요 없으면 이 링크는 지워도 됩니다 -->
										      <a href="/calendar" class="small text-muted">전체 보기</a>
										    </div>
										
										    <!-- 목록이 채워질 자리 -->
										    <div id="home-agenda-rows"></div>

                                    </div> <!-- end card-body-->
                                </div> <!-- end card-->
                            
                                <div class="card">
								  <div class="card-body" id="home-notice-card">
								    <div class="d-flex align-items-center justify-content-between">
								      <h4 class="mb-1 mt-1">공지사항</h4>
								      <a href="/board/notice" class="small text-muted">전체 보기</a>
								    </div>
								
								    <!-- 공지 리스트가 채워질 자리 -->
								    <div id="home-notice-rows" class="notice-rows mt-2" role="list" aria-label="공지 목록"></div>
								
								    <!-- 더보기(페이지네이션용, 필요 없으면 숨겨둠) -->
								    <button id="home-notice-more" class="btn btn-sm btn-light w-100 mt-2 d-none">더보기</button>
								  </div>
								</div>
                                
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
<script src="${pageContext.request.contextPath}/resources/libs/apexcharts/apexcharts.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/libs/fullcalendar/index.global.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/weather.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/home.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/chatbot.init.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/notice.init.js"></script>
</html>