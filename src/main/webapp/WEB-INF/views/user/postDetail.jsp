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

/* 공통 모달 스타일 */
.modal {
    display: none;             /* 기본 숨김 */
    position: fixed;
    top: 0; left: 0;
    width: 100%; height: 100%;
    background: rgba(0,0,0,0.5); /* 반투명 배경 */
    z-index: 9999;

    display: flex;             /* flex 적용 */
    justify-content: center;   /* 가로 중앙 */
    align-items: center;       /* 세로 중앙 */
}

/* 모달 내용 박스 */
.modal-content {
    background-color: #fff;
    padding: 20px 25px;
    border-radius: 8px;
    width: 200px;               /* 기본 너비 */
    max-width: 40%;             /* 화면 작을 때 최대 너비 */
    box-sizing: border-box;
    box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    position: relative;
}

/* 모달 제목 */
.modal-content h3 {
    margin-top: 0;
    margin-bottom: 15px;
    font-size: 20px;
    text-align: center; /* 제목 중앙 정렬 */
}

/* 모달 input, textarea */
.modal-content input[type="text"],
.modal-content input[type="password"],
.modal-content textarea {
    width: 100%;
    padding: 8px 10px;
    margin-bottom: 15px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 14px;
    box-sizing: border-box;
}

/* 모달 버튼 */
.modal-content button {
    padding: 6px 12px;
    font-size: 14px;
    border-radius: 4px;
    cursor: pointer;
    margin-right: 8px;
}

/* 닫기 버튼 강조 */
.modal-content button.cancel {
    background-color: #e0e0e0;
    border: 1px solid #ccc;
}

.modal-content button.cancel:hover {
    background-color: #d5d5d5;
}

/* 확인 버튼 강조 */
.modal-content button.confirm {
    background-color: #007bff;
    color: #fff;
    border: none;
}

.modal-content button.confirm:hover {
    background-color: #0056b3;
}

/* 모바일 대응: 화면 작을 때 너비 조정 */
@media (max-width: 480px) {
    .modal-content {
        width: 90%;
        padding: 15px 20px;
    }
}

/* 버튼 */
/* 버튼 영역을 flex로 좌우 배치 */
.post-buttons {
    display: flex;
    justify-content: space-between; /* 좌우 정렬 */
    margin-top: 15px;
}

/* 좌측 버튼 그룹 */
.post-buttons .btn-left {
    display: flex;
    gap: 8px; /* 버튼 사이 간격 */
}

/* 우측 버튼 그룹 */
.post-buttons .btn-right {
    display: flex;
    gap: 8px;
}

/* 삭제 버튼 빨간색 */
.btn-danger {
    background-color: #dc3545;
    color: #fff;
    border: none;
}

.dropbtn {
    background-color: #f0f0f0;
    border: 1px solid #ccc;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 3px;
}
.dropbtn:hover {
    background-color: #e0e0e0;
}
.dropdown-content a:hover {
    background-color: #ddd;
}

