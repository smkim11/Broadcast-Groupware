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

/* 댓글 전체 영역 */
.comment {
    margin-top: 20px;
}

/* 최상위 댓글 입력 폼 */
#firstComment {
    margin-bottom: 15px;
}

#firstComment textarea {
    width: 100%;
    resize: none;
}

#firstComment button {
    margin-top: 5px;
}

/* 댓글 리스트 - 최상위 댓글 */
.secondComment {
    padding: 10px;
    margin-top: 10px;
    border-top: 1px solid #eee;
    background-color: #fafafa;
    border-radius: 6px;
}

/* 댓글 작성자 / 내용 */
.secondComment span {
    font-weight: bold;
    margin-right: 8px;
}

.secondComment p {
    margin: 5px 0;
}

/* 대댓글 입력 폼 */
.secondForm {
    display: none;
    margin-top: 10px;
    margin-left: 30px; /* 최상위 댓글보다 들여쓰기 */
}

.secondForm textarea {
    width: 100%;
    resize: none;
}

.secondForm button {
    margin-top: 5px;
}

/* 대댓글 */
.reply {
    margin-left: 30px; /* 최상위 댓글보다 들여쓰기 */
    padding: 8px 12px;
    border-left: 2px solid #007bff;
    background-color: #f0f8ff;
    border-radius: 6px;
    margin-top: 5px;
}

.reply p {
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

.secondForm {
	display: none;
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
					<p>댓글
						<div id="firstComment">
							<textarea rows="2" cols="50" name="commentContent" placeholder="댓글입력"></textarea>
							<button type="button">등록</button>
						</div>
						<c:forEach var="co" items="${oneLevelComments}">
						    <div class="secondComment">
						        <input type="hidden" name="commentId" value="${co.commentId}">
						        <span>${co.userName}(${co.userRank})</span>
						        <p>${co.commentContent}</p>
						        <span>${co.createDate}</span>
						        <button type="button" class="second">댓글쓰기</button>
						        <div class="secondForm">
						            <textarea rows="2" cols="50" name="commentContent" placeholder="댓글입력"></textarea>
						            <button type="button">등록</button>
						        </div>
						
						        <!-- 대댓글 -->
						        <c:forEach var="r" items="${co.replies}">
						            <div class="reply">
						                <span>${r.userName}(${r.userRank})</span>
						                <p>${r.content}</p>
						                <span>${r.createDate}</span>
						            </div>
						        </c:forEach>
						    </div>
						</c:forEach>

					</div>	
				</div>
				
				<c:if test="${boardId == 1 and userRole == 'admin'}">
				    <a href="" class="btn btn-outline-primary waves-effect waves-light">삭제</a>
				    <a href="" class="btn btn-outline-primary waves-effect waves-light">수정</a>
				</c:if>
				
				<c:forEach var="c" items="${detail}">
				    <c:if test="${boardId != 1 and loginUser.userId == c.userId}">
				        <a href="/board/delete?postId=${c.postId}" class="btn btn-outline-primary waves-effect waves-light">삭제</a>
				        <a href="/board/edit?postId=${c.postId}" class="btn btn-outline-primary waves-effect waves-light">수정</a>
				    </c:if>
				</c:forEach>

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

	
	$(document).ready(function() {
	    // 등록 버튼 클릭 이벤트
	    $('#firstComment button').on('click', function() {
	        var commentContent = $('#firstComment textarea[name="commentContent"]').val().trim();
	        var postId = '${detail[0].postId}';
	        var userId = $('#userId').val();
	        
	        //console.log("게시글번호: ", postId);
	        //console.log("댓글: ", commentContent);

	        if(commentContent === '') {
	            alert('댓글을 입력해주세요.');
	            return;
	        }

	        
	        $.ajax({
	            url: '/board/comment/insert',
	            type: 'POST',
	            contentType: 'application/json',
	            data: JSON.stringify({
					userId: userId,
	                postId: postId,
	                commentContent: commentContent
	            }),
	            success: function(res) {
	                alert('댓글이 등록되었습니다.');

	                $('#firstComment textarea[name="commentContent"]').val('');

	                location.reload(); 
	            },
	            error: function(err) {
	                console.error(err);
	                alert('댓글 등록에 실패했습니다.');
	            }
	        });
	    });	
	});
	
    // 대댓글 등록
$(document).ready(function() {
    $('.secondForm').hide();

    // 댓글쓰기 버튼 클릭
    $(document).on('click', '.second', function() {
        $(this).siblings('.secondForm').toggle();
    });

    // 대댓글 등록
    $(document).on('click', '.secondForm button', function() {
        var form = $(this).closest('.secondForm');
        var commentContent = form.find('textarea[name="commentContent"]').val().trim();
        var commentParent = $(this).closest('.secondComment').find('input[name="commentId"]').val();
        var postId = '${detail[0].postId}';
        var userId = $('#userId').val();

        if(commentContent === '') {
            alert('댓글을 입력해주세요.');
            return;
        }

        $.ajax({
            url: '/board/cecondComment/insert',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({	
				userId: userId,
                postId: postId,
                commentParent: commentParent,
                commentContent: commentContent
            }),
            success: function(res) {
                alert('대댓글이 등록되었습니다.');
                form.find('textarea[name="commentContent"]').val('');
                location.reload();
            },
            error: function(err) {
                console.error(err);
                alert('대댓글 등록 실패');
            }
        });
    });
});




</script>


</body>
</html>
