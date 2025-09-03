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

/* 검색 */
/* 검색 폼 전체 영역 */
.searchForm {
    margin-top: 15px;
}

/* 검색 영역 박스 */
.search-main {
    display: flex;
    align-items: center;
    gap: 8px; 
    padding: 10px 15px;
    border-radius: 8px;
}

/* 셀렉트박스 */
.search-main select {
    padding: 6px 10px;
    border: 1px solid #ccc;
    border-radius: 6px;
    background-color: #fff;
    font-size: 14px;
}

/* 입력창 */
.search-main input[type="text"] {
    flex: 1; /* 가로 공간 꽉 채움 */
    border-radius: 6px;
    font-size: 14px;
}

/* 검색 버튼 */
.search-main button {
    border-radius: 6px;
    padding: 6px 14px;
    font-size: 14px;
    transition: all 0.2s ease-in-out;
}

#insertPostModal {
    display: inline-block; /* 버튼 기본 표시 유지 */
}

/* 버튼 우측 정렬 */
.button-container {
    display: flex;
    justify-content: flex-end; /* 우측 정렬 */
    margin-bottom: 1rem; /* 필요 시 여백 */
}

/* 테이블 */
#post-list {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed; /* 열 너비 고정 */
}

#post-list th, #post-list td {
    border: 1px solid #ddd;
    padding: 14px 8px;
    word-wrap: break-word; /* 긴 내용 줄바꿈 */
    text-align: center; /* 필요 시 중앙 정렬 */
}

/* 각 컬럼 고정 너비 지정 */
#post-list th:nth-child(1), #post-list td:nth-child(1) {
    width: 60px; /* 번호 */
}

#post-list th:nth-child(2), #post-list td:nth-child(2) {
    width: 50%; /* 제목 */
    text-align: center;
}

#post-list th:nth-child(3), #post-list td:nth-child(3) {
    width: 20%; /* 작성자 */
}

#post-list th:nth-child(4), #post-list td:nth-child(4) {
    width: 20%; /* 작성일 */
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
                        <h4 class="mb-0" id="boardTitle"></h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item">게시판</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
            <input type="hidden" id="loginRole" value="${loginUser.role}">
            
            <div class="button-container">
			    <a href="" id="insertPostModal" class="btn btn-outline-primary waves-effect waves-light">글쓰기</a>
			</div>

	
            <!-- 글 리스트 -->
            <table id="post-list" class="table table-striped">
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
            
            <!-- 검색 -->
		   	<div class="row mt-3">
			    <div class="col-12">
		            <form id="searchForm" class="d-flex justify-content-center">
			            <div id="search-main" class="search-main">
			                <select name="searchType" id="searchType" class="btn btn-light waves-effect">
			                    <option value="title">제목</option>
			                    <option value="userName">작성자</option>
			
			                </select>
			                <input type="text" name="searchWord" class="form-control" style="max-width: 360px;" placeholder="검색어 입력">
			                <button type="submit" class="btn btn-primary ms-2">검색</button>
		                </div>
		            </form>
		        </div>
		    </div>   
		    
		    <!-- 페이징 -->
            <div class="d-flex justify-content-center mt-3" id="pagination"></div> 

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
            <div style="margin-bottom:10px;">
                <label>비밀번호</label><br>
                <input type="text" name="postPassword" style="width:100%;" required>
            </div>
            <div style="text-align:right;">
                <button type="button" id="closePostModal">닫기</button>
                <button type="submit">등록</button>
            </div>
        </form>
    </div>
