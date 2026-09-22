<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container d-flex align-items-center justify-content-center py-5" style="min-height:100vh;">
        <div class="card shadow border-0" style="max-width:440px; width:100%;">
            <div class="card-body p-4 p-md-5">
                <div class="text-center mb-4">
                    <span class="fs-1 text-primary mb-2 d-inline-block">&#128737;</span>
                    <h4 class="fw-bold text-dark mb-1">Tender Management System</h4>
                    <p class="text-muted small mb-0">Secure Public &amp; Enterprise Procurement Portal</p>
                </div>

                <% if ("pending".equals(request.getParameter("registered"))) { %>
                    <div class="alert alert-success py-2 small d-flex align-items-center gap-2 mb-3">
                        <span>&#10003;</span>
                        <div>Registration submitted! Your account is pending administrator approval before you can log in.</div>
                    </div>
                <% } %>

                <% if ("1".equals(request.getParameter("error"))) { %>
                    <div class="alert alert-danger py-2 small d-flex align-items-center gap-2 mb-3">
                        <span>&#9888;</span>
                        <div>Invalid email or password.</div>
                    </div>
                <% } %>

                <!-- Quick Demo Login Fillers -->
                <div class="d-flex gap-2 mb-3">
                    <button type="button" class="btn btn-outline-primary btn-sm flex-fill py-1 small" 
                            onclick="document.getElementById('emailField').value='admin@tms.com';document.getElementById('passField').value='admin123';">
                        &#128100; Admin Demo
                    </button>
                    <button type="button" class="btn btn-outline-secondary btn-sm flex-fill py-1 small" 
                            onclick="document.getElementById('emailField').value='vendor1@tms.com';document.getElementById('passField').value='vendor123';">
                        &#127970; Vendor Demo
                    </button>
                </div>

                <form action="login" method="post" id="loginForm">
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Corporate Email Address</label>
                        <input type="email" name="email" id="emailField" class="form-control" placeholder="name@company.com" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label small fw-semibold">Password</label>
                        <input type="password" name="password" id="passField" class="form-control" placeholder="••••••••" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm" id="submitLoginBtn">
                        Sign In &rarr;
                    </button>
                    <div class="text-center mt-3">
                        <span class="text-muted small">New to the platform?</span>
                        <a href="signup.jsp" class="text-decoration-none small fw-semibold ms-1">Register as a contractor</a>
                    </div>
                </form>

                <hr class="my-4 text-muted">
                <p class="text-muted small mb-0 text-center">
                    Authorized access only &bull; Audited under statutory procurement standards
                </p>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/tms-live.js"></script>
    <jsp:include page="/WEB-INF/includes/ai-copilot.jsp"/>
</body>
</html>
