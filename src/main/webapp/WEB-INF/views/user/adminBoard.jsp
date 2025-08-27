<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
					<tr>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
						<td></td>
					</tr>
				</tbody>
			</table>
           
           
           <!-- 페이징 -->
           	<div>
           		<div>
           		
           		</div>
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