</div>
<div><jsp:include page ="../nav/footer.jsp"></jsp:include></div>
<div><jsp:include page ="../nav/javascript.jsp"></jsp:include></div>
<script>
	var currentBoardId = null;
	var currentPage = 1;
	var userRole = '${loginUser.role}';
	
	// 게시판 메뉴 클릭 시 호출
	window.loadBoard = function(boardId, boardTitle) {
	    currentBoardId = boardId;
	    currentPage = 1;
	    $('#boardTitle').text(boardTitle);
	
	    // 공지사항게시판 관리자만 글쓰기 버튼
	    if (boardId === 1 && userRole !== 'admin') {
	        $('#insertPostModal').hide();
	    } else {
	        $('#insertPostModal').show();
	    }
	
	    loadPosts(); 
	};
	
	// 글 리스트 로드
	function loadPosts() {
	    if (!currentBoardId) return;
	
	    var formData = $('#searchForm').serialize();
	    $.ajax({
	        url: '/board/' + currentBoardId + '/posts',
	        type: 'GET',
	        data: $('#searchForm').serialize() + '&currentPage=' + currentPage,
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
	                    +'<td><a href="/post/detail?postId=' + post.postId + '&boardId=' + currentBoardId + '" target="_blank">' + post.title + '</a></td>'
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
	
	    var ul = $('<ul class="pagination pagination-sm justify-content-center mb-0 pagination-rounded gap-1"></ul>');
	
	    // 이전 블럭
	    if (pageDto.hasPrev) {
	        ul.append(
	            '<li class="page-item">' +
	                '<a class="page-link" href="javascript:void(0);" onclick="goPage(' + Math.max(pageDto.startPage - 1, 1) + ')">&lt;</a>' +
	            '</li>'
	        );
	    }
	
	    // 페이지 번호
	    var maxPage = Math.min(pageDto.endPage, pageDto.lastPage); // 안전하게 lastPage 제한
	    for (var i = pageDto.startPage; i <= maxPage; i++) {
	        if (i === pageDto.currentPage) {
	            ul.append(
	                '<li class="page-item active">' +
	                    '<span class="page-link" aria-current="page">' + i + '</span>' +
	                '</li>'
	            );
	        } else {
	            ul.append(
	                '<li class="page-item">' +
	                    '<a class="page-link" href="javascript:void(0);" onclick="goPage(' + i + ')">' + i + '</a>' +
	                '</li>'
	            );
	        }
	    }
	
	    // 다음 블럭
	    if (pageDto.hasNext) {
	        var nextPage = Math.min(pageDto.endPage + 1, pageDto.lastPage); // lastPage 제한
	        ul.append(
	            '<li class="page-item">' +
	                '<a class="page-link" href="javascript:void(0);" onclick="goPage(' + nextPage + ')">&gt;</a>' +
	            '</li>'
	        );
	    }
	
	    container.append(ul);
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
	$(document).ready(function () {
  var ctx = '${pageContext.request.contextPath}';

  // URL에서 boardId 추출 (컨텍스트 제거)
  var path = location.pathname;
  if (ctx && path.indexOf(ctx) === 0) path = path.slice(ctx.length);
  var m = path.match(/^\/board\/([^/]+)/);
  var idFromUrl = m ? m[1] : null;

  if (!idFromUrl) return;

  // 현재 보드 설정
  currentBoardId = idFromUrl;

  // 페이지 상단 제목만 세팅 (사이드바는 header.jsp가 이미 렌더링함)
  var $navA = $('#board-menu-list a[href="' + ctx + '/board/' + currentBoardId + '"]');
  if ($navA.length) {
    $('#boardTitle').text($navA.text());
  } else {
    // 혹시 사이드바 렌더보다 먼저 실행될 수 있으니 백업 플로우
    $.getJSON(ctx + '/board/menu', function (list) {
      var found = list.find(function (x) { return String(x.boardId) === String(currentBoardId); });
      if (found) $('#boardTitle').text(found.boardTitle);
    });
  }

  // 글쓰기 버튼 권한 처리
  if (String(currentBoardId) === '1' && '${loginUser.role}' !== 'admin') {
    $('#insertPostModal').hide();
  } else {
    $('#insertPostModal').show();
  }

  // 글 목록 로드
  loadPosts();
});


    // 모달 열기
    $('#insertPostModal').on('click', function(e) {
        e.preventDefault(); 
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
                $('#postForm')[0].reset();
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
