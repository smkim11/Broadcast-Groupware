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
            const role = '<c:out value="${sessionScope.loginUser.role}" />';
            console.log('User role from session:', role);
        </script>
    </c:if>
<title>Insert title here</title>
<style>
/* 날씨 카드 크게 보이게 */
#weather-body.weather-lg .icon   { width: 96px; height: 96px; }
#weather-body.weather-lg .temp   { font-size: 2.5rem; font-weight: 700; line-height: 1; }
#weather-body.weather-lg .city   { font-size: 1.1rem; font-weight: 600; }
#weather-body.weather-lg .desc   { font-size: 1.05rem; margin-top: .25rem; }
#weather-body.weather-lg .meta   { font-size: .95rem;  color: #6c757d; margin-top: .25rem; }

/* 넓은 화면에서는 더 크게 */
@media (min-width: 992px) {
  #weather-body.weather-lg .icon { width: 112px; height: 112px; }
/* 온도 숫자만 폰트 교체 + 여유 라인하이트 */
#weather-body.weather-lg .temp {
  font-family: 'Noto Sans KR', Arial, 'Apple SD Gothic Neo', system-ui, sans-serif !important;
  font-weight: 700;
  font-size: 3rem;
  line-height: 1.28;
  padding-top: 4px;
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
                         </div>
                     </div>
                 </div> 
                 <!-- end col-->
               </div>
               <!--  상단 4개카드 닫기 -->
                 
                 <!-- 중간 내용 2개 카드 -->
                  <div class="row">
                            <div class="col-xl-8">

                                     <div class="mt-1">
                                            <ul class="list-inline main-chart mb-0">
                                            <!-- 16:9 aspect ratio -->
                                        <div class="ratio ratio-16x9">
                                             <iframe width="943" height="530" src="https://www.youtube.com/embed/FJfwehhzIhw?autoplay=1&mute=1" 
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
                            
                            <div class="col-xl-4">
                                <div class="card">
                                    <div class="card-body" id="home-agenda-card">

                                          <div class="d-flex align-items-center justify-content-between">
										      <h4 class="card-title mb-0">이번 달 일정</h4>
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
                                        <h4 class="card-title mb-4">날씨</h4>
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
<div>
    <jsp:include page ="../views/nav/footer.jsp"></jsp:include>
</div>
<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>
</body>
<script src="${pageContext.request.contextPath}/resources/libs/fullcalendar/index.global.min.js"></script>
<script src="<c:url value='/resources/js/pages/weather.init.js'/>?v=2"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/home.init.js"></script>
</html>