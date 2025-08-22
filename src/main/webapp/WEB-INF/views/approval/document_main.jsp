<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Document Main</title>
</head>
<body>
<div>
	<jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- 페이지 타이틀 영역 (제목 + 경로 표시) -->
            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">문서 유형 선택</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item"><a href="javascript:void(0);">전자결재</a></li>
                                <li class="breadcrumb-item active">문서 작성</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 카드 3개 -->
            <div class="row g-3">
                <!-- 일반 문서 -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/approval/common/new" class="text-reset text-decoration-none">
                        <div class="card shadow-sm type-card h-100">
                            <div class="card-body d-flex flex-column align-items-center justify-content-center text-center">
                                <div class="avatar-md mb-3">
                                    <span class="avatar-title rounded-circle bg-success">
                                        <i class="uil-file-alt font-size-24 text-white"></i>
                                    </span>
                                </div>
                                <h5 class="mb-2">일반 문서</h5>
                                <p class="text-muted mb-0">보고서, 일반 품의 결재 문서</p>
                            </div>
                        </div>
                    </a>
                </div>

                <!-- 방송 문서 -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/approval/broadcast/new" class="text-reset text-decoration-none">
                        <div class="card shadow-sm type-card h-100">
                            <div class="card-body d-flex flex-column align-items-center justify-content-center text-center">
                                <div class="avatar-md mb-3">
                                    <span class="avatar-title rounded-circle bg-info">
                                        <i class="uil-video font-size-24 text-white"></i>
                                    </span>
                                </div>
                                <h5 class="mb-2">방송 문서</h5>
                                <p class="text-muted mb-0">편성/제작 관련 결재 문서</p>
                            </div>
                        </div>
                    </a>
                </div>

                <!-- 휴가 문서 -->
                <div class="col-md-4">
                    <a href="${pageContext.request.contextPath}/approval/vacation/new" class="text-reset text-decoration-none">
                        <div class="card shadow-sm type-card h-100">
                            <div class="card-body d-flex flex-column align-items-center justify-content-center text-center">
                                <div class="avatar-md mb-3">
                                    <span class="avatar-title rounded-circle bg-warning">
                                        <i class="uil-schedule font-size-24 text-white"></i>
                                    </span>
                                </div>
                                <h5 class="mb-2">휴가 문서</h5>
                                <p class="text-muted mb-0">연차/반차 결재 문서</p>
                            </div>
                        </div>
                    </a>
                </div>
            </div>
            
        </div>
    </div>
</div>

<div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
</div>
</body>
<div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
</div>
</html>