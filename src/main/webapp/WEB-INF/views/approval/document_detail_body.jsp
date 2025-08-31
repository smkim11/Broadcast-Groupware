<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>  <!-- 날짜 포맷 -->
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>		<!-- 문서번호 포맷 -->

<!-- 페이지 타이틀 영역 -->
<div class="row">
    <div class="col-12">
        <div class="page-title-box d-flex align-items-center justify-content-between">
            <h4 class="mb-0">문서 상세</h4>
            <div class="page-title-right">
                <ol class="breadcrumb m-0">
                    <li class="breadcrumb-item"><a href="javascript:void(0);">전자결재</a></li>
                    <li class="breadcrumb-item active">내 문서함</li>
                </ol>
            </div>
        </div>
    </div>
</div>

<!-- 상단: 결재란 (3칸 고정) -->
<div class="row align-items-center mb-2">
    <div class="col"></div>
    <div class="col-auto">
        <div class="d-flex gap-2 flex-wrap justify-content-end">

            <c:forEach var="al" items="${approvalLines}" varStatus="st">
                <c:if test="${st.index lt 3}">
                    <div class="card border-2" style="width:160px;">
                        <div class="card-header py-1 text-center bg-light">
                            <strong>결재 ${st.index + 1}차</strong>
                        </div>
                        <div class="card-body p-2 d-flex flex-column justify-content-center align-items-center text-center gap-2" style="min-height:110px;">
                            <div class="fw-semibold text-truncate" style="max-width:140px;">
                                <c:out value="${al.fullName}"/>
                                <c:if test="${not empty al.userRank}"> (<c:out value="${al.userRank}"/>)</c:if>
                            </div>
                            <div>
                                <c:choose>
									<c:when test="${al.approvalLineStatus eq '승인'}">
							            <span class="badge bg-success px-3 py-2">승인</span>
							            <c:if test="${not empty al.signatureUrl}">
							                <div class="mt-1">
							                    <img src="${al.signatureUrl}" style="height:26px;" alt="sign">
							                </div>
							            </c:if>
							        </c:when>
							        
							        <c:when test="${al.approvalLineStatus eq '반려'}">
							            <span class="badge bg-danger px-3 py-2">반려</span>
							        </c:when>
							
							        <c:otherwise>
							            <span class="badge bg-secondary px-3 py-2">대기</span>
							        </c:otherwise>
							    </c:choose>
                            </div>
                        </div>
                    </div>
                </c:if>
            </c:forEach>

            <!-- placeholder로 3칸 맞추기 -->
            <c:forEach begin="${fn:length(approvalLines)}" end="2" var="i">
                <div class="card border-2" style="width:160px;">
                    <div class="card-header py-1 text-center bg-light">
                        <strong>결재 ${i + 1}차</strong>
                    </div>
                    <div class="card-body p-2 d-flex flex-column justify-content-center align-items-center text-center gap-2" style="min-height:110px;">
                        <div class="text-muted">미지정</div>
                    </div>
                </div>
            </c:forEach>

        </div>
    </div>
