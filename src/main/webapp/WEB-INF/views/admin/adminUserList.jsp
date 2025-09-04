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
              <div class="table-responsive mb-4">
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
                      <th scope="col" style="width: 200px;">Action</th>
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
                            <li class="list-inline-item dropdown">
                              <a class="text-muted dropdown-toggle font-size-18 px-2" href="#" role="button" data-bs-toggle="dropdown" aria-haspopup="true">
                                <i class="uil uil-ellipsis-v"></i>
                              </a>
                              <div class="dropdown-menu dropdown-menu-end">
                                <a class="dropdown-item" href="${ctx}/user/detail/${r.userId}">View</a>
                                <a class="dropdown-item" href="${ctx}/user/edit/${r.userId}">Edit</a>
                              </div>
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

              <!-- 하단 페이징/카운트 -->
              <div class="row mt-4">
                <div class="col-sm-6">
                  <div>
                    <c:set var="startIndex" value="${(page.currentPage - 1) * page.rowPerPage + 1}" />
                    <c:set var="endIndex"   value="${page.currentPage * page.rowPerPage}" />
                    <c:if test="${totalRows == 0}">
                      <c:set var="startIndex" value="0"/>
                      <c:set var="endIndex"   value="0"/>
                    </c:if>
                    <c:if test="${endIndex > totalRows}">
                      <c:set var="endIndex" value="${totalRows}" />
                    </c:if>
                  </div>
                </div>

                <div class="col-sm-6">
                  <div class="float-sm-end">
                    <c:set var="startPage" value="${page.currentPage - 2}" />
                    <c:if test="${startPage < 1}">
                      <c:set var="startPage" value="1" />
                    </c:if>
                    <c:set var="endPage" value="${page.currentPage + 2}" />
                    <c:if test="${endPage > lastPage}">
                      <c:set var="endPage" value="${lastPage}" />
                    </c:if>

                    <ul class="pagination mb-sm-0">
                      <li class="page-item ${page.currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${ctx}/admin/adminUserList?page=${page.currentPage - 1}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}">
                          <i class="mdi mdi-chevron-left"></i>
                        </a>
                      </li>

                      <c:forEach var="p" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${p == page.currentPage ? 'active' : ''}">
                          <a class="page-link"
                             href="${ctx}/admin/adminUserList?page=${p}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}">${p}</a>
                        </li>
                      </c:forEach>

                      <li class="page-item ${page.currentPage == lastPage ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${ctx}/admin/adminUserList?page=${page.currentPage + 1}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}">
                          <i class="mdi mdi-chevron-right"></i>
                        </a>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
              <!-- 검색 -->
              <div class="row mb-2">
                <div class="col-md-6">
                  <form class="form-inline float-md-end mb-3" method="get" action="${ctx}/admin/adminUserList">
                    <input type="hidden" name="size" value="${page.rowPerPage}" />
                    <div class="search-box ms-2">
                      <div class="position-relative">
                        <input type="text"
                               name="q"
                               value="${fn:escapeXml(q)}"
                               class="form-control rounded bg-light border-0"
                               placeholder="이름 / 이메일 검색" />
                        <i class="mdi mdi-magnify search-icon"></i>
                      </div>
                    </div>
                  </form>
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
