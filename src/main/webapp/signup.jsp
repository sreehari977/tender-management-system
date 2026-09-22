<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up — Vendor Registration | Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Minimal Header -->
    <nav class="navbar navbar-dark bg-dark border-bottom py-2 shadow-sm">
        <div class="container d-flex justify-content-between align-items-center">
            <a class="navbar-brand fw-bold text-white d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
                <span class="fs-4">&#128737;</span>
                <span>Tender Management System</span>
            </a>
            <div>
                <span class="text-white-50 small me-2">Already registered?</span>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-light btn-sm px-3">
                    Sign In &rarr;
                </a>
            </div>
        </div>
    </nav>

    <!-- Main Registration Container -->
    <div class="container py-5">
        <div class="row g-4 justify-content-center align-items-stretch">
            
            <!-- Left Column: Value Proposition & Onboarding Guide -->
            <div class="col-lg-5 d-flex flex-column justify-content-between">
                <div>
                    <div class="mb-4">
                        <span class="badge bg-primary text-uppercase px-3 py-2 mb-2">Vendor Onboarding</span>
                        <h2 class="fw-bold text-dark">Join the Public &amp; Enterprise Procurement Network</h2>
                        <p class="text-secondary small" style="line-height: 1.6;">
                            Create an official contractor account to participate in transparent, competitive procurement opportunities with legally binding contract awards.
                        </p>
                    </div>

                    <!-- Highlights List -->
                    <div class="d-flex flex-column gap-3 mb-4">
                        <div class="d-flex gap-3 align-items-start p-3 bg-white rounded border shadow-sm">
                            <span class="fs-4 text-primary">&#128196;</span>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">Certified Solicitations</h6>
                                <p class="text-muted small mb-0">Browse verified tenders across Infrastructure, IT, Telecommunications, and Renewable Energy.</p>
                            </div>
                        </div>

                        <div class="d-flex gap-3 align-items-start p-3 bg-white rounded border shadow-sm">
                            <span class="fs-4 text-success">&#9878;</span>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">Transparent L1 Evaluation</h6>
                                <p class="text-muted small mb-0">Fair, rule-based commercial ranking with budget variance benchmarking and complete audit trails.</p>
                            </div>
                        </div>

                        <div class="d-flex gap-3 align-items-start p-3 bg-white rounded border shadow-sm">
                            <span class="fs-4 text-warning">&#128172;</span>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">AI Proposal Assistant</h6>
                                <p class="text-muted small mb-0">Built-in AI copilot for RFP executive summaries, auto-drafting technical proposals, and live strength scoring.</p>
                            </div>
                        </div>

                        <div class="d-flex gap-3 align-items-start p-3 bg-white rounded border shadow-sm">
                            <span class="fs-4 text-info">&#127942;</span>
                            <div>
                                <h6 class="fw-bold mb-1 text-dark">Official Award Certificates</h6>
                                <p class="text-muted small mb-0">Generate and print high-resolution legal contract award certificates upon tender finalization.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Onboarding Note -->
                <div class="alert alert-secondary border-0 p-3 small mb-0 text-muted">
                    <strong>&#9432; Verification Protocol:</strong> New registrations default to <code>PENDING</code> approval. Administrators verify corporate credentials before granting active commercial bidding access.
                </div>
            </div>

            <!-- Right Column: Registration Form -->
            <div class="col-lg-7">
                <div class="card shadow border-0 h-100">
                    <div class="card-body p-4 p-md-5">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h4 class="fw-bold text-dark mb-0">Create Contractor Account</h4>
                            <span class="badge bg-secondary-subtle text-secondary border">Step 1 of 2</span>
                        </div>
                        <p class="text-muted small mb-4">Please fill in your company and authorized representative details accurately.</p>

                        <c:if test="${not empty error}">
                            <div class="alert alert-danger py-2 small d-flex align-items-center gap-2 mb-4">
                                <span>&#9888;</span>
                                <div><c:out value="${error}"/></div>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/register" method="POST" id="signupForm">
                            
                            <!-- Subsection 1: Account & Credentials -->
                            <div class="mb-3">
                                <h6 class="text-uppercase fw-bold text-secondary small mb-3 pb-1 border-bottom" style="letter-spacing: 0.5px;">
                                    1. Authorized Representative
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="nameInput" class="form-label small fw-semibold">
                                            Full Name <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" 
                                               id="nameInput"
                                               name="name" 
                                               class="form-control" 
                                               placeholder="e.g. Ramesh Menon" 
                                               value="<c:out value='${name}'/>" 
                                               required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="emailInput" class="form-label small fw-semibold">
                                            Corporate Email Address <span class="text-danger">*</span>
                                        </label>
                                        <input type="email" 
                                               id="emailInput"
                                               name="email" 
                                               class="form-control" 
                                               placeholder="contact@company.com" 
                                               value="<c:out value='${email}'/>" 
                                               required>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="passwordInput" class="form-label small fw-semibold">
                                            Password <span class="text-danger">*</span>
                                        </label>
                                        <input type="password" 
                                               id="passwordInput"
                                               name="password" 
                                               class="form-control" 
                                               placeholder="Minimum 6 characters" 
                                               minlength="6"
                                               required>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="confirmPasswordInput" class="form-label small fw-semibold">
                                            Confirm Password <span class="text-danger">*</span>
                                        </label>
                                        <input type="password" 
                                               id="confirmPasswordInput"
                                               name="confirmPassword" 
                                               class="form-control" 
                                               placeholder="Re-type password" 
                                               required>
                                        <div id="passwordMatchFeedback" class="form-text small" style="display:none;"></div>
                                    </div>
                                </div>
                            </div>

                            <!-- Subsection 2: Corporate Profile -->
                            <div class="mb-3">
                                <h6 class="text-uppercase fw-bold text-secondary small mb-3 pb-1 border-bottom" style="letter-spacing: 0.5px;">
                                    2. Enterprise Information
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-7">
                                        <label for="companyInput" class="form-label small fw-semibold">
                                            Registered Company / Legal Entity <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" 
                                               id="companyInput"
                                               name="companyName" 
                                               class="form-control" 
                                               placeholder="e.g. Menon Infra Pvt Ltd" 
                                               value="<c:out value='${companyName}'/>" 
                                               required>
                                    </div>
                                    <div class="col-md-5">
                                        <label for="regInput" class="form-label small fw-semibold">
                                            Registration / CIN / GST <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" 
                                               id="regInput"
                                               name="registrationNumber" 
                                               class="form-control" 
                                               placeholder="e.g. REG-TMS-1001" 
                                               value="<c:out value='${registrationNumber}'/>" 
                                               required>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="phoneInput" class="form-label small fw-semibold">
                                    Official Contact Phone <span class="text-danger">*</span>
                                </label>
                                <input type="tel" 
                                       id="phoneInput"
                                       name="phone" 
                                       class="form-control" 
                                       placeholder="e.g. +91-9840012345" 
                                       value="<c:out value='${phone}'/>" 
                                       required>
                            </div>

                            <div class="mb-4">
                                <label for="addressInput" class="form-label small fw-semibold">
                                    Official Registered Address <span class="text-danger">*</span>
                                </label>
                                <textarea id="addressInput"
                                          name="address" 
                                          class="form-control" 
                                          rows="3" 
                                          placeholder="Enter full street, city, state, and postal code..."
                                          required><c:out value='${address}'/></textarea>
                            </div>

                            <!-- Compliance Checkbox -->
                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="termsCheck" required>
                                <label class="form-check-label small text-secondary" for="termsCheck">
                                    I certify that the information provided is true and accurate, and agree to adhere to the <strong>Procurement Code of Conduct</strong> and anti-collusion regulations.
                                </label>
                            </div>

                            <!-- Submit Button -->
                            <button type="submit" class="btn btn-primary w-100 py-2 fw-semibold shadow-sm" id="submitBtn">
                                Complete Vendor Registration &rarr;
                            </button>
                        </form>

                        <hr class="my-4 text-muted">
                        <div class="text-center">
                            <span class="text-muted small">Already have a registered account?</span>
                            <a href="${pageContext.request.contextPath}/login.jsp" class="fw-semibold text-decoration-none small ms-1">
                                Sign In
                            </a>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Footer -->
    <footer class="py-3 bg-white border-top text-center text-muted small mt-auto">
        &copy; 2026 Tender Management System &bull; Secure Enterprise Procurement
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/js/tms-live.js"></script>
    <script>
        // Real-time password match validation
        const password = document.getElementById('passwordInput');
        const confirmPassword = document.getElementById('confirmPasswordInput');
        const feedback = document.getElementById('passwordMatchFeedback');
        const form = document.getElementById('signupForm');

        function checkPasswordMatch() {
            if (!confirmPassword.value) {
                feedback.style.display = 'none';
                return true;
            }
            if (password.value === confirmPassword.value) {
                feedback.style.display = 'block';
                feedback.className = 'form-text small text-success';
                feedback.innerHTML = '&#10003; Passwords match.';
                return true;
            } else {
                feedback.style.display = 'block';
                feedback.className = 'form-text small text-danger';
                feedback.innerHTML = '&#9888; Passwords do not match.';
                return false;
            }
        }

        password.addEventListener('input', checkPasswordMatch);
        confirmPassword.addEventListener('input', checkPasswordMatch);

        form.addEventListener('submit', function(e) {
            if (!checkPasswordMatch()) {
                e.preventDefault();
                confirmPassword.focus();
            }
        });
    </script>
    <jsp:include page="/WEB-INF/includes/ai-copilot.jsp"/>
</body>
</html>
