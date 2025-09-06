<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">

    <head>

        <meta charset="UTF-8" />
        <title>Broadcast Groupware</title>
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
                            <a href="/home" class="logo logo-dark">
                                <span class="logo-sm">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                                </span>
                                <span class="logo-lg">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-dark.png" alt="" height="20">
                                </span>
                            </a>

                            <a href="/home" class="logo logo-light">
                                <span class="logo-sm">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                                </span>
                                <span class="logo-lg">
                                    <img src="${pageContext.request.contextPath}/resources/images/logo-dark2.png" alt="" height="20">
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
                    <a href="/home" class="logo logo-dark">
                        <span class="logo-sm">
                            <img src="${pageContext.request.contextPath}/resources/images/logo-sm.png" alt="" height="22">
                        </span>
                        <span class="logo-lg">
                            <img src="${pageContext.request.contextPath}/resources/images/logo-dark2.png" alt="" height="60">
                        </span>
                    </a>

                    <a href="/home" class="logo logo-light">
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
                                <a href="/user/chat" class="waves-effect">
                                    <i class="uil-comments-alt"></i>
                                    <span>채팅</span>
                                </a>
                            </li>
                            <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-stopwatch me-1"></i>
                                    <span>근태</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="/attendance">내 근태</a>
								    </li>
								    <c:choose>
									    <c:when test="${loginUser.role == 'admin' or loginUser.userRank == '국장' }">
									    	<li>
				            					<a href="/attendanceList">직원 근태</a>
				            				</li>
				            			</c:when>
				            			<c:when test="${loginUser.role != 'admin' and loginUser.userRank == '팀장' }">
				            				<li>
				            					<a href="/attendanceList">팀원 근태</a>
				            				</li>
				            			</c:when>
				            			<c:when test="${loginUser.role != 'admin' and loginUser.userRank == '부서장' }">
				            				<li>
				            					<a href="/attendanceList">부서원 근태</a>
				            				</li>
				            			</c:when>
			            			</c:choose>
								</ul>
                             </li>
                            
                               
                             <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-sitemap"></i>
                                    <span>조직도</span>
                                </a>
	                                <ul class="sub-menu" aria-expanded="false">
									    <c:choose>
										    <c:when test="${loginUser.role == 'user'}">
			                     				<li>
											        <a href="/user/userList">직원 리스트</a>
											    </li>
									   		</c:when>
										    <c:when test="${loginUser.role == 'admin'}">
										    	<li>
					            					<a href="/admin/adminUserList">직원 관리</a>
					            				</li>
					            			</c:when>
				            			</c:choose>
									</ul>
                            </li>
                            <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-clipboard-alt"></i>
                                    <span>게시판</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false" id="board-menu-list">
								        <c:choose>
									        <c:when test="${loginUser.role == 'admin'}">
									            <li>
									                <a href="/admin/adminBoard">게시판 관리</a>
									            </li>
									        </c:when>
								        </c:choose>
								</ul>
                             </li>         
                       		 <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-clock-three me-1"></i>
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
								         </li>
								            <li>
								                <a href="/user/car">차량</a>
								            </li>
								</ul>
                             </li>         
							<li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil-desktop-alt"></i>
                                    <span>전자결재</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="/approval/document/main">문서 작성</a>
								    </li>
								    <li>
								        <a href="javascript: void(0);" class="has-arrow">받은 문서함</a>
								        <ul class="sub-menu" aria-expanded="false">
								    		<li>
								                <a href="/approval/received/pending">결재 대기 문서</a>
								            </li>
								            <li>
								                <a href="/approval/received/in-progress">결재 진행 문서</a>
								            </li>
								            <li>
								                <a href="/approval/received/completed">결재 종료 문서</a>
								            </li>
								            <li>
								                <a href="/approval/received/referenced">참조 문서</a>
								            </li>
								    	</ul>
								    </li>
								    <li>
								    	<a href="javascript: void(0);" class="has-arrow">내 문서함</a>
								    	<ul class="sub-menu" aria-expanded="false">
								    		<li>
								                <a href="/approval/documents/draft">임시저장 문서</a>
								            </li>
								            <li>
								                <a href="/approval/documents/in-progress">진행 중 문서</a>
								            </li>
								            <li>
								                <a href="/approval/documents/completed">종료 문서</a>
								            </li>
								    	</ul>
								    </li>
								</ul>
                             </li>     
                            <li>
                                <a href="javascript: void(0);" class="has-arrow waves-effect">
                                    <i class="uil uil-tv-retro me-1"></i>
                                    <span>방송편성</span>
                                </a>
                                <ul class="sub-menu" aria-expanded="false">
								    <li>
								        <a href="/broadcast/list">편성목록</a>
								    </li>
								    <li>
								        <a href="#">시청률</a>
								    </li>
								    <li>
								        <a href="#">편성표</a>
								    </li>
								</ul>
                             </li>       
                            </ul>
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

