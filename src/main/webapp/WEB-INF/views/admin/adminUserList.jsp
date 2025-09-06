<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
  <link href="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.css" rel="stylesheet" type="text/css" />
</head>
  <style>
/* 템플릿에서 제공하는 에러메세지만 사용  */
.was-validated .form-control:valid,
.form-control.is-valid {
  border-color: #dee2e6 !important;
  background-image: none !important;
  box-shadow: none !important;
}
</style>
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
            <h4 class="mb-0">직원 관리</h4>

            <div class="page-title-right">
              <ol class="breadcrumb m-0">
                <li class="breadcrumb-item"><a href="javascript:void(0);">조직도</a></li>
                <li class="breadcrumb-item active">직원 관리</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
      <!-- end page title -->

      <div class="row">
        <div class="col-lg-12">
       <div class="mb-1 text-end">
		  <a href="javascript:void(0);" 
		     class="btn btn-outline-primary btn-sm waves-effect"
		     data-bs-toggle="modal" data-bs-target="#userCreateModal">
		     <i class="mdi mdi-plus me-1"></i>직원 등록
		  </a>
		</div>
          <div class="card">
            <div class="card-body">


              <!-- 목록 테이블 -->
              <div class="table-responsive mb-0">
                <table class="table table-centered table-nowrap mb-0">
                  <thead>
                    <tr>
                      <th scope="col">사원번호</th>
                      <th scope="col">이름</th>
                      <th scope="col">직급</th>
                      <th scope="col">부서</th>
                      <th scope="col">팀</th>
                      <th scope="col">Email</th>
                      <th scope="col">입사일</th>
                      <th scope="col" style="width: 200px;">Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="r" items="${rows}">
                      <tr>
						<td><c:out value="${r.username}"/></td>
                        <td>
                          <img
                            src="<c:out value='${empty r.profileImage ? ctx += "/resources/images/users/default-avatar.png" : r.profileImage}'/>"
                            alt=""
                            class="avatar-xs rounded-circle me-2">
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
                        <td><c:out value="${r.userJoinDate}"/></td>

                        <td>
                          <ul class="list-inline mb-0">
                            <li class="list-inline-item">
                              <a href="${ctx}/user/edit/${r.userId}" class="px-2 text-primary">
                                <i class="uil uil-pen font-size-18"></i>
                              </a>
                            </li>
                            <li class="list-inline-item">
                              <a href="javascript:void(0);" class="px-2 text-danger" data-user-id="${r.userId}">
                                <i class="uil uil-trash-alt font-size-18"></i>
                              </a>
                            </li>
                          </ul>
                        </td>
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
				    <form class="searchbar-wrap" method="get" action="${ctx}/admin/adminUserList">
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
				  <div class="col-12 d-flex justify-content-center">
				
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
				           href="${ctx}/admin/adminUserList?page=1&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&laquo;</a>
				      </li>
				
				      <!-- 이전(<) -->
				      <li class="page-item ${cp == 1 ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/admin/adminUserList?page=${prevPage}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&lsaquo;</a>
				      </li>
				
				      <!-- 현재 블록의 ‘실제’ 페이지만 렌더링 (빈칸 없음) -->
				      <c:forEach var="p" begin="${blockStart}" end="${blockEnd}">
				        <li class="page-item ${p == cp ? 'active' : ''}">
				          <a class="page-link"
				             href="${ctx}/admin/adminUserList?page=${p}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">${p}</a>
				        </li>
				      </c:forEach>
				
				      <!-- 다음(>) -->
				      <li class="page-item ${cp == lp ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/admin/adminUserList?page=${nextPage}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&rsaquo;</a>
				      </li>
				
				      <!-- 끝(>>) -->
				      <li class="page-item ${cp == lp ? 'disabled' : ''}">
				        <a class="page-link"
				           href="${ctx}/admin/adminUserList?page=${lp}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}&field=${param.field}">&raquo;</a>
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
  
