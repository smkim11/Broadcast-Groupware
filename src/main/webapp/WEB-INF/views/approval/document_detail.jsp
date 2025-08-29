<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Document Detail</title>
</head>
<body>
<jsp:include page ="../nav/header.jsp"></jsp:include>
<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">
	
	        <!-- 공통 정보 + 결재선/참조선 -->
	        <%@ include file="document_detail_body.jsp" %>

        </div>
    </div>
</div>
<jsp:include page="../nav/footer.jsp"/>
<jsp:include page="../nav/javascript.jsp"/>
</body>
</html>