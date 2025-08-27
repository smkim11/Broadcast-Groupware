<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시판</title>
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
                               <li class="breadcrumb-item">게시판</li>
                           </ol>
                       </div>
                   </div>
               </div>
           </div>
           
           <h1>게시판 목록</h1>
           
			<table border="1">
				<tr>
					<th>번호</th>
					<th>제목</th>
					<th>작성자</th>
					<th>작성시간</th>
				</tr>
			</table>
           
           
           
           
           
          </div>
	</div>
</div>

</body>
</html>