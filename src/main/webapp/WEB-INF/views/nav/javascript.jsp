 <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
 <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
 
 <nav>
 <!-- JAVASCRIPT -->
 <script src="${pageContext.request.contextPath}/resources/libs/jquery/jquery.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/bootstrap/js/bootstrap.bundle.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/metismenu/metisMenu.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/simplebar/simplebar.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/node-waves/waves.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/waypoints/lib/jquery.waypoints.min.js"></script>
 <script src="${pageContext.request.contextPath}/resources/libs/jquery.counterup/jquery.counterup.min.js"></script>


 <!-- App js -->
 <script src="${pageContext.request.contextPath}/resources/js/app.js"></script>
 
 <!-- myPage -->
 <script>
    $(document).ready(function () {
       
        const role = '<c:out value="${sessionScope.loginUser.role}" default=""/>';
        console.log("Session role:", role);

        $("#myPageBtn").click(function (e) {
            e.preventDefault();

            if (role === "admin") {
                window.location.href = "/myPage";
            } else if (role === "user") {
                window.location.href = "/myPage";
            } else {
                alert("권한이 없습니다.");
            }
        });
    });
</script>
</nav>