<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    <meta charset="UTF-8">
         <title>Broadcast Login</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta content="Premium Multipurpose Admin & Dashboard Template" name="description" />
        <meta content="Themesbrand" name="author" />
        <!-- App favicon -->
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/resources/images/favicon.ico">

        <!-- Bootstrap Css -->
        <link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" id="bootstrap-style" rel="stylesheet" type="text/css" />
        <!-- Icons Css -->
        <link href="${pageContext.request.contextPath}/resources/css/icons.min.css" rel="stylesheet" type="text/css" />
        <!-- App Css-->
        <link href="${pageContext.request.contextPath}/resources/css/app.min.css" id="app-style" rel="stylesheet" type="text/css" />
</head>

    <body class="authentication-bg">
        <div class="account-pages my-5 pt-sm-5">
            <div class="container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="text-center">
                            <a href="/login" class="mb-5 d-block auth-logo">
                                <img src="${pageContext.request.contextPath}/resources/images/logo-dark.png" alt="" height="22" class="logo logo-dark">
                                <img src="${pageContext.request.contextPath}/resources/images/logo-light.png" alt="" height="22" class="logo logo-light">
                            </a>
                        </div>
                    </div>
                </div>
                <div class="row align-items-center justify-content-center">
                    <div class="col-md-8 col-lg-6 col-xl-5">
                        <div class="card">
                           
                            <div class="card-body p-4"> 
                                <div class="text-center mt-2">
                                    <h5 class="text-primary">환영합니다.</h5>
                                    <p class="text-muted">로그인</p>
                                </div>
                                <div class="p-2 mt-4">
                                    <form action="/login" method="post">
        
                                        <div class="mb-3">
                                            <label class="form-label" for="username">사원번호</label>
                                            <input type="text" class="form-control" id="username" name="username" placeholder="사원번호 입력" required>
                                        </div>
                
                                        <div class="mb-3">
                                            <div class="float-end">
                                                <a href="" class="text-muted">비밀번호 찾기</a>
                                            </div>
                                            <label class="form-label" for="password">비밀번호</label>
                                            <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호 입력" required>
                                        </div>
                
                                        <div class="mt-3 text-end">
                                            <button class="btn btn-primary w-sm waves-effect waves-light" type="submit">로그인</button>
                                        </div>
            

                                        <div class="mt-4 text-center">
                                            <p class="mb-0">Don't have an account ? <a href="" class="fw-medium text-primary"> Signup now </a> </p>
                                        </div>
                                    </form>
                                </div>
            
                            </div>
                        </div>

                        <div class="mt-5 text-center">
                            <p>© <script>document.write(new Date().getFullYear())</script> Minible. Crafted with <i class="mdi mdi-heart text-danger"></i> by Themesbrand</p>
                        </div>

                    </div>
                </div>
                <!-- end row -->
            </div>
            <!-- end container -->
        </div>

<div>
    <jsp:include page ="../views/nav/javascript.jsp"></jsp:include>
</div>
</body>
</html>