<!-- ===== 직원 생성 모달 ===== -->
<div class="modal fade" id="userCreateModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">직원 등록</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
      </div>

      <div class="modal-body">
        <div class="row g-3">
          <!-- 부서 -->
          <div class="col-md-6">
            <label class="form-label">부서</label>
            <select id="deptSelect" class="form-select">
              <option value="">부서를 선택하세요</option>
            </select>
            <div class="invalid-feedback" id="err-dept"></div>
          </div>

          <!-- 팀 -->
          <div class="col-md-6">
            <label class="form-label">팀</label>
            <select id="teamSelect" class="form-select" disabled>
              <option value="">팀을 선택하세요</option>
            </select>
            <div class="invalid-feedback" id="err-team"></div>
          </div>

          <!-- 권한 -->
          <div class="col-md-6">
            <label class="form-label">권한(role)</label>
            <select id="role" class="form-select">
              <option value="USER">USER</option>
              <option value="ADMIN">ADMIN</option>
            </select>
            <div class="invalid-feedback" id="err-role"></div>
          </div>
          <!-- 직급 -->
          <div class="col-md-6">
            <label class="form-label">직급</label>
            <select id="userRank" class="form-select">
            </select>
            <div class="invalid-feedback" id="err-rank"></div>
          </div>
          
          <!-- 이름 -->
          <div class="col-md-6">
            <label class="form-label">이름</label>
            <input id="fullName" class="form-control" type="text" placeholder="홍길동">
            <div class="invalid-feedback" id="err-name"></div>
          </div>

          <!-- 주민번호 앞/뒤 -->
          <div class="col-md-3">
            <label class="form-label">주민 앞자리(6자리)</label>
            <input id="userSn1" class="form-control"
                   type="text" inputmode="numeric" pattern="\d*"
                   maxlength="6" placeholder="예: 900101">
            <div class="invalid-feedback" id="err-sn1"></div>
          </div>
          <div class="col-md-3">
            <label class="form-label">주민 뒷자리(7자리)</label>
            <input id="userSn2" class="form-control"
                   type="text" inputmode="numeric" pattern="\d*"
                   maxlength="7" placeholder="예: 1xxxxxx">
            <div class="invalid-feedback" id="err-sn2"></div>
          </div>
       

          <!-- 연락처 -->
          <div class="col-md-6">
            <label class="form-label">연락처</label>
            <input id="userPhone" class="form-control" type="text" placeholder="01012345678">
            <div class="invalid-feedback" id="err-phone"></div>
          </div>
          
          <!-- 이메일 -->
          <div class="col-md-6">
            <label class="form-label">이메일</label>
            <input id="userEmail" class="form-control" type="email" placeholder="user@example.com">
            <div class="invalid-feedback" id="err-email"></div>
          </div>


       <!-- 입사일(왼쪽) + 안내문구(오른쪽) : 칸 너비는 그대로 col-md-6 / col-md-6 -->
		<div class="col-md-6">
		  <label class="form-label">입사일</label>
		  <input id="userJoinDate" class="form-control" type="date" readonly>
		  <!-- (유효성 메시지 위치 유지) -->
		  <div id="err-join" class="invalid-feedback"></div>
		</div>
		
		<!-- 오른쪽 빈칸에 안내 문구만 배치 -->
		<div class="col-md-6">
		  <!-- 라벨 라인 높이를 맞추기 위해 보이지 않는 레이블 한 줄 -->
		  <label class="form-label d-none d-md-block">&nbsp;</label>
		  <!-- 실제 안내 문구 -->
		  <div class="small text-danger pt-2">
		    ※ 초기비밀번호는 생년월일입니다.
		  </div>
		</div>
		
		 </div>

        <!-- 서버/기타 메시지 -->
        <div id="createResult" class="mt-3 small" style="display:none;"></div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">닫기</button>
        <button type="button" class="btn btn-outline-success" id="btnCreateUser">등록</button>
      </div>
    </div>
  </div>
</div>
<!-- ===== /직원 생성 모달 ===== -->
<script>
document.addEventListener('DOMContentLoaded', function () {
  const form = document.querySelector('.searchbar-wrap');
  if (!form) return;

  const field = form.querySelector('select[name="field"]');
  const q     = form.querySelector('input[name="q"]');

  // 선택값에 맞춰 placeholder도 같이 바꿔주기(옵션)
  const placeholders = {
    all : '이름/부서/팀/직급 검색',
    name: '이름 검색',
    dept: '부서 검색',
    team: '팀 검색',
    rank: '직급 검색'
  };

  if (field && q) {
    // 최초 로드 시 placeholder 안전 세팅
    q.placeholder = placeholders[field.value] || q.placeholder;

    field.addEventListener('change', function () {
      q.value = '';                               // 검색어 초기화
      q.placeholder = placeholders[this.value] || '검색어';
      q.focus();
    });
  }
});
</script>
  <div>
    <jsp:include page ="../nav/footer.jsp"></jsp:include>
  </div>
  <div>
    <jsp:include page ="../nav/javascript.jsp"></jsp:include>
  </div>
</div><!-- main-content -->

<!-- Sweet Alerts js -->
<script src="${pageContext.request.contextPath}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/js/pages/user-create.init.js"></script>
</body>
</html>
