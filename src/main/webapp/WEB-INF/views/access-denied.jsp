<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <!-- Top Navigation Bar -->
    <jsp:include page="/WEB-INF/includes/navbar.jsp"/>

    <!-- Error Content Container -->
    <div class="container my-auto py-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow border-0 text-center p-4">
                    <div class="card-body">
                        <div class="mb-3 text-warning" style="font-size: 4rem;">
                            &#128737; <!-- Shield Icon -->
                        </div>
                        <span class="badge bg-danger px-3 py-2 text-uppercase mb-3">HTTP 403 &bull; Access Denied</span>
                        <h3 class="fw-bold text-dark mb-3">Insufficient Privileges</h3>
                        
                        <div class="alert alert-light border text-start mb-4">
                            <p class="mb-1 text-secondary small fw-semibold">REASON:</p>
                            <p class="mb-0 text-dark">
                                <c:choose>
                                    <c:when test="${not empty requestScope['jakarta.servlet.error.message']}">
                                        <c:out value="${requestScope['jakarta.servlet.error.message']}"/>
                                    </c:when>
                                    <c:when test="${not empty errorMessage}">
                                        <c:out value="${errorMessage}"/>
                                    </c:when>
                                    <c:otherwise>
                                        You do not have administrative or appropriate role permissions to view or perform actions on this resource.
                                    </c:otherwise>
                                </c:choose>
                            </p>
                            <c:if test="${not empty sessionScope.userRole}">
                                <hr class="my-2">
                                <small class="text-muted">
                                    Current Session: <strong><c:out value="${sessionScope.userName}"/></strong> (Role: <span class="badge bg-secondary"><c:out value="${sessionScope.userRole}"/></span>)
                                </small>
                            </c:if>
                        </div>

                        <p class="text-muted small mb-4">
                            If you believe this is in error, please sign in with an account having the required role privileges or return to the main dashboard.
                        </p>

                        <div class="d-flex justify-content-center gap-2">
                            <a href="${pageContext.request.contextPath}/tenders" class="btn btn-primary px-4">
                                &larr; Return to Active Tenders
                            </a>
                            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-secondary px-4">
                                Switch Account
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small">
        &copy; 2026 Tender Management System &bull; Secure Role-Based Access Control
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