</div>

            
<!-- 기본 문서 정보 -->
<div class="card">
    <div class="card-body p-0">
        <table class="table table-bordered mb-0 align-middle">
            <tbody>
            	<tr>
                    <th class="bg-light text-center">문서 번호</th>
                    <td>
						<fmt:formatNumber value="${document.approvalDocumentId}"
						                  type="number"
						                  minIntegerDigits="6"
						                  groupingUsed="false" />
					</td>
                    <th class="bg-light text-center">기안일</th>
                    <td>
					    <c:choose>
					        <c:when test="${not empty document.createDate}">
					            ${fn:substring(document.createDate, 0, 10)}
					        </c:when>
					        <c:otherwise>-</c:otherwise>
					    </c:choose>
					</td>
                </tr>
                <tr>
                    <th class="bg-light text-center">소속</th>
                    <td><c:out value="${document.departmentName}"/> / <c:out value="${document.teamName}"/></td>
                    <th class="bg-light text-center">기안자</th>
                    <td><c:out value="${document.fullName}"/> (<c:out value="${document.userRank}"/>)</td>
                </tr>
                <tr>
                    <th class="bg-light text-center">제목</th>
                    <td colspan="3"><c:out value="${document.approvalDocumentTitle}"/></td>
                </tr>
                
	            <!-- 타입별 폼 -->
                <c:choose>
                	<%-- 휴가 폼 --%>
                    <c:when test="${not empty vacationForm}">
					    <tr>
					        <th class="bg-light text-center">유형</th>
					        <td>
					            <c:out value="${vacationForm.vacationFormType}"/>
					            <c:if test="${vacationForm.vacationFormType eq '반차' and not empty vacationForm.vacationFormHalfType}">
					                (<c:out value="${vacationForm.vacationFormHalfType}"/>)
					            </c:if>
					        </td>
					        <th class="bg-light text-center">기간</th>
					        <td>
					            <c:out value="${vacationForm.vacationFormStartDate}"/> ~
					            <c:out value="${vacationForm.vacationFormEndDate}"/>
					        </td>
					    </tr>
					</c:when>
	            
	            	<%-- 방송 폼 --%>
                    <c:when test="${not empty broadcastForm}">
                        <tr>
                            <th class="bg-light text-center">프로그램명</th>
                            <td><c:out value="${broadcastForm.broadcastFormName}"/></td>
                        </tr>
                        <tr>
                        	<th class="bg-light text-center">방송 기간</th>
                            <td>
                                <c:out value="${broadcastForm.broadcastFormStartDate}"/> ~
                                <c:out value="${broadcastForm.broadcastFormEndDate}"/>
                            </td>
                            <th class="bg-light text-center">방송 시간</th>
                            <td>
                                <c:out value="${broadcastForm.broadcastFormStartTime}"/> ~
                                <c:out value="${broadcastForm.broadcastFormEndTime}"/>
                            </td>
                        </tr>
                        <tr>
                            <th class="bg-light text-center">방송 요일</th>
                            <td>
                                <c:if test="${broadcastForm.broadcastMonday == 1}">월 </c:if>
                                <c:if test="${broadcastForm.broadcastTuesday == 1}">화 </c:if>
                                <c:if test="${broadcastForm.broadcastWednesday == 1}">수 </c:if>
                                <c:if test="${broadcastForm.broadcastThursday == 1}">목 </c:if>
                                <c:if test="${broadcastForm.broadcastFriday == 1}">금 </c:if>
                                <c:if test="${broadcastForm.broadcastSaturday == 1}">토 </c:if>
                                <c:if test="${broadcastForm.broadcastSunday == 1}">일 </c:if>
                            </td>
                            <th class="bg-light text-center">담당 총 인원</th>
                            <td><c:out value="${broadcastForm.broadcastFormCapacity}"/>명</td>
                        </tr>
                    </c:when>
                </c:choose>
	            
                <tr>
                    <th class="bg-light text-center">내용</th>
                    <td colspan="3" style="white-space: pre-wrap;">
                        <c:out value="${document.approvalDocumentContent}"/>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

