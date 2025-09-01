<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Program List</title>
</head>
<body>
<div>
    <jsp:include page="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- 페이지 타이틀 -->
            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">방송편성 목록</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item"><a href="javascript:void(0);">방송편성</a></li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 방송편성 목록 테이블 -->
            <div class="card">
                <div class="card-body">
                    <table class="table table-hover align-middle mb-0 text-center">
                        <thead class="table-light">
                            <tr>
                                <th style="width:10%;">번호</th>
                                <th style="width:35%;">프로그램명</th>
                                <th style="width:25%;">방영 기간</th>
                                <th style="width:20%;">방영 요일</th>
                            </tr>
                        </thead>
                        <tbody>
						    <c:forEach var="prog" items="${programs}" varStatus="status">
						        <tr>
			                        <td>
			                            <fmt:formatNumber value="${prog.broadcastScheduleId}" type="number" minIntegerDigits="4" groupingUsed="false"/>
			                        </td>
			                        <td class="text-center">
			                            <c:url var="detailUrl" value="/broadcast/detail/${prog.broadcastScheduleId}"/>
			                            <a href="${detailUrl}">
			                                <c:out value="${prog.broadcastFormName}"/>
			                            </a>
			                        </td>
			                        <td>
			                            <c:out value="${fn:substring(prog.broadcastFormStartDate,0,10)}"/> ~
			                            <c:out value="${fn:substring(prog.broadcastFormEndDate,0,10)}"/>
			                        </td>
			                        <td>
			                            <c:out value="${empty prog.broadcastDaysText ? '-' : prog.broadcastDaysText}"/>
			                        </td>
			                    </tr>
						    </c:forEach>
						    <c:if test="${empty programs}">
						        <tr>
						            <td colspan="4" class="text-muted">등록된 프로그램이 없습니다.</td>
						        </tr>
						    </c:if>
						</tbody>

                    </table>
                </div>
            </div>

            <!-- 검색 영역 -->
			<div class="row mt-3">
			    <div class="col-12">
			        <form method="get"
			              action="${pageContext.request.contextPath}/broadcast/list"
			              class="d-flex justify-content-center">
			            <input type="text" name="keyword" value="${param.keyword}"
			                   class="form-control" placeholder="프로그램명 검색"
			                   style="max-width: 360px;"/>
			            <button type="submit" class="btn btn-primary ms-2">검색</button>
			        </form>
			    </div>
			</div>
			
            <!-- 페이징 -->
			<nav class="mt-3">
			    <ul class="pagination pagination-sm justify-content-center mb-0 pagination-rounded gap-1">
			
			        <!-- 이전 (<) -->
			        <c:url var="prevUrl" value="/broadcast/list">
			            <c:param name="page" value="${pageDto.currentPage - 1}"/>
			            <c:param name="size" value="${pageDto.rowPerPage}"/>
			            <c:param name="keyword" value="${param.keyword}"/>
			        </c:url>
			        <li class="page-item ${pageDto.currentPage == 1 ? 'disabled' : ''}">
			            <a class="page-link shadow-sm" href="${prevUrl}" aria-label="이전">&lt;</a>
			        </li>
			
			        <!-- 현재 기준 -2 ~ +2 / 최대 5개 표시 -->
			        <c:set var="startPage" value="${pageDto.currentPage - 2 > 1 ? pageDto.currentPage - 2 : 1}"/>
		        	<c:set var="endPage"   value="${pageDto.currentPage + 2 < pageDto.lastPage ? pageDto.currentPage + 2 : pageDto.lastPage}"/>
			
			        <c:forEach var="i" begin="${startPage}" end="${endPage}">
			            <c:url var="pageUrl" value="/broadcast/list">
			                <c:param name="page" value="${i}"/>
			                <c:param name="size" value="${pageDto.rowPerPage}"/>
			                <c:param name="keyword" value="${param.keyword}"/>
			            </c:url>
			            <li class="page-item ${i == pageDto.currentPage ? 'active' : ''}">
			                <a class="page-link rounded-3 shadow-sm" href="${pageUrl}"
			                   <c:if test="${i == pageDto.currentPage}">aria-current="page"</c:if>>
			                    ${i}
			                </a>
			            </li>
			        </c:forEach>
			
			        <!-- 다음 (>) -->
			        <c:url var="nextUrl" value="/broadcast/list">
			            <c:param name="page" value="${pageDto.currentPage + 1}"/>
			            <c:param name="size" value="${pageDto.rowPerPage}"/>
			            <c:param name="keyword" value="${param.keyword}"/>
			        </c:url>
			        <li class="page-item ${pageDto.currentPage == pageDto.lastPage ? 'disabled' : ''}">
			            <a class="page-link rounded-0 shadow-sm" href="${nextUrl}" aria-label="다음">&gt;</a>
			        </li>
						
				</ul>
			</nav>

        </div>
    </div>
</div>

<div>
    <jsp:include page="../nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page="../nav/javascript.jsp"></jsp:include>
</div>
</body>
</html>