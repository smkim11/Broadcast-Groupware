<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시판</title>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<style>
/* 간단한 스타일 */
#post-list { width: 100%; border-collapse: collapse; }
#post-list th, #post-list td { border: 1px solid #ddd; padding: 8px; }
#pagination a { margin: 0 2px; cursor: pointer; text-decoration: none; }
#pagination span.active { font-weight: bold; }

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
                        <h4 class="mb-0">게시판</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item" id="boardTitle"></li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
	
            <!-- 글 리스트 -->
            <table id="post-list">
                <thead>
                    <tr>
                        <th>번호</th>
                        <th>제목</th>
                        <th>작성자</th>
                        <th>작성일</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- JS에서 동적 생성 -->
                </tbody>
            </table>
            
           	<a href="" id="insertPostModal" class="btn btn-outline-primary waves-effect waves-light">글쓰기</a>

            <!-- 페이징 -->
            <div class="pagination" id="pagination"></div>

            <!-- 검색 -->
            <form id="searchForm">
                <select name="searchType">
                    <option value="title">제목</option>
                    <option value="userName">작성자</option>
                    <option value="category">카테고리</option>
                </select>
                <input type="text" name="searchWord" placeholder="검색어 입력">
                <button type="submit">검색</button>
            </form>

        </div>
    </div>
</div>

<!-- 글쓰기 모달 -->
<div id="postModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; 
    background:rgba(0,0,0,0.5); justify-content:center; align-items:center;">
    <div style="background:white; padding:20px; width:500px; border-radius:8px; position:relative;">
        <h3>게시글 작성</h3>
        <form id="postForm" enctype="multipart/form-data">
            <input type="hidden" name="boardId" id="modalBoardId" value="">
            <div style="margin-bottom:10px;">
                <label>제목</label><br>
                <input type="text" name="postTitle" style="width:100%;" required>
            </div>
            <div style="margin-bottom:10px;">
                <label>내용</label><br>
                <textarea name="postContent" rows="5" style="width:100%;" required></textarea>
            </div>
            <div style="margin-bottom:10px;">
                <label>파일 업로드</label><br>
                <input type="file" name="files" multiple>
            </div>
            <div style="text-align:right;">
                <button type="button" id="closePostModal">닫기</button>
                <button type="submit">등록</button>
            </div>
        </form>
    </div>
</div>

<script>
	var currentBoardId = null;
	var currentPage = 1;
	
	// 게시판 메뉴 클릭 시 호출
	window.loadBoard = function(boardId, boardTitle) {
	    currentBoardId = boardId;
	    currentPage = 1;
	    $('#boardTitle').text(boardTitle);
	    loadPosts();
	};
	
	// 글 리스트 로드
	function loadPosts() {
	    if (!currentBoardId) return;
	
	    var formData = $('#searchForm').serialize();
	    $.ajax({
	        url: '/board/' + currentBoardId + '/posts',
	        type: 'GET',
	        data: formData + '&currentPage=' + currentPage,
	        success: function(data) {
	            var tbody = $('#post-list tbody');
	            tbody.empty();
	
	            var posts = data.posts;
	            var pageDto = data.pageDto;
	
	            if (!posts || posts.length === 0) {
	                tbody.append('<tr><td colspan="4">게시글이 없습니다.</td></tr>');
	                $('#pagination').empty();
	                return;
	            }
	
	            posts.forEach(function(post) {
	                tbody.append('<tr>'
	                    + '<td>' + post.postId + '</td>'
	                    + '<td>' + post.title + '</td>'
	                    + '<td>' + post.userName + '</td>'
	                    + '<td>' + post.createDate + '</td>'
	                    + '</tr>');
	            });
	
	            loadPagination(pageDto);
	        },
	        error: function() {
	            console.error('게시글을 불러오는 데 실패했습니다.');
	        }
	    });
	}
	
	// 페이징 생성
	function loadPagination(pageDto) {
	    if (!pageDto) return;
	    var container = $('#pagination');
	    container.empty();
	
	    if (pageDto.startPage > 1) {
	        container.append('<a href="javascript:void(0);" onclick="goPage(' + (pageDto.startPage - 1) + ')">&lt;</a>');
	    }
	    for (var i = pageDto.startPage; i <= pageDto.endPage; i++) {
	        if (i === pageDto.currentPage) {
	            container.append('<span class="active">' + i + '</span>');
	        } else {
	            container.append('<a href="javascript:void(0);" onclick="goPage(' + i + ')">' + i + '</a>');
	        }
	    }
	    if (pageDto.endPage < pageDto.lastPage) {
	        container.append('<a href="javascript:void(0);" onclick="goPage(' + (pageDto.endPage + 1) + ')">&gt;</a>');
	    }
	}
	
	function goPage(page) {
	    currentPage = page;
	    loadPosts();
	}
	
	// 검색 submit
	$('#searchForm').on('submit', function(e) {
	    e.preventDefault();
	    currentPage = 1;
	    loadPosts();
	});
	
	// 메뉴 로드 및 첫 게시판 자동 선택
	$(document).ready(function() {
	    $.ajax({
	        url: '/board/menu',
	        method: 'GET',
	        success: function(data) {
	            var menuList = $('#board-menu-list');
	            menuList.empty();
	
	            data.forEach(function(menu, index) {
	                var li = $('<li></li>');
	                var link = $('<a href="javascript:void(0);"></a>').text(menu.boardTitle);
	
	                link.on('click', function(e) {
	                    e.preventDefault();
	                    loadBoard(menu.boardId, menu.boardTitle);
	                });
	
	                li.append(link);
	                menuList.append(li);
	
	                if(index === 0) {
	                    loadBoard(menu.boardId, menu.boardTitle);
	                }
	            });
	        },
	        error: function() {
	            console.error('게시판 메뉴를 불러오는 데 실패했습니다.');
	        }
	    });
	});
	
	// 모달 열기
	$('#insertPostModal').on('click', function(e) {
	    e.preventDefault(); // 링크 기본 동작 차단
	    if(!currentBoardId){
	        alert('게시판을 먼저 선택해주세요.');
	        return;
	    }
	    $('#modalBoardId').val(currentBoardId);
	    $('#postModal').css('display', 'flex');
	});
	
	// 모달 닫기
	$('#closePostModal').on('click', function() {
	    $('#postModal').hide();
	});
	
	// 글쓰기 폼 제출
	$('#postForm').on('submit', function(e) {
	    e.preventDefault();
	
	    var formData = new FormData(this);
	
	    $.ajax({
	        url: '/board/insertPost', 
	        type: 'POST',
	        data: formData,
	        processData: false,
	        contentType: false,
	        success: function(res) {
	            alert('게시글 등록 성공');
	            $('#postModal').hide();
	            loadPosts();
	        },
	        error: function() {
	            alert('게시글 등록 실패');
	        }
	    });
	});

</script>

</body>
</html>
