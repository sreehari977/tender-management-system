<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Active Tenders — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="tenders"/>
    </jsp:include>

    <div class="container py-2">
        <!-- Header & Action Button -->
        <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-2 mb-3">
            <div>
                <h4 class="fw-bold mb-1 text-dark">Active Public Tenders</h4>
                <p class="text-muted small mb-0">Browse open procurement opportunities and submit commercial proposals</p>
            </div>
            <c:if test="${sessionScope.userRole == 'ADMIN'}">
                <div>
                    <a href="tender-form" class="btn btn-primary px-3 shadow-sm">+ Create Tender</a>
                </div>
            </c:if>
        </div>

        <!-- Search & Filter Card -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-3">
                <form action="tenders" method="get" class="row g-2 align-items-end">
                    <!-- Keyword Search -->
                    <div class="col-md-3">
                        <label class="form-label small fw-semibold text-secondary mb-1">Search Keywords</label>
                        <input type="text" name="q" class="form-control form-control-sm" 
                               placeholder="Search title, scope..." value="<c:out value="${currentQuery}"/>">
                    </div>

                    <!-- Category Dropdown -->
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold text-secondary mb-1">Category</label>
                        <select name="category" class="form-select form-select-sm">
                            <option value="">All Categories</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="<c:out value="${cat}"/>" ${currentCategory == cat ? 'selected' : ''}>
                                    <c:out value="${cat}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Min Budget -->
                    <div class="col-sm-6 col-md-2">
                        <label class="form-label small fw-semibold text-secondary mb-1">Min Budget (&#8377;)</label>
                        <input type="number" name="minBudget" step="any" class="form-control form-control-sm" 
                               placeholder="Min ₹" value="<c:out value="${currentMinBudget}"/>">
                    </div>

                    <!-- Max Budget -->
                    <div class="col-sm-6 col-md-2">
                        <label class="form-label small fw-semibold text-secondary mb-1">Max Budget (&#8377;)</label>
                        <input type="number" name="maxBudget" step="any" class="form-control form-control-sm" 
                               placeholder="Max ₹" value="<c:out value="${currentMaxBudget}"/>">
                    </div>

                    <!-- Sort Dropdown -->
                    <div class="col-md-2">
                        <label class="form-label small fw-semibold text-secondary mb-1">Sort By</label>
                        <select name="sort" class="form-select form-select-sm">
                            <option value="deadline_asc" ${currentSort == 'deadline_asc' ? 'selected' : ''}>Deadline: Soonest</option>
                            <option value="deadline_desc" ${currentSort == 'deadline_desc' ? 'selected' : ''}>Deadline: Latest</option>
                            <option value="budget_asc" ${currentSort == 'budget_asc' ? 'selected' : ''}>Budget: Low to High</option>
                            <option value="budget_desc" ${currentSort == 'budget_desc' ? 'selected' : ''}>Budget: High to Low</option>
                            <option value="newest" ${currentSort == 'newest' ? 'selected' : ''}>Recently Added</option>
                        </select>
                    </div>

                    <!-- Filter & Reset Buttons -->
                    <div class="col-md-1 d-flex gap-1">
                        <button type="submit" class="btn btn-primary btn-sm flex-fill" title="Filter Tenders">
                            Filter
                        </button>
                        <a href="tenders" class="btn btn-outline-secondary btn-sm" title="Clear Filters">
                            &#10005;
                        </a>
                    </div>
                </form>
                <hr class="my-2 text-muted opacity-25">
                <div class="d-flex flex-wrap align-items-center gap-2 pt-1">
                    <span class="small text-muted fw-semibold me-1">Quick Sectors:</span>
                    <a href="tenders" class="badge ${empty currentCategory ? 'bg-primary text-white' : 'bg-light text-secondary border'} text-decoration-none py-1 px-3">All Sectors</a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="tenders?category=${cat}" class="badge ${currentCategory == cat ? 'bg-primary text-white' : 'bg-light text-secondary border'} text-decoration-none py-1 px-3">
                            <c:out value="${cat}"/>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- Filter Results Stats Bar & Live Instant Filter -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2 mb-2 px-1">
            <div class="d-flex align-items-center gap-2">
                <span class="text-muted small">
                    Showing <strong>${tenders.size()}</strong> of <strong>${totalRecords}</strong> tenders (Page ${currentPage} of ${totalPages})
                </span>
                <span id="tendersMatchCount" class="badge bg-secondary-subtle text-secondary small"></span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <input type="text" class="form-control form-control-sm" placeholder="🔍 Instant search on page..." 
                       data-table-filter="#tendersMasterTable" data-filter-count="#tendersMatchCount" style="max-width: 240px;">
                <c:if test="${not empty currentQuery or not empty currentCategory or not empty currentMinBudget or not empty currentMaxBudget}">
                    <a href="tenders" class="btn btn-outline-danger btn-sm py-1 px-2 text-nowrap">
                        &times; Reset Filters
                    </a>
                </c:if>
            </div>
        </div>

        <!-- Tenders Table -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="tendersMasterTable">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4">Tender Title &amp; Scope</th>
                                <th>Category</th>
                                <th>Estimated Budget</th>
                                <th>Deadline &amp; Time Remaining</th>
                                <th>Status</th>
                                <c:if test="${sessionScope.userRole == 'ADMIN'}">
                                    <th class="text-end pe-4" style="width: 140px;">Actions</th>
                                </c:if>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="t" items="${tenders}">
                                <tr>
                                    <td class="ps-4">
                                        <div class="d-flex align-items-center gap-2">
                                            <a href="tender?id=${t.id}" class="text-decoration-none fw-semibold text-primary">
                                                <c:out value="${t.title}"/>
                                            </a>
                                            <c:if test="${not empty t.attachmentFilename}">
                                                <a href="download?type=tender&id=${t.id}" class="badge bg-light text-primary border text-decoration-none" title="Download Specification PDF">
                                                    &#128206; Spec Attached
                                                </a>
                                            </c:if>
                                        </div>
                                        <div class="d-flex align-items-center gap-2 mt-1">
                                            <span class="tms-copyable badge bg-light text-secondary border small" 
                                                  data-copy="TMS-TND-${t.id}" data-copy-label="Tender Reference" title="Click to copy Reference ID">
                                                Ref #TMS-TND-${t.id} &#128203;
                                            </span>
                                            <small class="text-muted text-truncate" style="max-width: 380px;">
                                                <c:out value="${t.description}"/>
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-secondary border">
                                            <c:out value="${t.category != null ? t.category : 'General'}"/>
                                        </span>
                                    </td>
                                    <td class="fw-bold text-dark">
                                        &#8377; <c:out value="${t.formattedBudget}"/>
                                    </td>
                                    <td>
                                        <div class="small text-secondary mb-1"><c:out value="${t.formattedDeadline}"/></div>
                                        <div data-deadline="${t.deadline}">
                                            <small class="badge bg-light text-primary border px-2 py-0" style="font-size:0.7rem;">
                                                <c:out value="${t.timeRemaining}"/>
                                            </small>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-status-published">
                                            <c:out value="${t.status}"/>
                                        </span>
                                    </td>
                                    <c:if test="${sessionScope.userRole == 'ADMIN'}">
                                        <td class="text-end pe-4">
                                            <div class="btn-group btn-group-sm">
                                                <a href="bids?tenderId=${t.id}" class="btn btn-outline-primary" title="Compare Bids">Bids</a>
                                                <a href="tender-form?id=${t.id}" class="btn btn-outline-secondary" title="Edit Tender">Edit</a>
                                            </div>
                                        </td>
                                    </c:if>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty tenders}">
                                <tr>
                                    <td colspan="${sessionScope.userRole == 'ADMIN' ? 6 : 5}" class="text-center text-muted py-5">
                                        <div class="mb-2" style="font-size: 2.5rem;">&#128269;</div>
                                        <h6 class="fw-bold text-secondary">No matching tenders found</h6>
                                        <p class="small text-muted mb-3">Try adjusting your keyword, category, or budget range filters.</p>
                                        <a href="tenders" class="btn btn-outline-primary btn-sm">Clear All Filters</a>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Pagination Controls -->
        <c:if test="${totalPages > 1}">
            <nav aria-label="Tenders pagination" class="d-flex justify-content-center mb-4">
                <ul class="pagination pagination-sm shadow-sm">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="tenders?page=${currentPage - 1}&q=${currentQuery}&category=${currentCategory}&minBudget=${currentMinBudget}&maxBudget=${currentMaxBudget}&sort=${currentSort}">
                            &laquo; Previous
                        </a>
                    </li>
                    <c:forEach var="p" begin="1" end="${totalPages}">
                        <li class="page-item ${currentPage == p ? 'active' : ''}">
                            <a class="page-link" href="tenders?page=${p}&q=${currentQuery}&category=${currentCategory}&minBudget=${currentMinBudget}&maxBudget=${currentMaxBudget}&sort=${currentSort}">
                                ${p}
                            </a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="tenders?page=${currentPage + 1}&q=${currentQuery}&category=${currentCategory}&minBudget=${currentMinBudget}&maxBudget=${currentMaxBudget}&sort=${currentSort}">
                            Next &raquo;
                        </a>
                    </li>
                </ul>
            </nav>
        </c:if>
    </div>

    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small">
        &copy; 2026 Tender Management System &bull; Public Procurement Portal
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
