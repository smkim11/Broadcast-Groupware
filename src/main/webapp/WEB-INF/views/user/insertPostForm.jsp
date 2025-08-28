<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시글 작성하기</title>
</head>
<body>
	<form action="/insertPost" method="post">
		<div>제목</div>
		<div>
			<input type="text" id="postTitle" class="postTitle" name="postTitle" placeholder="제목을 입력하세요.">
		</div>
		<div>내용</div>
		<div>
			<textarea rows="10" cols="50" class="postContent" name="postContent"></textarea>
		</div>
		<div>
			파일업로드: <input type="file" class="file" name="file">
		</div>

		<a href="" class="btn btn-outline-secondary waves-effect">취소</a>
		<a href="" class="btn btn-outline-primary waves-effect waves-light">등록</a>
	</form>
</body>
</html>