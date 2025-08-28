<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

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
                       <h4 class="mb-0">게시판</h4>
                       <div class="page-title-right">
                           <ol class="breadcrumb m-0">
                               <li class="breadcrumb-item">게시판 관리</li>
                           </ol>
                       </div>
                   </div>
               </div>
           </div>
           
           
			<table class="table table-striped">
				<tbody>
					<tr>
						<th>번호</th>
						<th>분류(활성화)</th>
						<th>상단고정</th>
						<th>제목</th>
						<th>작성자</th>
						<th>작성시간</th>
						<th>활성화</th>
					</tr>
					<c:forEach var="board" items="${boardList}">
						<tr>
							<td>${board.boardId}</td>
							<td>${board.boardTitle}(${board.boardStatus == 'Y' ? '활성화' : '비활성화'})</td>
							<td>${board.fixed == 'Y' ? '활성화' : '비활성화'}</td>
							<td>${board.title}</td>
							<td>${board.userName}</td>
							<td>${board.createDate}</td>
							<td>${board.postStatus == 'Y' ? '활성화' : '비활성화'}</td>
						</tr>
					</c:forEach>
				</tbody>
			</table>
           
           
<div class="pagination" style="display:flex; gap:8px;">

    <!-- 이전 블럭 -->
    <c:if test="${pageDto.hasPrev}">
        <a href="?currentPage=${pageDto.startPage - 1}&searchType=${param.searchType}&searchWord=${param.searchWord}">&lt;</a>
    </c:if>

    <!-- 현재 블럭 페이지 번호 -->
    <c:forEach begin="${pageDto.startPage}" end="${pageDto.endPage}" var="i">
        <c:choose>
            <c:when test="${i == pageDto.currentPage}">
                <span style="font-weight:bold; text-decoration:underline;">${i}</span>
            </c:when>
            <c:otherwise>
                <a href="?currentPage=${i}&searchType=${param.searchType}&searchWord=${param.searchWord}">${i}</a>
            </c:otherwise>
        </c:choose>
    </c:forEach>

    <!-- 다음 블럭 -->
    <c:if test="${pageDto.hasNext}">
        <a href="?currentPage=${pageDto.endPage + 1}&searchType=${param.searchType}&searchWord=${param.searchWord}">&gt;</a>
    </c:if>

</div>


           
           <!-- 검색 -->
           	<form action="/user/adminBoard" method="get" id="searchForm" class="searchForm">
           		<div id="search-main" class="search-main">
           			<select id="serchType" name="serchType">
           				<option value="분류">분류</option>
           				<option value="제목">제목</option>
           				<option value="작성자">작성자</option>
           			</select>
           			<input type="text" id="searchWord" name="searchWord" placeholder="검색어를 입력하세요">
           			<button type="submit">검색</button>
           		</div>       	
           	</form>
           
           
          </div>
	</div>
</div>

</body>
<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<!-- parsleyjs -->
<script src="${pageContext.request.contextPath}/resources/libs/parsleyjs/parsley.min.js"></script>
</html>