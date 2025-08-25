<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">

    <head>

        <meta charset="UTF-8" />
        <title>Calendar | Minible - Admin & Dashboard Template</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="Premium Multipurpose Admin & Dashboard Template" name="description" />
        <meta content="Themesbrand" name="author" />
        <!-- App favicon -->
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/resources/images/favicon.ico">

        <!-- Bootstrap Css -->
        <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" id="bootstrap-style" rel="stylesheet" type="text/css" />
        <!-- Icons Css -->
        <link href="${pageContext.request.contextPath}/resources/css/icons.min.css" rel="stylesheet" type="text/css" />
        <!-- App Css-->
        <link href="${pageContext.request.contextPath}/resources/css/app.min.css" id="app-style" rel="stylesheet" type="text/css" />
        <!-- 뱃지알림 -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/custom.css?v=3">

    </head>

   <!-- <nav> -->
    <body>

    <!-- <body data-layout="horizontal" data-topbar="colored"> -->

        <!-- Begin page -->
        <div id="layout-wrapper">

            
            <header id="page-topbar">
                <div class="navbar-header">
                    <div class="d-flex">
                        <!-- LOGO -->
                        <div class="navbar-brand-box">
                            <a href="index.html" class="logo logo-dark">
                                <span class="logo-sm">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                                </span>
                                <span class="logo-lg">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-dark.png" alt="" height="20">
                                </span>
                            </a>

                            <a href="index.html" class="logo logo-light">
                                <span class="logo-sm">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                                </span>
                                <span class="logo-lg">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-light.png" alt="" height="20">
                                </span>
                            </a>
                        </div>

                        <button type="button" class="btn btn-sm px-3 font-size-16 header-item waves-effect vertical-menu-btn">
                            <i class="fa fa-fw fa-bars"></i>
                        </button>

                    </div>

                    <div class="d-flex">

                        <div class="dropdown d-inline-block d-lg-none ms-2">
                            <button type="button" class="btn header-item noti-icon waves-effect" id="page-header-search-dropdown"
                                data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="uil-search"></i>
                            </button>
                            <div class="dropdown-menu dropdown-menu-lg dropdown-menu-end p-0"
                                aria-labelledby="page-header-search-dropdown">
                    
                                <form class="p-3">
                                    <div class="m-0">
                                        <div class="input-group">
                                            <input type="text" class="form-control" placeholder="Search ..." aria-label="Recipient's username">
                                            <div class="input-group-append">
                                                <button class="btn btn-primary" type="submit"><i class="mdi mdi-magnify"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        

                        

                        <div class="dropdown d-none d-lg-inline-block ms-1">
                            <button type="button" class="btn header-item noti-icon waves-effect" data-bs-toggle="fullscreen">
                                <i class="uil-minus-path"></i>
                            </button>
                        </div>

                        <div class="dropdown d-inline-block">
                            <button type="button" class="btn header-item noti-icon waves-effect" id="page-header-notifications-dropdown"
                                data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <i class="uil-bell"></i>
                                <span class="badge bg-danger rounded-pill">3</span>
                            </button>
                            <div class="dropdown-menu dropdown-menu-lg dropdown-menu-end p-0"
                                aria-labelledby="page-header-notifications-dropdown">
                                <div class="p-3">
                                    <div class="row align-items-center">
                                        <div class="col">
                                            <h5 class="m-0 font-size-16"> Notifications </h5>
                                        </div>
                                        <div class="col-auto">
                                            <a href="#!" class="small"> Mark all as read</a>
                                        </div>
                                    </div>
                                </div>
                                <div data-simplebar style="max-height: 230px;">
                                    <a href="javascript:void(0);" class="text-dark notification-item">
                                        <div class="d-flex align-items-start">
                                            <div class="flex-shrink-0 me-3">
                                                <div class="avatar-xs">
                                                    <span class="avatar-title bg-primary rounded-circle font-size-16">
                                                        <i class="uil-shopping-basket"></i>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1">Your order is placed</h6>
                                                <div class="font-size-12 text-muted">
                                                    <p class="mb-1">If several languages coalesce the grammar</p>
                                                    <p class="mb-0"><i class="mdi mdi-clock-outline"></i> 3 min ago</p>
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                    <a href="javascript:void(0);" class="text-dark notification-item">
                                        <div class="d-flex align-items-start">
                                            <div class="flex-shrink-0 me-3">
                                                <img src="${pageContext.request.contextPath}/resources/images/users/user.png" class="rounded-circle avatar-xs" alt="user-pic">
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1">James Lemire</h6>
                                                <div class="font-size-12 text-muted">
                                                    <p class="mb-1">It will seem like simplified English.</p>
                                                    <p class="mb-0"><i class="mdi mdi-clock-outline"></i> 1 hour ago</p>
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                    <a href="javascript:void(0);" class="text-dark notification-item">
                                        <div class="d-flex align-items-start">
                                            <div class="flex-shrink-0 me-3">
                                                <div class="avatar-xs">
                                                    <span class="avatar-title bg-success rounded-circle font-size-16">
                                                        <i class="uil-truck"></i>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1">Your item is shipped</h6>
                                                <div class="font-size-12 text-muted">
                                                    <p class="mb-1">If several languages coalesce the grammar</p>
                                                    <p class="mb-0"><i class="mdi mdi-clock-outline"></i> 3 min ago</p>
                                                </div>
                                            </div>
                                        </div>
                                    </a>

                                    <a href="javascript:void(0);" class="text-dark notification-item">
                                        <div class="d-flex align-items-start">
                                            <div class="flex-shrink-0 me-3">
                                                <img src="${pageContext.request.contextPath}/resources/images/users/user.png" class="rounded-circle avatar-xs" alt="user-pic">
                                            </div>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-1">Salena Layfield</h6>
                                                <div class="font-size-12 text-muted">
                                                    <p class="mb-1">As a skeptical Cambridge friend of mine occidental.</p>
                                                    <p class="mb-0"><i class="mdi mdi-clock-outline"></i> 1 hours ago</p>
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                </div>
                                <div class="p-2 border-top">
                                    <div class="d-grid">
                                        <a class="btn btn-sm btn-link font-size-14 text-center" href="javascript:void(0)">
                                            <i class="uil-arrow-circle-right me-1"></i> View More..
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
					<!-- 로그인한 유저 이름 직급 -->
                        <div class="dropdown d-inline-block">
							   <c:set var="me" value="${sessionScope.loginUser}" />
							
							<c:if test="${not empty me}">
							  <button type="button" class="btn header-item waves-effect" id="page-header-user-dropdown"
							          data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
							
							      <c:choose>
							        <c:when test="${not empty me.userimagesName}">
							          <img class="rounded-circle header-profile-user"
							               src="<c:url value='${pageContext.request.contextPath}/resources/images/users/${me.userimagesName}'/>"
							               alt="Header Avatar" />
							        </c:when>
							        <c:otherwise>
							          <img class="rounded-circle header-profile-user"
							               src="<c:url value='${pageContext.request.contextPath}/resources/images/users/avatar-default.png'/>"
							               alt="Header Avatar" />
							        </c:otherwise>
							      </c:choose>
							
							      <span class="d-none d-xl-inline-block ms-1 fw-medium font-size-15">
							        ${me.fullName} ${me.userRank}
							      </span>
							
							      <i class="uil-angle-down d-none d-xl-inline-block font-size-15"></i>
							  </button>
							</c:if>
                            <div class="dropdown-menu dropdown-menu-end">
                                <!-- item-->
                                <a class="dropdown-item" href="/myPage" id="myPageBtn"><i class="uil uil-user-circle font-size-18 align-middle text-muted me-1"></i> <span class="align-middle">마이페이지</span></a>
                                <a class="dropdown-item" href="/logout"><i class="uil uil-sign-out-alt font-size-18 align-middle me-1 text-muted"></i> <span class="align-middle">로그아웃</span></a>
                            </div>
                        </div>

                        <div class="dropdown d-inline-block">
                            <button type="button" class="btn header-item noti-icon right-bar-toggle waves-effect">
                                <i class="uil-cog"></i>
                            </button>
                        </div>
            
                    </div>
                </div>
            </header>
            <!-- ========== Left Sidebar Start ========== -->
            <div class="vertical-menu">

                <!-- LOGO -->
                <div class="navbar-brand-box">
                    <a href="index.html" class="logo logo-dark">
                        <span class="logo-sm">
                            <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                        </span>
                        <span class="logo-lg">
                            <img src="${pageContext.request.contextPath}/resources/images/logo-dark.png" alt="" height="20">
                        </span>
                    </a>

                    <a href="index.html" class="logo logo-light">
                        <span class="logo-sm">
                            <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                        </span>
                        <span class="logo-lg">
                            <img src="${pageContext.request.contextPath}/resources/images/logo-light.png" alt="" height="20">
                        </span>
                    </a>
                </div>

                <button type="button" class="btn btn-sm px-3 font-size-16 header-item waves-effect vertical-menu-btn">
                    <i class="fa fa-fw fa-bars"></i>
                </button>

                <div data-simplebar class="sidebar-menu-scroll">

                    <!--- Sidemenu -->
                    <div id="sidebar-menu">
                        <!-- Left Menu Start -->
                        <ul class="metismenu list-unstyled" id="side-menu">
                            <li class="menu-title">메뉴</li>

                            <li>
                                <a href="/home">
                                    <i class="uil-home-alt"></i>
                                    <span>HOME</span>
                                </a>
                            </li>

                            <li>
                                <a href="/calendar" class="waves-effect">
                                    <i class="uil-calender"></i>
                                    <span>캘린더</span>
                                </a>
                            </li>

                            <li>
                                <a href="/user/chat" class=" waves-effect">
                                    <i class="uil-comments-alt"></i>
                                    <span>채팅</span>
                                </a>
                            </li>
                            <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-store"></i>
                                    <span>예약</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="javascript: void(0);" class="has-arrow">시설</a>
								        <ul class="sub-menu" aria-expanded="false">
								            <li>
								                <a href="/user/meetingroom">회의실</a>
								            </li>
								            <li>
								                <a href="/user/cuttingroom">편집실</a>
								            </li>
								         </ul>
								            <li>
								                <a href="/user/car">차량</a>
								            </li>
								        
							    </li>
								</ul>
                             </li>     
                             <li>
                                <a href="chat.html" class=" waves-effect">
                                    <i class="uil-comments-alt"></i>
                                    <span>조직도</span>
                                </a>
                            </li>
                            <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-store"></i>
                                    <span>게시판</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="#">공지사항</a>
								    </li>
								    <li>
								        <a href="#">요청게시판</a>
								    </li>
								</ul>
                             </li>         
                       		<li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-store"></i>
                                    <span>근태</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="/attendance">본인근태</a>
								    </li>
								    <li>
								        <a href="#">-근태</a>
								    </li>
								</ul>
                             </li>       
							<li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-store"></i>
                                    <span>결재</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="/approval/document/main">문서작성</a>
								    </li>
								    <li>
								        <a href="#">받은 문서함</a>
								    </li>
								    <li>
								    	<a href="javascript: void(0);" class="has-arrow">내 문서함</a>
								    	<ul class="sub-menu" aria-expanded="false">
								    		<li>
								                <a href="layouts-dark-sidebar.html">임시저장문서</a>
								            </li>
								            <li>
								                <a href="layouts-dark-sidebar.html">결재완료문서</a>
								            </li>
								            <li>
								                <a href="layouts-dark-sidebar.html">진행중문서</a>
								            </li>
								    	</ul>
								    </li>
								</ul>
                             </li>     
                            <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-store"></i>
                                    <span>방송편성</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="#">편성목록</a>
								    </li>
								    <li>
								        <a href="#">시청률</a>
								    </li>
								    <li>
								        <a href="#">편성표</a>
								    </li>
								</ul>
                             </li>       
                            
                    </div>
                    <!-- Sidebar -->
                </div>
            </div>
            <!-- Left Sidebar End -->

            

            <!-- ============================================================== -->
            <!-- Start right Content here -->
            <!-- ============================================================== -->
            

       

    </body>
   <!-- </nav> -->
</html>
