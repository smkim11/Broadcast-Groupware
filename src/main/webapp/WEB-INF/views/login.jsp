<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta charset="UTF-8">
<title>login page</title>
</head>
<body>
	<h2>Login</h2>
	<div>
        <label for="username">아이디</label>
        <input type="text" id="username" name="username" required/>
    </div>
    <div>
        <label for="password">비밀번호</label>
        <input type="password" id="password" name="password" required/>
    </div>
    <div>
        <button type="submit">로그인</button>
    </div>
</body>
</html>