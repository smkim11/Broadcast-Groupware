<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- 날짜 포맷 -->
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>		<!-- 문서번호 포맷 -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>List Draft</title>
</head>
<body>
<div>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- 페이지 타이틀 -->
            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">임시저장 문서 목록</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item"><a href="javascript:void(0);">전자결재</a></li>
                                <li class="breadcrumb-item active">내 문서함</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 임시저장 문서 테이블 -->
            <div class="card">
                <div class="card-body">
                    <table class="table table-hover align-middle mb-0 text-center">
                        <thead class="table-light">
                            <tr>
                                <th style="width: 12%;">문서번호</th>
                                <th style="width: 48%;">제목</th>
                                <th style="width: 15%;">유형</th>
                                <th style="width: 15%;">기안일</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="doc" items="${docs}">
                                <tr>
                                    <td>
										<fmt:formatNumber value="${doc.approvalDocumentId}"
							                  type="number"
							                  minIntegerDigits="6"
							                  groupingUsed="false" />
									</td>
                                    <td class="text-start">
                                        <a href="${pageContext.request.contextPath}/approval/document/detail/${doc.approvalDocumentId}">
                                            <c:out value="${doc.approvalDocumentTitle}"/>
                                        </a>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${doc.documentType == 'COMMON'}">일반</c:when>
                                            <c:when test="${doc.documentType == 'BROADCAST'}">방송</c:when>
                                            <c:when test="${doc.documentType == 'VACATION'}">휴가</c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty doc.createDate}">
                                                ${fn:substring(doc.createDate, 0, 10)}
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty docs}">
                                <tr>
                                    <td colspan="4" class="text-center text-muted">임시저장 문서가 없습니다.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>
</div>

<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>

</body>
</html>