.date {
	font-size: 11px;
	font-weight: 100;
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
					    <div class="content">
					        <div class="attachment-dropdown" style="position: relative; display: inline-block; float: right; margin-top: 5px;">
					            <button class="dropbtn">📎 첨부파일</button>
					            <div class="dropdown-content" style="display: none; position: absolute; right: 0; background-color: #f9f9f9; min-width: 160px; box-shadow: 0px 8px 16px rgba(0,0,0,0.2); z-index: 1;">
					                <c:forEach var="f" items="${fileList}">
					                    <a href="/file/download?fileId=${f.fileId}" style="display: block; padding: 5px 10px; text-decoration: none; color: #333;">
					                        ${f.fileName}
					                    </a>
					                </c:forEach>
					            </div>
					        </div>
					        
					        <div class="content-main">${c.postContent}</div>
					
					        <div style="clear: both;"></div>
					    </div>
					</c:forEach>
										
					<div class="comment">
					    <p>댓글</p>
					
					    <!-- 최상위 댓글 입력 -->
					    <div id="firstComment">
					        <textarea rows="2" cols="50" name="commentContent" placeholder="댓글입력"></textarea>
					        <button type="button" id="submitComment" class="btn btn-outline-primary waves-effect waves-light">등록</button>
					    </div>
					
					    <!-- 댓글 리스트 -->
					    <c:forEach var="co" items="${oneLevelComments}">
					        <div class="secondComment">
					            <input type="hidden" name="commentId" value="${co.commentId}">
					
					            <c:choose>
					                <c:when test="${co.commentStatus eq 'N'}">
					                    <p>삭제된 글입니다</p>
					                </c:when>
					                <c:otherwise>
					                    <span class="author">${co.userName} (${co.userRank})</span>
					                    <p class="commentContent">${co.commentContent}</p>
					                    <span class="date" style="font-weight: 300;">${co.createDate}</span>
					
					                    <!-- 본인 글 수정/삭제 -->
					                    <c:if test="${loginUser.userId eq co.userId}">
					                        <a class="editComment" data-id="${co.commentId}">수정</a>
					                        <a class="deleteComment" data-id="${co.commentId}">삭제</a>
					                    </c:if>
					
					                    <!-- 댓글 수정 폼 (숨김) -->
					                    <div class="editForm" style="display:none;">
					                        <textarea rows="2" class="editContent">${co.commentContent}</textarea>
					                        <a class="updateComment" data-id="${co.commentId}">수정</a>
					                        <a class="cancelEdit">취소</a>
					                    </div>
					
					                    <!-- 대댓글 작성 버튼 -->
					                    <a class="second ">댓글쓰기</a>
					
					                    <!-- 대댓글 입력 폼 -->
					                    <div class="secondForm" style="display:none;">
					                        <textarea rows="2" name="commentContent" placeholder="댓글입력"></textarea>
					                        <input type="hidden" name="parentCommentId" value="${co.commentId}">
					                        <a class="replySubmit">등록</a>
					                    </div>
					                </c:otherwise>
					            </c:choose>
					
					            <!-- 대댓글 리스트 -->
					            <c:forEach var="r" items="${co.replies}">
					                <div class="reply">
					                    <input type="hidden" name="commentId" value="${r.commentId}">
					
					                    <c:choose>
					                        <c:when test="${r.commentStatus eq 'N'}">
					                            <p>삭제된 글입니다</p>
					                        </c:when>
					                        <c:otherwise>
					                            <span class="author">${r.userName} (${r.userRank})</span>
					                            <p class="commentContent">${r.commentContent}</p>
					                            <span class="date" style="font-weight: 300;">${r.createDate}</span>
					
					                            <!-- 본인 대댓글 수정/삭제 -->
					                            <c:if test="${loginUser.userId eq r.userId}">
					                                <a class="editReply" data-id="${r.commentId}">수정</a>
					                                <a class="deleteReply" data-id="${r.commentId}">삭제</a>
					                            </c:if>
					
					                            <!-- 대댓글 수정 폼 (숨김) -->
					                            <div class="editForm" style="display:none;">
					                                <textarea rows="2" class="editContent">${r.commentContent}</textarea>
					                                <a class="updateComment" data-id="${r.commentId}">수정</a>
					                                <a class="cancelEdit">취소</a>
					                            </div>
					                        </c:otherwise>
					                    </c:choose>
					                </div>
					            </c:forEach>
					        </div>
					    </c:forEach>
					</div>


				</div>
				
			<!-- 버튼 영역 -->
			<div class="post-buttons">
			  <div class="btn-left">
			      <c:if test="${boardId == 1 and userRole == 'admin'}">
			          <c:forEach var="c" items="${detail}">
			              <button data-postid="${c.postId}"
			                      data-title="${c.postTitle}"
			                      data-content="${c.postContent}"
			                      class="deletePostBtn btn btn-danger">삭제</button>
			          </c:forEach>
			      </c:if>
			
			      <c:forEach var="c" items="${detail}">
			          <c:if test="${boardId != 1 and loginUser.userId == c.userId}">
			              <button data-postid="${c.postId}"
			                      data-title="${c.postTitle}"
			                      data-content="${c.postContent}"
			                      class="deletePostBtn btn btn-danger">삭제</button>
			          </c:if>
			      </c:forEach>
			  </div>
			
			  <div class="btn-right">
			      <c:if test="${boardId == 1 and userRole == 'admin'}">
			          <c:forEach var="c" items="${detail}">
			              <button data-postid="${c.postId}"
			                      data-title="${c.postTitle}"
			                      data-content="${c.postContent}"
			                      class="modifyPostBtn btn btn-outline-primary">수정</button>
			          </c:forEach>
			      </c:if>
			
			      <c:forEach var="c" items="${detail}">
			          <c:if test="${boardId != 1 and loginUser.userId == c.userId}">
			              <button data-postid="${c.postId}"
			                      data-title="${c.postTitle}"
			                      data-content="${c.postContent}"
			                      class="modifyPostBtn btn btn-outline-primary">수정</button>
			          </c:if>
			      </c:forEach>
			
			      <button onclick="window.close()" class="btn btn-outline-primary">닫기</button>
			    </div>
			</div>


			</div>
			
			<!-- 게시글 수정 모달 -->
			<div id="modifyPostModal" class="modal">
			    <div class="modal-content">
			        <h3>게시글 수정</h3>
			        <input type="hidden" id="modifyPostId">
			        <label>제목</label>
			        <input type="text" id="modifyTitle">
			        <label>내용</label>
			        <textarea id="modifyContent"></textarea>
			        <button id="confirmModify" class="confirm">수정</button>
			        <button id="cancelModify" class="cancel">닫기</button>
			    </div>
			</div>
			
			<!-- 게시글 삭제 모달 -->
			<div id="passwordModal" class="modal">
			    <div class="modal-content">
			        <h3>게시글 삭제</h3>
			        <input type="password" id="deletePassword" placeholder="비밀번호 입력">
			        <button id="confirmDelete" class="confirm">삭제 확인</button>
			        <button id="cancelDelete" class="cancel">취소</button>
			    </div>
			</div>

        </div>
    </div>
</div>


<script>
	// 첨부파일 
	document.querySelectorAll('.dropbtn').forEach(function(btn) {
	    btn.addEventListener('click', function(event) {
	        event.stopPropagation();
	        const dropdown = this.nextElementSibling;
	        const isVisible = dropdown.style.display === 'block';
	
	        document.querySelectorAll('.dropdown-content').forEach(d => d.style.display = 'none');
	
	        dropdown.style.display = isVisible ? 'none' : 'block';
	    });
	});
	
	window.addEventListener('click', function() {
	    document.querySelectorAll('.dropdown-content').forEach(d => d.style.display = 'none');
	});
	

	$(document).on("click", ".dropdown-content a, .fileDownload", function(e){
	    e.preventDefault(); 
	    var fileId = $(this).data("id") || $(this).attr("href").split("fileId=")[1];
	    console.log("다운로드 파일 id:", fileId);
	    window.location.href = "/file/download?fileId=" + fileId;
	});

	
	// 수정 버튼 클릭 시 → 게시글 내용 모달에 셋팅
	$(document).on("click", ".modifyPostBtn", function () {
		let postId = $(this).data("postid");
		let title = $(this).data("title");
		let content = $(this).data("content");
		
		//console.log('수정 게시글 id: ', postId);
		//console.log('수정 게시글 제목: ', title);
		//console.log('수정 게시글 내용: ', content);

		$("#modifyPostId").val(postId);
		$("#modifyTitle").val(title);
		$("#modifyContent").val(content);

		$("#modifyPostModal").css("display", "flex");
	});

	// 닫기 버튼
	$("#cancelModify").on("click", function () {
		$("#modifyPostModal").hide();
	});

	// 수정 확인 버튼 → Ajax 요청
	$("#confirmModify").on("click", function () {
		let postId = $("#modifyPostId").val();
		let title = $("#modifyTitle").val();
		let content = $("#modifyContent").val();

		$.ajax({
			url: "/board/modifyPost",
			type: "POST",
			data: {
				postId: postId,
				postTitle: title,
				postContent: content
			},
			success: function (res) {
				alert("게시글이 수정되었습니다.");
				location.reload();
			},
			error: function () {
				alert("수정 중 오류가 발생했습니다.");
			}
		});
	});

	

	
	// 게시글 삭제
	$('.deletePostBtn').on('click', function() {
	    var postId = $(this).data('postid');
	    $('#passwordModal').data('postid', postId).css('display','flex');
	});
	
	$('#cancelDelete').on('click', function() {
	    $('#passwordModal').hide();
	});
	
	$('#confirmDelete').on('click', function() {
	    var postId = $('#passwordModal').data('postid');
	    var password = $('#deletePassword').val();
	    
	    //console.log('삭제할 게시글 번호: ', postId);
	    //console.log('삭제할 게시글 암호: ', password);
	
	    $.ajax({
	        url: '/board/deletePost',
	        type: 'POST',
	        data: { postId: postId, postPassword: password },
	        success: function(res) {
	            if(res.success){
	                alert('게시글 삭제 완료');
		            if(window.opener && !window.opener.closed){
		                window.opener.location.reload();
		            }
		            
		            window.close();
	            } else {
	                alert('비밀번호가 틀렸습니다.');
	            }
	            $('#passwordModal').hide();
	        },
	        error: function() {
	            alert('삭제 중 오류 발생');
	            $('#passwordModal').hide();
	        }
	    });
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
	    $(document).on('click', '.replySubmit', function() {
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


	$(document).ready(function(){
	
	    // 댓글/대댓글 수정 버튼 클릭
	    $(document).on('click', '.editComment, .editReply', function(){
	        var parentDiv = $(this).parent(); 
	        parentDiv.find('> .editForm').show();  
	        parentDiv.find('> .commentContent').hide();
	        $(this).hide();                            
	    });
	
	    // 수정 취소
		$(document).on('click', '.cancelEdit', function() {

		    var parentDiv = $(this).closest('.secondComment, .reply');
		
		    parentDiv.find('.editForm').hide();
		
		    parentDiv.find('.commentContent').show();
		
		    parentDiv.find('.editComment, .editReply').show();
		});
	
	    // 댓글/대댓글 수정 완료
	    $(document).on('click', '.updateComment', function(){
	        var parentDiv = $(this).closest('div.secondComment, div.reply');
	        var commentId = $(this).data('id');
	        var newContent = parentDiv.find('.editContent').val().trim();
	
	        if(newContent === ''){
	            alert('댓글 내용을 입력해주세요.');
	            return;
	        }
	
	        $.ajax({
	            url: '/board/comment/modify',
	            type: 'POST',
	            contentType: 'application/json',
	            data: JSON.stringify({
	                commentId: commentId,
	                commentContent: newContent,
	                userId: $('#userId').val()
	            }),
	            success: function(res){
	                parentDiv.find('.commentContent').text(newContent).show();
	                parentDiv.find('.editForm').hide();
	                parentDiv.find('.editComment, .editReply').show();
	                location.reload();
	            },
	            error: function(err){
	                console.error(err);
	                alert('댓글 수정 실패');
	            }
	        });
	    });
	
	});
	
		// 댓글, 대댓글 삭제
		$(document).on('click', '.deleteComment, .deleteReply', function(){
		    var commentId = $(this).data('id');
		    
		    // console.log('삭제할 댓글 id: ', commentId);
		
		    if(!confirm('정말 삭제하시겠습니까?')){
		        return;
		    }
		
		    $.ajax({
		        url: '/board/comment/delete',
		        type: 'POST',
		        contentType: 'application/json',
		        data: JSON.stringify({ commentId: commentId }),
		        success: function(res){
		            alert('삭제되었습니다.');
		            location.reload();
		        },
		        error: function(err){
		            console.error(err);
		            alert('삭제 실패');
		        }
		    });
		});

	


</script>


</body>
</html>
