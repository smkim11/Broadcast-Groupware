<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시판</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

<style>
/* main-contain 전체 영역 */
.main-contain {
    padding: 20px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: 0 0 10px rgba(0,0,0,0.05);
}

/* 글 리스트 전체 */
.article-header {
    border-bottom: 1px solid #ddd;
    padding-bottom: 15px;
    margin-bottom: 20px;
}

.article-header .title {
    margin-bottom: 10px;
}

.article-header .title h3.title {
    font-size: 24px;
    margin: 0 0 5px 0;
}

.article-header .title .info {
    font-size: 14px;
    color: #555;
    margin-bottom: 2px;
}

.article-header .title .date {
    font-size: 12px;
    color: #999;
}

/* 게시글 내용 */
.article-body .content {
    font-size: 16px;
    line-height: 1.6;
    padding: 15px;
    background: #f9f9f9;
    border-radius: 6px;
    margin-bottom: 20px;
}

/* 댓글 영역 */
.comment {
    margin-top: 30px;
}

.comment .main-comment {
    border-top: 1px solid #eee;
    padding: 10px 0;
}

.comment .main-comment span {
    font-weight: bold;
    margin-right: 10px;
}

.comment .main-comment p {
    margin: 5px 0;
}

.comment .main-comment a.reComment {
    font-size: 12px;
    color: #007bff;
    cursor: pointer;
    text-decoration: none;
}

.comment .main-comment a.reComment:hover {
    text-decoration: underline;
}

/* 대댓글 */
.comment .reply {
    margin-left: 40px;  /* 댓글보다 더 오른쪽으로 들여쓰기 */
    padding-left: 10px;
    border-left: 2px solid #ddd;
    margin-top: 5px;
    background-color: #f8f8f8;
    border-radius: 4px;
    padding: 8px;
}

.comment .reply p {
    margin: 0;
    font-size: 14px;
}

/* 버튼 스타일 */
.btn {
    display: inline-block;
    padding: 6px 12px;
    margin: 5px 5px 0 0;
    font-size: 14px;
    border-radius: 4px;
    text-decoration: none;
    cursor: pointer;
    transition: 0.2s;
}

.btn-outline-primary {
    border: 1px solid #007bff;
    color: #007bff;
    background-color: transparent;
}

.btn-outline-primary:hover {
    background-color: #007bff;
    color: #fff;
}

a.btn {
    text-decoration: none;
}

/* 닫기 버튼 강조 */
a.btn:last-of-type {
    background-color: #e0e0e0;
    color: #333;
    border: 1px solid #ccc;
}

a.btn:last-of-type:hover {
    background-color: #d5d5d5;
}
</style>

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
			
			<div class="main-contain">
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
	            		<c:forEach var="f" items="${fileList}">
			                <div class="file">${f.fileName}<button type="button" class="fileDownload" data-id="${f.fileId}">파운로드</button></div>
			            </c:forEach>
			            <div class="content">
			                <div class="content-main">${c.postContent}</div>
			            </div>
					</c:forEach>
					<div class="comment">
						<c:forEach var="co" items="${oneLevelComments}">
							<div class="main-comment">
								<span>${co.userName}(${co.userRank})</span>
								<p>${co.commentContent}</p>
								<a>${co.createDate} <a class="reComment">댓글쓰기</a></a>
							</div>
							
					        	<c:forEach var="r" items="${c.replies}">
						            <div class="reply">
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
</div>
<script>
	$(document).on("click", ".fileDownload", function(){
	    var fileId = $(this).data("id");
	    console.log("다운로드 파일 id", fileId);
	    window.location.href = "/file/download?fileId=" + fileId;
	});
</script>


</body>
</html>
