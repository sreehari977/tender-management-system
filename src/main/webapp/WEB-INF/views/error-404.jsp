<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found (404) — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <jsp:include page="/WEB-INF/includes/navbar.jsp"/>

    <div class="container my-auto py-5">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow border-0 text-center p-4">
                    <div class="card-body">
                        <div class="mb-3 text-secondary" style="font-size: 4rem;">
                            &#128269; <!-- Magnifying Glass -->
                        </div>
                        <span class="badge bg-secondary px-3 py-2 text-uppercase mb-3">HTTP 404 &bull; Not Found</span>
                        <h3 class="fw-bold text-dark mb-3">Page Not Found</h3>
                        
                        <p class="text-muted mb-4">
                            The page or resource you are looking for does not exist or may have been moved.
                        </p>

                        <div class="d-flex justify-content-center gap-2">
                            <a href="${pageContext.request.contextPath}/tenders" class="btn btn-primary px-4">
                                &larr; Return to Active Tenders
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small">
        &copy; 2026 Tender Management System
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
