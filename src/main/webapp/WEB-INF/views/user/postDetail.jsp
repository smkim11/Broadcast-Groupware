<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시판</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

</head>
<body>
<div>
    <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">상세페이지</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item" id="boardTitle"></li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            <input type="hidden" id="userId" value="${loginUser.userId}">

            <!-- 글 리스트 -->
			<div class="article-header">
            	<c:forEach var="c" items="${detail}">
		            <div class="title">
		                <h3 class="title">${c.postTitle}</h3>
		                <div class="info">${c.userName}(${c.userRank})</div>
		                <span class="date">${c.createDate}</span>
		            </div>
		        </c:forEach>
            </div>
            <div class="article-body">
            	<c:forEach var="c" items="${detail}">
		            <div class="content">
		                <div>${c.postContent}</div>
		            </div>
				</c:forEach>
				<div class="comment">
					<c:forEach var="co" items="${oneLevelComments}">
						<div>
							<span>${co.userName}(${co.userRank})</span>
							<p>${co.commentContent}</p>
							<a>${co.createDate} <a class="reComment">댓글쓰기</a></a>
						</div>
						
				        	<c:forEach var="r" items="${c.replies}">
					            <div class="reply" style="margin-left:20px;">
					                <p>${r.userName}(${r.userRank}): ${r.content}</p>
					            </div>
					        </c:forEach>
					</c:forEach>
				</div>	
			</div>
			
			<c:if test="${boardId == 1 and userRole == 'admin'}">
			    <a href="" class="btn btn-outline-primary waves-effect waves-light">삭제</a>
			    <a href="" class="btn btn-outline-primary waves-effect waves-light">수정</a>
			</c:if>
			
			<c:if test="${boardId != 1}">
			    <a href="" class="btn btn-outline-primary waves-effect waves-light">삭제</a>
			    <a href="" class="btn btn-outline-primary waves-effect waves-light">수정</a>
			</c:if>
			
			<a href="" class="btn btn-outline-primary waves-effect waves-light">닫기</a>

        </div>
    </div>
</div>


</body>
</html>
