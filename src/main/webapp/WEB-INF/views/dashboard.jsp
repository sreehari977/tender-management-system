<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Top Navigation Bar -->
    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="dashboard"/>
    </jsp:include>

    <div class="container py-2">

        <!-- Welcome Banner & Quick Action Buttons -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-4">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <span class="badge bg-primary text-uppercase small">Executive Portal</span>
                            <span class="badge bg-success text-uppercase small">System Online</span>
                        </div>
                        <h4 class="fw-bold mb-1 text-dark">Administrator Control Center</h4>
                        <p class="text-muted small mb-0">Overview of public tenders, submitted commercial proposals, vendor compliance, and awards</p>
                    </div>
                    <div class="d-flex flex-wrap gap-2">
                        <a href="tender-form" class="btn btn-primary px-3 shadow-sm">
                            + Create Tender
                        </a>
                        <a href="vendor-approvals" class="btn btn-outline-secondary px-3">
                            Review Approvals (${pendingApprovals})
                        </a>
                        <a href="audit-logs" class="btn btn-outline-dark px-3">
                            &#128220; Audit Trail
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <!-- 6 Metrics KPI Cards Grid -->
        <div class="row g-3 mb-4">
            <!-- Total Tenders -->
            <div class="col-sm-6 col-lg-4">
                <div class="card shadow-sm border-0 h-100 metric-card">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted text-uppercase small fw-semibold">Total Tenders</span>
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">&#128196;</span>
                        </div>
                        <h2 class="fw-bold text-dark mb-1 counter-value" data-counter="${totalTenders}">${totalTenders}</h2>
                        <small class="text-muted">
                            <strong class="text-success">${publishedTenders} Published</strong> &bull; ${closedTenders} Closed
                        </small>
                    </div>
                </div>
            </div>

            <!-- Total Bids -->
            <div class="col-sm-6 col-lg-4">
                <div class="card shadow-sm border-0 h-100 metric-card">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted text-uppercase small fw-semibold">Total Bids Received</span>
                            <span class="badge bg-info-subtle text-info border border-info-subtle px-2 py-1">&#128221;</span>
                        </div>
                        <h2 class="fw-bold text-dark mb-1 counter-value" data-counter="${totalBids}">${totalBids}</h2>
                        <small class="text-muted">Commercial proposals from verified vendors</small>
                    </div>
                </div>
            </div>

            <!-- Contract Awards -->
            <div class="col-sm-6 col-lg-4">
                <div class="card shadow-sm border-0 h-100 metric-card">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted text-uppercase small fw-semibold">Contract Awards</span>
                            <span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">&#127942;</span>
                        </div>
                        <h2 class="fw-bold text-success mb-1 counter-value" data-counter="${totalAwards}">${totalAwards}</h2>
                        <small class="text-muted">&#8377; ${totalAwardedValue} total awarded contract value</small>
                    </div>
                </div>
            </div>

            <!-- Pending Approvals -->
            <div class="col-sm-6 col-lg-4">
                <div class="card shadow-sm border-0 h-100 metric-card ${pendingApprovals > 0 ? 'border-start border-warning border-4' : ''}">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted text-uppercase small fw-semibold">Pending Vendor Approvals</span>
                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle px-2 py-1">&#9203;</span>
                        </div>
                        <h2 class="fw-bold ${pendingApprovals > 0 ? 'text-warning' : 'text-dark'} mb-1 counter-value" data-counter="${pendingApprovals}">${pendingApprovals}</h2>
                        <c:choose>
                            <c:when test="${pendingApprovals > 0}">
                                <a href="vendor-approvals" class="text-decoration-none small text-warning fw-semibold">
                                    Action required: Review applications &rarr;
                                </a>
                            </c:when>
                            <c:otherwise>
                                <small class="text-muted">All vendor accounts verified</small>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Total Vendors -->
            <div class="col-sm-6 col-lg-4">
                <div class="card shadow-sm border-0 h-100 metric-card">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted text-uppercase small fw-semibold">Total Vendors</span>
                            <span class="badge bg-secondary-subtle text-secondary border px-2 py-1">&#127970;</span>
                        </div>
                        <h2 class="fw-bold text-dark mb-1 counter-value" data-counter="${totalVendors}">${totalVendors}</h2>
                        <small class="text-muted">Registered corporate contractor entities</small>
                    </div>
                </div>
            </div>

            <!-- Active Bidding Rate -->
            <div class="col-sm-6 col-lg-4">
                <div class="card shadow-sm border-0 h-100 metric-card">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="text-muted text-uppercase small fw-semibold">Active Tenders</span>
                            <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">&#128337;</span>
                        </div>
                        <h2 class="fw-bold text-primary mb-1 counter-value" data-counter="${publishedTenders}">${publishedTenders}</h2>
                        <small class="text-muted">Currently open for commercial bids</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section: Recently Published Tenders -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-header bg-white py-3 border-0">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">Recently Published Tenders</h5>
                        <small class="text-muted">Latest procurement opportunities open for bidding</small>
                    </div>
                    <div class="d-flex align-items-center gap-2">
                        <input type="text" class="form-control form-control-sm" placeholder="🔍 Quick filter rows..." 
                               data-table-filter="#recentTendersTable" style="max-width: 220px;">
                        <a href="tenders" class="btn btn-outline-primary btn-sm text-nowrap">View All Tenders &rarr;</a>
                    </div>
                </div>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty recentTenders}">
                        <div class="text-center py-5">
                            <div class="mb-3 text-muted" style="font-size: 3rem;">📁</div>
                            <h6 class="fw-bold text-dark">No Active Published Tenders</h6>
                            <p class="text-muted small">Create and publish a new tender to solicit vendor proposals.</p>
                            <a href="tender-form" class="btn btn-primary btn-sm">+ Create New Tender</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0" id="recentTendersTable">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-4">Tender Title</th>
                                        <th>Category</th>
                                        <th>Estimated Budget</th>
                                        <th>Deadline &amp; Time Left</th>
                                        <th>Status</th>
                                        <th class="text-end pe-4">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="t" items="${recentTenders}">
                                        <tr>
                                            <td class="ps-4">
                                                <div class="d-flex align-items-center gap-1">
                                                    <a href="tender?id=${t.id}" class="text-decoration-none fw-semibold text-primary">
                                                        <c:out value="${t.title}"/>
                                                    </a>
                                                    <span class="tms-copyable badge bg-light text-secondary border small" 
                                                          data-copy="Tender #${t.id}" data-copy-label="Tender ID" title="Click to copy ID">
                                                        #${t.id} &#128203;
                                                    </span>
                                                </div>
                                                <small class="text-muted d-block">Official Solicitation Dossier</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-secondary border">
                                                    <c:out value="${t.category}"/>
                                                </span>
                                            </td>
                                            <td class="fw-bold text-dark">
                                                &#8377; <c:out value="${t.formattedBudget}"/>
                                            </td>
                                            <td>
                                                <small class="text-secondary d-block"><c:out value="${t.formattedDeadline}"/></small>
                                                <span data-deadline="${t.deadline}"></span>
                                            </td>
                                            <td>
                                                <span class="badge badge-status-published"><c:out value="${t.status}"/></span>
                                            </td>
                                            <td class="text-end pe-4">
                                                <div class="btn-group btn-group-sm">
                                                    <a href="tender?id=${t.id}" class="btn btn-outline-secondary">View</a>
                                                    <a href="bids?tenderId=${t.id}" class="btn btn-outline-primary">Bids</a>
                                                    <a href="tender-form?id=${t.id}" class="btn btn-outline-secondary">Edit</a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

    </div>

    <!-- Footer -->
    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small">
        &copy; 2026 Tender Management System &bull; Executive Administrative Console
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
