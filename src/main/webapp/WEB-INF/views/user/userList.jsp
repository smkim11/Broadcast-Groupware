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
<c:set var="ctx" value="${pageContext.request.contextPath}" />

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
            <h4 class="mb-0">사원 리스트</h4>

            <div class="page-title-right">
              <ol class="breadcrumb m-0">
                <li class="breadcrumb-item"><a href="javascript:void(0);">조직도</a></li>
                <li class="breadcrumb-item active">사원 리스트</li>
              </ol>
            </div>
          </div>
        </div>
      </div>
      <!-- end page title -->

      <div class="row">
        <div class="col-lg-12">
          <div class="card">
            <div class="card-body">

              <!-- 상단 좌: 버튼, 우: 검색 -->
              <div class="row mb-2">
                <div class="col-md-6">
                  <div class="mb-3">
                    <a href="javascript:void(0);" class="btn btn-success waves-effect waves-light">
                      <i class="mdi mdi-plus me-2"></i> Add New
                    </a>
                  </div>
                </div>

                <div class="col-md-6">
                  <form class="form-inline float-md-end mb-3" method="get" action="${ctx}/user/userList">
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
                      <th scope="col">Name</th>
                      <th scope="col">Position</th>
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

                        <td>
                          <img
                            src="<c:out value='${empty r.profileImage ? ctx += "/resources/images/users/default-avatar.png" : r.profileImage}'/>"
                            alt=""
                            class="avatar-xs rounded-circle me-2">
                          <a href="${ctx}/user/detail/${r.userId}" class="text-body">
                            <c:out value="${r.fullName}"/>
                          </a>
                         (<c:out value="${r.userRank}"/>)
                        </td>

                        <td>
                         <div class="text-muted small">
                            <c:out value="${r.departmentName}"/>
                            <c:if test="${not empty r.departmentName}">
                              /<c:out value="${r.teamName}"/>
                            </c:if>
                          </div>
                        </td>
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

                    <p class="mb-sm-0">
                      Showing <strong>${startIndex}</strong> to <strong>${endIndex}</strong> of
                      <strong>${totalRows}</strong> entries
                    </p>
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
                           href="${ctx}/user/userList?page=${page.currentPage - 1}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}">
                          <i class="mdi mdi-chevron-left"></i>
                        </a>
                      </li>

                      <c:forEach var="p" begin="${startPage}" end="${endPage}">
                        <li class="page-item ${p == page.currentPage ? 'active' : ''}">
                          <a class="page-link"
                             href="${ctx}/user/userList?page=${p}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}">${p}</a>
                        </li>
                      </c:forEach>

                      <li class="page-item ${page.currentPage == lastPage ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${ctx}/user/userList?page=${page.currentPage + 1}&size=${page.rowPerPage}&q=${fn:escapeXml(q)}">
                          <i class="mdi mdi-chevron-right"></i>
                        </a>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

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

<script src="${ctx}/resources/libs/sweetalert2/sweetalert2.min.js"></script>
</body>
</html>
