<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

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
                                    <div class="card-body">
                                        <div class="float-end">
                                            <div class="dropdown">
                                                <a class="dropdown-toggle text-reset" href="#" id="dropdownMenuButton1"
                                                    data-bs-toggle="dropdown" aria-haspopup="true"
                                                    aria-expanded="false">
                                                    <span class="fw-semibold">Sort By:</span> <span class="text-muted">Yearly<i class="mdi mdi-chevron-down ms-1"></i></span>
                                                </a>

                                                <div class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButton1">
                                                    <a class="dropdown-item" href="#">Monthly</a>
                                                    <a class="dropdown-item" href="#">Yearly</a>
                                                    <a class="dropdown-item" href="#">Weekly</a>
                                                </div>
                                            </div>
                                        </div>

                                        <h4 class="card-title mb-4">공지사항</h4>


                                        <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-primary me-2"></i> Desktops </p>
                                            </div>

                                            <div class="col-sm-9">
                                                <div class="progress mt-1" style="height: 6px;">
                                                    <div class="progress-bar progress-bar bg-primary" role="progressbar"
                                                        style="width: 52%" aria-valuenow="52" aria-valuemin="0"
                                                        aria-valuemax="52">
                                                    </div>
                                                </div>
                                            </div>
                                        </div> <!-- end row-->
                                  <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-info me-2"></i> iPhones </p>
                                            </div>
                                            <div class="col-sm-9">
                                                <div class="progress mt-1" style="height: 6px;">
                                                    <div class="progress-bar progress-bar bg-info" role="progressbar"
                                                        style="width: 45%" aria-valuenow="45" aria-valuemin="0"
                                                        aria-valuemax="45">
                                                    </div>
                                                </div>
                                            </div>
                                        </div> <!-- end row-->

                                        <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-success me-2"></i> Android </p>
                                            </div>
                                            <div class="col-sm-9">
                                                <div class="progress mt-1" style="height: 6px;">
                                                    <div class="progress-bar progress-bar bg-success" role="progressbar"
                                                        style="width: 48%" aria-valuenow="48" aria-valuemin="0"
                                                        aria-valuemax="48">
                                                    </div>
                                                </div>
                                            </div>
                                        </div> <!-- end row-->

                                        <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-warning me-2"></i> Tablets </p>
                                            </div>
                                            <div class="col-sm-9">
                                                <div class="progress mt-1" style="height: 6px;">
                                                    <div class="progress-bar progress-bar bg-warning" role="progressbar"
                                                        style="width: 78%" aria-valuenow="78" aria-valuemin="0"
                                                        aria-valuemax="78">
                                                    </div>
                                                </div>
                                            </div>
                                        </div> <!-- end row-->

                                        <div class="row align-items-center g-0 mt-3">
                                            <div class="col-sm-3">
                                                <p class="text-truncate mt-1 mb-0"><i class="mdi mdi-circle-medium text-purple me-2"></i> Cables </p>
                                            </div>
                                            <div class="col-sm-9">
                                                <div class="progress mt-1" style="height: 6px;">
                                                    <div class="progress-bar progress-bar bg-purple" role="progressbar"
                                                        style="width: 63%" aria-valuenow="63" aria-valuemin="0"
                                                        aria-valuemax="63">
                                                    </div>
                                                </div>
                                            </div>
                                        </div> <!-- end row-->

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
</body>
<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>
</html>