<!-- 결재선 / 참조선 -->
<div class="accordion mt-3" id="lineAccordion">
    <div class="accordion-item">
        <h2 class="accordion-header">
            <button class="accordion-button fw-semibold text-dark" type="button"
                    data-bs-toggle="collapse" data-bs-target="#collapseLines"
                    aria-expanded="true" aria-controls="collapseLines">
                결재선 / 참조선
            </button>
        </h2>
        <div id="collapseLines" class="accordion-collapse collapse show">
            <div class="accordion-body">
                <div class="row g-3">

                    <!-- 결재선 -->
                    <div class="col-6">
                        <div class="card h-100">
                            <div class="card-header bg-light py-2 d-flex justify-content-between">
                                <strong>결재선</strong>
                                <c:if test="${isEditable}">
                                    <a href="${pageContext.request.contextPath}/approval/line/input?docId=${document.approvalDocumentId}"
                                       class="btn btn-sm btn-outline-success">수정</a>
                                </c:if>
                            </div>
                            <div class="card-body p-2">
                                <table class="table table-sm table-bordered mb-0 text-center">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width:20px;" class="text-center">차수</th>
                                            <th style="width:50px;" class="text-center">결재자</th>
                                            <th style="width:30px;" class="text-center">소속</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="al" items="${approvalLines}">
                                            <tr>
                                                <td><c:out value="${al.approvalLineSequence}"/></td>
                                                <td><c:out value="${al.fullName}"/> (<c:out value="${al.userRank}"/>)</td>
                                                <td><c:out value="${document.departmentName}"/> / <c:out value="${document.teamName}"/></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- 참조선 -->
                    <div class="col-6">
                        <div class="card h-100">
                            <div class="card-header bg-light py-2 d-flex justify-content-between">
                                <strong>참조선</strong>
                                <c:if test="${isEditable}">
                                    <a href="${pageContext.request.contextPath}/approval/reference/input?docId=${document.approvalDocumentId}"
                                       class="btn btn-sm btn-outline-success">수정</a>
                                </c:if>
                            </div>
                            
							<div class="card-body p-2" style="max-height:260px; overflow:auto;">
							    <c:if test="${empty referenceTeams and empty referenceIndividuals and empty referenceLines}">
							        <div class="d-flex align-items-center justify-content-center text-muted"
							             style="min-height:120px; width:100%;">지정된 참조자가 없습니다</div>
							    </c:if>

							    <c:if test="${not empty referenceTeams or not empty referenceIndividuals or not empty referenceLines}">
							        <div class="d-flex flex-column gap-2">
							
							            <%-- 팀 전원 참조 배지 --%>
							            <c:if test="${not empty referenceTeams}">
							                <div class="d-flex flex-wrap gap-2">
							                    <c:forEach var="t" items="${referenceTeams}">
							                        <span class="badge bg-light fs-6 px-3 py-2 m-1">
							                            👥 팀: <c:out value="${t.teamName}" />
							                            <c:if test="${not empty t.departmentName}">
							                                &nbsp;(<c:out value="${t.departmentName}" />)
							                            </c:if>
							                        </span>
							                    </c:forEach>
							                </div>
							            </c:if>

							            <%-- 개인 배지 (팀으로 묶이지 않은 사람들) --%>
							            <c:if test="${not empty referenceIndividuals}">
							                <div class="d-flex flex-wrap gap-2">
							                    <c:forEach var="rf" items="${referenceIndividuals}">
							                        <span class="badge bg-light fs-6 px-3 py-2 m-1">
							                            👤 <c:out value="${rf.fullName}" />
							                            <c:if test="${not empty rf.userRank}">&nbsp;(<c:out value="${rf.userRank}" />)</c:if>
							                            <c:if test="${not empty rf.departmentName or not empty rf.teamName}">
							                                &nbsp;-&nbsp;
							                                <c:if test="${not empty rf.departmentName}">
							                                    <c:out value="${rf.departmentName}" />
							                                    <c:if test="${not empty rf.teamName}"> / </c:if>
							                                </c:if>
							                                <c:if test="${not empty rf.teamName}">
							                                    <c:out value="${rf.teamName}" />
							                                </c:if>
							                            </c:if>
							                        </span>
							                    </c:forEach>
							                </div>
							            </c:if>

							            <%-- referenceTeams/Individuals가 없을 때의 안전한 폴백: 기존 referenceLines 그대로 --%>
							            <c:if test="${empty referenceTeams and empty referenceIndividuals and not empty referenceLines}">
							                <div class="d-flex flex-wrap gap-2">
							                    <c:forEach var="rf" items="${referenceLines}">
							                        <span class="badge bg-light fs-6 px-3 py-2 m-1">
							                            👤 <c:out value="${rf.fullName}" />
							                            <c:if test="${not empty rf.userRank}">&nbsp;(<c:out value="${rf.userRank}" />)</c:if>
							                            <c:if test="${not empty rf.departmentName or not empty rf.teamName}">
							                                &nbsp;-&nbsp;
							                                <c:if test="${not empty rf.departmentName}">
							                                    <c:out value="${rf.departmentName}" />
							                                    <c:if test="${not empty rf.teamName}"> / </c:if>
							                                </c:if>
							                                <c:if test="${not empty rf.teamName}">
							                                    <c:out value="${rf.teamName}" />
							                                </c:if>
							                            </c:if>
							                        </span>
							                    </c:forEach>
							                </div>
							            </c:if>
							
							        </div>
							    </c:if>
							</div>

                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<!-- 수정/삭제 버튼 -->
<div class="mt-3 d-flex align-items-center">
    <a href="${pageContext.request.contextPath}/approval/document/main" class="btn btn-outline-secondary">목록</a>

	<!-- 사용자가 기안자 & 수정 가능한 경우 -->
    <c:if test="${isEditable}">
        <div class="ms-auto d-flex gap-2">
            <form method="post"
                  action="${pageContext.request.contextPath}/approval/document/delete/${document.approvalDocumentId}"
                  class="m-0">
                <button type="submit" class="btn btn-outline-danger"
                        onclick="return confirm('정말 삭제하시겠습니까?')">삭제</button>
            </form>
            <a href="${pageContext.request.contextPath}/approval/document/edit/${document.approvalDocumentId}"
               class="btn btn-outline-success">수정</a>
        </div>
    </c:if>
    
    <!-- 사용자가 결재할 차례인 경우 -->
    <c:if test="${canApprove}">
        <div class="ms-auto d-flex gap-2">
            <form method="post" action="${pageContext.request.contextPath}/approval/document/decide-web" class="m-0">
                <input type="hidden" name="documentId" value="${document.approvalDocumentId}">
                <input type="hidden" name="decision" value="APPROVE">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <button type="submit" class="btn btn-success">승인</button>
            </form>

            <form method="post" action="${pageContext.request.contextPath}/approval/document/decide-web" class="m-0 d-flex">
                <input type="hidden" name="documentId" value="${document.approvalDocumentId}">
                <input type="hidden" name="decision" value="REJECT">
                <input type="text" name="comment" placeholder="반려 사유(선택)" class="form-control form-control-sm me-1" style="width:220px;">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <button type="submit" class="btn btn-danger">반려</button>
            </form>
        </div>
    </c:if>
</div>