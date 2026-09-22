<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Trail &amp; System Logs — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="audit"/>
    </jsp:include>

    <div class="container py-2">
        <!-- Header -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2 mb-3">
            <div>
                <h4 class="fw-bold mb-1 text-dark">System Audit Trail</h4>
                <p class="text-muted small mb-0">Immutable compliance event log tracking tenders, vendor validations, bids, and contract awards</p>
            </div>
            <div class="badge bg-secondary-subtle text-secondary border px-3 py-2">
                Total Events Logged: <strong>${totalRecords}</strong>
            </div>
        </div>

        <!-- Filter Card -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-3">
                <form action="audit-logs" method="get" class="row g-2 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label small fw-semibold text-secondary mb-1">Filter by Action Type</label>
                        <select name="action" class="form-select form-select-sm">
                            <option value="">All Action Types</option>
                            <c:forEach var="act" items="${distinctActions}">
                                <option value="<c:out value="${act}"/>" ${currentAction == act ? 'selected' : ''}>
                                    <c:out value="${act}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary btn-sm w-100">Apply Filter</button>
                    </div>
                    <c:if test="${not empty currentAction}">
                        <div class="col-md-2">
                            <a href="audit-logs" class="btn btn-outline-secondary btn-sm w-100">Reset Filter</a>
                        </div>
                    </c:if>
                    <div class="col-md-4 ms-auto">
                        <label class="form-label small fw-semibold text-secondary mb-1">Live Search Log Records</label>
                        <input type="text" class="form-control form-control-sm" placeholder="🔍 Quick filter events..." data-table-filter="#auditLogsTable">
                    </div>
                </form>
            </div>
        </div>

        <!-- Audit Table -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0" id="auditLogsTable">
                        <thead class="table-light">
                            <tr>
                                <th class="ps-4" style="width: 180px;">Timestamp</th>
                                <th>Action Event</th>
                                <th>Actor</th>
                                <th>Target Entity</th>
                                <th class="pe-4">Event Details</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="l" items="${logs}">
                                <tr>
                                    <td class="ps-4 small text-secondary">
                                        <c:out value="${l.formattedTimestamp}"/>
                                    </td>
                                    <td>
                                        <span class="badge ${l.actionBadgeClass}">
                                            <c:out value="${l.action}"/>
                                        </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty l.userName}">
                                                <strong class="small text-dark"><c:out value="${l.userName}"/></strong>
                                                <small class="text-muted d-block"><c:out value="${l.userEmail}"/></small>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small">System Process</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-secondary border">
                                            <c:out value="${l.entityType}"/> #<c:out value="${l.entityId}"/>
                                        </span>
                                    </td>
                                    <td class="pe-4 small text-secondary">
                                        <c:out value="${l.details}"/>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty logs}">
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-5">
                                        <div style="font-size: 2.5rem;" class="mb-2">&#128220;</div>
                                        <h6>No audit records found matching criteria</h6>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPages > 1}">
            <nav aria-label="Audit pagination" class="d-flex justify-content-center mb-4">
                <ul class="pagination pagination-sm shadow-sm">
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <a class="page-link" href="audit-logs?page=${currentPage - 1}&action=${currentAction}">&laquo; Previous</a>
                    </li>
                    <c:forEach var="p" begin="1" end="${totalPages}">
                        <li class="page-item ${currentPage == p ? 'active' : ''}">
                            <a class="page-link" href="audit-logs?page=${p}&action=${currentAction}">${p}</a>
                        </li>
                    </c:forEach>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link" href="audit-logs?page=${currentPage + 1}&action=${currentAction}">Next &raquo;</a>
                    </li>
                </ul>
            </nav>
        </c:if>

    </div>

    <!-- Footer -->
    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small">
        &copy; 2026 Tender Management System &bull; Legal Compliance &amp; Audit Trail
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
