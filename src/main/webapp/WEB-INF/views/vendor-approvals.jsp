<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Vendor Approvals — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="approvals"/>
    </jsp:include>

    <div class="container">
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2 mb-3">
            <div>
                <h4 class="fw-bold mb-1 text-dark">Vendor Approval Queue</h4>
                <p class="text-muted small mb-0">Review and verify contractor credentials before granting bidding clearance</p>
            </div>
            <div>
                <input type="text" class="form-control form-control-sm" placeholder="🔍 Search vendor applications..." 
                       data-table-filter="#vendorApprovalsTable" style="max-width: 260px;">
            </div>
        </div>

        <c:if test="${param.success == '1'}">
            <div class="alert alert-success alert-dismissible fade show py-2 small" role="alert">
                &#10003; Vendor verification status has been updated and recorded in the audit trail.
            </div>
        </c:if>

        <div class="card shadow-sm border-0">
            <div class="table-responsive">
                <table class="table table-hover bg-white mb-0 align-middle" id="vendorApprovalsTable">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-3">Company Name</th>
                            <th>Reg. Number</th>
                            <th>Authorized Representative</th>
                            <th>Corporate Email</th>
                            <th>Phone</th>
                            <th>Registered Address</th>
                            <th>Status</th>
                            <th class="text-center pe-3" style="width: 170px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="v" items="${pendingVendors}">
                            <tr>
                                <td class="ps-3 fw-semibold text-dark">${v.companyName}</td>
                                <td>
                                    <span class="tms-copyable badge bg-light text-secondary border font-monospace" 
                                          data-copy="${v.registrationNumber}" data-copy-label="Reg Number" title="Click to copy">
                                        ${v.registrationNumber} &#128203;
                                    </span>
                                </td>
                                <td>${v.contactName}</td>
                                <td><a href="mailto:${v.contactEmail}" class="text-decoration-none">${v.contactEmail}</a></td>
                                <td>${v.phone}</td>
                                <td class="small text-muted" style="max-width: 200px;">${v.address}</td>
                                <td>
                                    <span class="badge badge-status-pending">${v.approvalStatus}</span>
                                </td>
                                <td class="text-center pe-3">
                                    <form action="vendor-approvals" method="post" class="d-inline">
                                        <input type="hidden" name="vendorId" value="${v.id}">
                                        <input type="hidden" name="action" value="APPROVE">
                                        <button type="submit" class="btn btn-sm btn-success">Approve</button>
                                    </form>
                                    <form action="vendor-approvals" method="post" class="d-inline ms-1">
                                        <input type="hidden" name="vendorId" value="${v.id}">
                                        <input type="hidden" name="action" value="REJECT">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to reject this vendor?');">Reject</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pendingVendors}">
                            <tr>
                                <td colspan="8" class="text-center text-muted py-4">
                                    No pending vendor registrations to review.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
