<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
</head>
<body>

<div>
  <jsp:include page ="../nav/header.jsp"></jsp:include>
</div>

<div class="main-content">
  <div class="page-content">
    <div class="container-fluid">

      <!-- start page title -->
      <div class="row">
        <div class="col-12">
          <div class="page-title-box d-flex align-items-center justify-content-between">
            <h4 class="mb-0">직원 리스트</h4>

            <div class="page-title-right">
              <ol class="breadcrumb m-0">
                <li class="breadcrumb-item"><a href="javascript:void(0);">조직도</a></li>
                <li class="breadcrumb-item active">직원 리스트</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
      <!-- end page title -->
              <!-- 목록 테이블 -->
              <div class="table-responsive mb-0">
                <table class="table table-centered table-nowrap mb-0">
                  <thead>
                    <tr>
                      <th scope="col" style="width: 50px;">
                        <div class="form-check font-size-16">
                          <input type="checkbox" class="form-check-input" id="contacusercheck">
                          <label class="form-check-label" for="contacusercheck"></label>
                        </div>
                      </th>
                      <th scope="col">사원번호</th>
                      <th scope="col">이름</th>
                      <th scope="col">직급</th>
                      <th scope="col">부서</th>
                      <th scope="col">팀</th>
                      <th scope="col">Email</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="r" items="${rows}">
                      <tr>
                        <th scope="row">
                          <div class="form-check font-size-16">
                            <input type="checkbox" class="form-check-input" id="check_${r.userId}">
                            <label class="form-check-label" for="check_${r.userId}"></label>
                          </div>
                        </th>
						<td><c:out value="${r.username}"/></td>
                        <td>
						 <c:choose>
						    <c:when test="${not empty r.profileImage}">
						      <img
						        src="${r.profileImage}"
						        alt=""
						        class="avatar-xs rounded-circle me-2"
						        onerror="this.onerror=null;this.src='${ctx}/resources/images/users/avatar-default.png'">
						    </c:when>
						    <c:otherwise>
						      <img
						        src="${ctx}/resources/images/users/avatar-default.png"
						        alt=""
						        class="avatar-xs rounded-circle me-2">
						    </c:otherwise>
						  </c:choose>
						
						  <a href="${ctx}/user/detail/${r.userId}" class="text-body">
						    <c:out value="${r.fullName}"/>
						  </a>
                         <small class="text-muted">(<c:out value="${r.gender}"/>)</small>
                        </td>

                        <td>
                         <c:out value="${r.userRank}"/>
                        </td>
                        
                        <td>
                            <c:out value="${r.departmentName}"/>
                            <c:if test="${not empty r.departmentName}">
                            </c:if>
                        </td>
                        <td><c:out value="${r.teamName}"/></td>
                        <td><c:out value="${r.email}"/></td>

                      </tr>
                    </c:forEach>

                    <c:if test="${empty rows}">
                      <tr>
                        <td colspan="5" class="text-center text-muted py-4">데이터가 없습니다.</td>
                      </tr>
                    </c:if>
                  </tbody>
                </table>
              </div>
              
                   <!-- 검색 (가운데) -->
				<div class="row mb-0">
				  <div class="col-12">
				    <form class="searchbar-wrap" method="get" action="${ctx}/user/userList">
				      <input type="hidden" name="size" value="${page.rowPerPage}" />
				      <select name="field" class="form-select">
				        <option value="all"  ${empty param.field || param.field == 'all'  ? 'selected' : ''}>전체</option>
					      <option value="name" ${param.field == 'name' ? 'selected' : ''}>이름</option>
					      <option value="dept" ${param.field == 'dept' ? 'selected' : ''}>부서</option>
					      <option value="team" ${param.field == 'team' ? 'selected' : ''}>팀</option>
					      <option value="rank" ${param.field == 'rank' ? 'selected' : ''}>직급</option>
					    </select>
					    
					     <c:set var="ph">
					      <c:choose>
					        <c:when test="${param.field == 'name'}">이름 검색</c:when>
					        <c:when test="${param.field == 'dept'}">부서 검색</c:when>
					        <c:when test="${param.field == 'team'}">팀 검색</c:when>
					        <c:when test="${param.field == 'rank'}">직급 검색</c:when>
					        <c:otherwise>이름/부서/팀/직급 검색</c:otherwise>
					      </c:choose>
					    </c:set>
					    
				        <div class="search-box ms-2">
					      <div class="position-relative">
					        <input type="text"
					               name="q"
					               value="${fn:escapeXml(q)}"
					               class="form-control rounded bg-light border-0"
					               placeholder="${ph}" />
					        <i class="mdi mdi-magnify search-icon"></i>
					      </div>
					    </div>
				      <button type="submit" class="btn btn-primary">검색</button>
				    </form>
				  </div>
				</div>
              

				<div class="row mt-0">
				  <div class="d-flex justify-content-center mt-0" id="pagination">
				
				    <!-- 현재/마지막 페이지 보정 -->
				    <c:set var="cp" value="${page.currentPage lt 1 ? 1 : page.currentPage}" />
				    <c:set var="lp" value="${lastPage lt 1 ? 1 : lastPage}" />
				
				    <!-- ===== 5개 고정 블록: 1~5 / 6~10 / 11~15 ... ===== -->
				    <c:set var="bs"  value="5" />
				    <c:set var="cp0" value="${cp - 1}" />
				    <!-- blockStart = (cp-1) - ((cp-1) % bs) + 1  (정수 블록 시작) -->
				    <c:set var="rem" value="${cp0 mod bs}" />
				    <c:set var="blockStart" value="${cp0 - rem + 1}" />
				    <c:set var="blockEnd"   value="${blockStart + bs - 1}" />
				    <c:if test="${blockEnd > lp}">
				      <c:set var="blockEnd" value="${lp}" />
				    </c:if>
				
				    <!-- 이전/다음 페이지 -->
				    <c:set var="prevPage" value="${cp - 1 < 1 ? 1 : cp - 1}" />
				    <c:set var="nextPage" value="${cp + 1 > lp ? lp : cp + 1}" />
				
				    <ul class="pagination mb-0">
				      <!-- 처음(<<) -->
				      <li class="page-item ${cp == 1 ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/user/userList?page=1&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&laquo;</a>
				      </li>
				
				      <!-- 이전(<) -->
				      <li class="page-item ${cp == 1 ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/user/userList?page=${prevPage}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&lsaquo;</a>
				      </li>
				
				      <!-- 현재 블록의 ‘실제’ 페이지만 렌더링 (빈칸 없음) -->
				      <c:forEach var="p" begin="${blockStart}" end="${blockEnd}">
				        <li class="page-item ${p == cp ? 'active' : ''}">
				          <a class="page-link"
				             href="${ctx}/user/userList?page=${p}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">${p}</a>
				        </li>
				      </c:forEach>
				
				      <!-- 다음(>) -->
				      <li class="page-item ${cp == lp ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/user/userList?page=${nextPage}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&rsaquo;</a>
				      </li>
				
				      <!-- 끝(>>) -->
				      <li class="page-item ${cp == lp ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/user/userList?page=${lp}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&raquo;</a>
				      </li>
				    </ul>
				  </div>
				</div>



              <!-- end row -->
              
            </div><!-- card-body -->
          </div><!-- card -->
        </div>
      </div>

    </div><!-- container-fluid -->
  </div><!-- page-content -->
  
  <div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
  </div>
  <div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
  </div>
</div><!-- main-content -->

</body>
</html>
