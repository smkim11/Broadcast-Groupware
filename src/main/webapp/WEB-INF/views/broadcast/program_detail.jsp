<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Program Detail</title>
</head>
<body>
<div>
    <jsp:include page="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
    <div class="page-content">
        <div class="container-fluid">

            <!-- 페이지 타이틀 -->
            <div class="row">
                <div class="col-12">
                    <div class="page-title-box d-flex align-items-center justify-content-between">
                        <h4 class="mb-0">방송편성 상세</h4>
                        <div class="page-title-right">
                            <ol class="breadcrumb m-0">
                                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/broadcast/list">방송편성</a></li>
                                <li class="breadcrumb-item active">상세</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 상세 카드 -->
            <div class="card">
			    <div class="card-body">
			
			        <!-- 상단 제목 -->
			        <div class="d-flex justify-content-between align-items-start mb-3">
			            <div>
			                <h5 class="mb-1">
			                    <c:out value="${program.broadcastFormName}"/> 상세 정보
			                </h5>
			            </div>
			        </div>
			
			        <!-- 상세 표 -->
			        <div class="table-responsive">
			            <table class="table table-bordered align-middle mb-0">
			                <colgroup>
			                    <col style="width:22%;">
			                    <col>
			                </colgroup>
			                <tbody>
			                    <tr>
			                        <th class="bg-light text-center">프로그램명</th>
			                        <td>
			                            <c:out value="${program.broadcastFormName}"/>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">방영 기간</th>
			                        <td>
			                            <c:out value="${fn:substring(program.broadcastFormStartDate,0,10)}"/> ~
			                            <c:out value="${fn:substring(program.broadcastFormEndDate,0,10)}"/>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">방영 요일</th>
			                        <td>
			                            <c:out value="${empty program.broadcastDaysText ? '-' : program.broadcastDaysText}"/>
			                        </td>
			                    </tr>
			                    <tr>
			                        <th class="bg-light text-center">회차</th>
			                        <td class="d-flex justify-content-between align-items-center">
			                            <span>
			                                <c:out value="${empty program.episodesCount ? '-' : program.episodesCount}"/>
			                            </span>
			                            <a href="${pageContext.request.contextPath}/broadcast/episodes?formId=${program.broadcastFormId}">
			                                회차 상세 보기
			                            </a>
			                        </td>
			                    </tr>
			                    <tr>
								    <th class="bg-light text-center">대표자</th>
								    <td class="d-flex align-items-center justify-content-between">
								        <span>
								            <c:out value="${empty program.fullName ? '-' : program.fullName}"/>
								            <span class="text-muted ms-2">(담당 인원: <c:out value="${program.broadcastFormCapacity}"/>명)</span>
								        </span>
								
										<!-- 팀원 보기 토글 -->
								        <a href="#teamCollapse" class="link-primary"
								           role="button" data-bs-toggle="collapse"
								           aria-expanded="false" aria-controls="teamCollapse">
								           팀원 보기
								        </a>
								    </td>
								</tr>
								
								<!-- 팀원 -->
								<tr>
								    <th class="bg-light text-center">팀원</th>
								    <td class="p-0">
								        <div id="teamCollapse" class="collapse"
								             data-schedule-id="${program.broadcastScheduleId}">
								             <!-- 헤더 액션 라인 -->
								            <div class="d-flex justify-content-between align-items-center px-2 py-2 border-bottom">
								                <div class="small text-muted">
								                    <span id="teamCountText">총 0명</span>
								                </div>
								                <div>
								                    <!-- 대표자만 추가 버튼 노출 -->
								                    <c:if test="${not empty sessionScope.loginUserId and sessionScope.loginUserId == program.userId}">
								                        <button type="button" class="btn btn-sm btn-outline-primary"
								                                data-bs-toggle="modal" data-bs-target="#teamAddModal">
								                            추가
								                        </button>
								                    </c:if>
								                </div>
								            </div>
								            
								            <!-- 팀원 목록 테이블 -->
							                <div class="table-responsive">
							                    <table class="table table-hover align-middle mb-0">
							                        <thead>
							                            <tr class="text-center">
							                                <th style="width:60px;">번호</th>
							                                <th style="width:20%;">팀원 명</th>
							                                <th style="width:22%;">소속 부서</th>
							                                <th style="width:22%;">소속 팀</th>
							                                <th style="width:16%;">직급</th>
							                            </tr>
							                        </thead>
							                        <tbody id="teamBody">
							                            <tr>
							                                <td colspan="6" class="text-center text-muted">팀원 보기를 눌러주세요</td>
							                            </tr>
							                        </tbody>
							                    </table>
						                	</div>
								
								            <!-- 하단 액션/페이징 -->
							                <div class="d-flex justify-content-between align-items-center px-2 py-2 border-top">
							                    <a href="${pageContext.request.contextPath}/broadcast/list" class="btn btn-sm btn-outline-secondary">목록</a>
							
							                    <ul id="teamPaging" class="pagination pagination-sm mb-0"></ul>
							
							                    <c:if test="${not empty sessionScope.loginUserId and sessionScope.loginUserId == program.userId}">
							                        <button id="btnTeamDelete" class="btn btn-sm btn-outline-danger" disabled>삭제</button>
							                    </c:if>
							                </div>
							            </div>
								    </td>
								</tr>
								
			                </tbody>
			            </table>
			            
			            <!-- 팀원 추가 모달 -->
						<div class="modal fade" id="teamAddModal" tabindex="-1" aria-hidden="true">
						    <div class="modal-dialog modal-md">
						        <div class="modal-content">
						            <div class="modal-header">
						                <h5 class="modal-title">팀원 추가</h5>
						                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
						            </div>
						            <div class="modal-body">
						                <form id="teamAddForm">
						                    <input type="hidden" name="formId" value="${program.broadcastFormId}"/>
						
						                    <div class="mb-2">
						                        <label class="form-label small">소속 부서</label>
						                        <select class="form-select" id="deptSelect"></select>
						                    </div>
						
						                    <div class="mb-2">
						                        <label class="form-label small">소속 팀</label>
						                        <select class="form-select" id="teamSelect"></select>
						                    </div>
						
						                    <div class="mb-2">
						                        <label class="form-label small">팀원 명</label>
						                        <select class="form-select" id="userSelect"></select>
						                    </div>
						
						                    <div class="mb-2">
						                        <label class="form-label small">직급</label>
						                        <input type="text" class="form-control" id="rankInput" placeholder="(선택)"/>
						                    </div>
						                </form>
						                <div class="small text-muted">부서/팀 선택 후 팀원 명을 선택하세요.</div>
						            </div>
						            <div class="modal-footer">
						                <button class="btn btn-outline-primary" id="btnTeamSave">저장</button>
						                <button class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
						            </div>
						        </div>
						    </div>
						</div>
						
			        </div>
			
			    </div>
			</div>
	        
        </div>
    </div>
</div>

<div>
    <jsp:include page="../nav/footer.jsp"></jsp:include>
</div>

<div>
    <jsp:include page="../nav/javascript.jsp"></jsp:include>
</div>

</body>
</html>