<script>
$(function () {
	  var ctx = '${pageContext.request.contextPath}';    // 컨텍스트
	  $.ajax({
	    url: ctx + '/board/menu',
	    method: 'GET',
	    success: function (data) {
	      var $ul = $('#board-menu-list');
	   // 1) 비우기 전에 "관리자 전용" 항목을 찾아서 보관
		//	    - href가 /admin/adminBoard 로 끝나는 항목을 안전하게 보존
			var $keep = $(); // 비어있는 jQuery 집합
			var $adminLi = $ul.find('a[href$="/admin/adminBoard"]').closest('li');
			if ($adminLi.length) $keep = $keep.add($adminLi.clone(true));
		
			// 2) 동적 항목 비우고(기존 로직) 보존본 먼저 복원
			$ul.empty();
			$ul.append($keep);
		
			// 3) 서버가 내려준 게시판 목록 다시 채우기(기존 로직 유지)
			data.forEach(function (menu) {
			  $('<li/>').append(
			    $('<a/>', {
			      href: ctx + '/board/' + menu.boardId,
			      text: menu.boardTitle,
			      'data-board-id': menu.boardId
			    })
			  ).appendTo($ul);
			});
			const IS_ADMIN = (document.getElementById('loginRole')?.value || '').toLowerCase().includes('admin');
	      var $parentLi = $ul.closest('li');
	      var $parentA  = $parentLi.children('a.has-arrow');

	      // ----- 현재 경로 계산 (컨텍스트 제거) -----
	      var path = location.pathname;
	      if (ctx && path.indexOf(ctx) === 0) path = path.slice(ctx.length);
	      var isBoard = /^\/board(\/|$)/.test(path);
	      var curId   = (path.match(/^\/board\/([^/?#]+)/) || [])[1];

	      // ----- 초기화 -----
	      $ul.find('a').removeClass('active');
	      $ul.find('li').removeClass('mm-active');
	      $ul.removeClass('mm-show').removeAttr('style');
	      $parentA.attr('aria-expanded', 'false');
	      $parentLi.removeClass('mm-active');

	      // ----- /board일 때만 펼치고 현재 항목 파랗게 -----
	      if (isBoard) {
	        $parentLi.addClass('mm-active');
	        $parentA.attr('aria-expanded', 'true');
	        $ul.addClass('mm-show').css('display', 'block');

	        if (curId) {
	          var $curA = $ul.find('a[href="' + ctx + '/board/' + curId + '"]');
	          $curA.addClass('active').closest('li').addClass('mm-active');
	        }
	      }

	      // 클릭 시 즉시 하이라이트(페이지 이동 전 미리 표시)
	      $ul.off('click.markActive')
	         .on('click.markActive', 'a[href^="' + ctx + '/board/"]', function () {
	           $ul.find('a').removeClass('active');
	           $ul.find('li').removeClass('mm-active');
	           $(this).addClass('active').closest('li').addClass('mm-active');
	         });

	      // 다른 루트 메뉴 클릭하면 '게시판' 접기
	      $('#side-menu').off('click.hideBoard')
	        .on('click.hideBoard', '> li > a.has-arrow', function () {
	          if (!$(this).is($parentA)) {
	            $ul.removeClass('mm-show').removeAttr('style');
	            $parentA.attr('aria-expanded', 'false');
	            $parentLi.removeClass('mm-active');
	          }
	        });
	    },
	    error: function () {
	      console.error('게시판 메뉴를 불러오는 데 실패했습니다.');
	    }
	  });
	});
</script>

</html>
