<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Bids — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="my-bids"/>
    </jsp:include>

    <div class="container py-2">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-1">My Submitted Bids</h4>
                <p class="text-muted small mb-0">Track all commercial quotes and proposals submitted by <c:out value="${vendor.companyName}"/></p>
            </div>
            <a href="tenders" class="btn btn-outline-primary btn-sm">&larr; Browse Active Tenders</a>
        </div>

        <!-- Metrics Summary Cards -->
        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="card shadow-sm border-0 metric-card">
                    <div class="card-body p-3">
                        <small class="text-muted d-block fw-semibold">Total Bids</small>
                        <h4 class="fw-bold mb-0 text-dark counter-value" data-counter="${totalBids}">${totalBids}</h4>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card shadow-sm border-0 metric-card">
                    <div class="card-body p-3">
                        <small class="text-muted d-block fw-semibold">Submitted</small>
                        <h4 class="fw-bold mb-0 text-primary counter-value" data-counter="${submittedCount}">${submittedCount}</h4>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card shadow-sm border-0 metric-card">
                    <div class="card-body p-3">
                        <small class="text-muted d-block fw-semibold">Under Review</small>
                        <h4 class="fw-bold mb-0 text-warning counter-value" data-counter="${underReviewCount}">${underReviewCount}</h4>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card shadow-sm border-0 metric-card">
                    <div class="card-body p-3">
                        <small class="text-muted d-block fw-semibold">Awarded Contracts</small>
                        <h4 class="fw-bold mb-0 text-success counter-value" data-counter="${awardedCount}">${awardedCount}</h4>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bids Table Card with Live Filter -->
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white py-3 border-0">
                <div class="d-flex justify-content-between align-items-center">
                    <h6 class="fw-bold mb-0 text-dark">Submission History &amp; Decision Record</h6>
                    <input type="text" class="form-control form-control-sm" placeholder="🔍 Quick filter my bids..." 
                           data-table-filter="#myBidsTable" style="max-width: 220px;">
                </div>
            </div>
            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${not empty bids}">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0" id="myBidsTable">
                                <thead class="table-light">
                                    <tr>
                                        <th class="ps-4">Tender Title</th>
                                        <th>Category</th>
                                        <th>Bid Amount</th>
                                        <th>Submitted On</th>
                                        <th>Status</th>
                                        <th class="text-center" style="width: 180px;">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="b" items="${bids}" varStatus="status">
                                        <tr>
                                            <td class="ps-4">
                                                <a href="tender?id=${b.tenderId}" class="text-decoration-none fw-semibold text-primary">
                                                    <c:out value="${b.tenderTitle}"/>
                                                </a>
                                                <small class="text-muted d-block">Tender #${b.tenderId}</small>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-secondary border">
                                                    <c:out value="${not empty b.tenderCategory ? b.tenderCategory : 'General'}"/>
                                                </span>
                                            </td>
                                            <td class="fw-bold text-dark">
                                                &#8377; <c:out value="${b.formattedAmount}"/>
                                            </td>
                                            <td>
                                                <span class="small text-muted"><c:out value="${b.formattedSubmittedAt}"/></span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${b.status == 'SUBMITTED'}">
                                                        <span class="badge bg-primary px-2 py-1">SUBMITTED</span>
                                                    </c:when>
                                                    <c:when test="${b.status == 'UNDER_REVIEW'}">
                                                        <span class="badge bg-warning text-dark px-2 py-1">UNDER_REVIEW</span>
                                                    </c:when>
                                                    <c:when test="${b.status == 'AWARDED'}">
                                                        <span class="badge bg-success px-2 py-1">AWARDED</span>
                                                    </c:when>
                                                    <c:when test="${b.status == 'REJECTED'}">
                                                        <span class="badge bg-danger px-2 py-1">REJECTED</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary px-2 py-1"><c:out value="${b.status}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-center">
                                                <c:if test="${b.status == 'AWARDED'}">
                                                    <a href="award-certificate?tenderId=${b.tenderId}" class="btn btn-sm btn-success me-1" title="View & Print Official Contract Certificate">
                                                        &#127942; Certificate
                                                    </a>
                                                </c:if>
                                                <button type="button" class="btn btn-sm btn-outline-secondary me-1"
                                                        data-bs-toggle="modal" data-bs-target="#proposalModal${b.id}">
                                                    View Proposal
                                                </button>
                                                <a href="tender?id=${b.tenderId}" class="btn btn-sm btn-outline-primary" title="View Tender">
                                                    &rarr;
                                                </a>

                                                <!-- Modal for viewing proposal -->
                                                <div class="modal fade" id="proposalModal${b.id}" tabindex="-1" aria-labelledby="modalLabel${b.id}" aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered modal-lg">
                                                        <div class="modal-content text-start">
                                                            <div class="modal-header">
                                                                <h5 class="modal-title" id="modalLabel${b.id}">
                                                                    Proposal for <c:out value="${b.tenderTitle}"/>
                                                                </h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                                            </div>
                                                            <div class="modal-body">
                                                                <div class="d-flex justify-content-between p-2 bg-light rounded mb-3">
                                                                    <div>
                                                                        <small class="text-muted d-block">Submitted Amount</small>
                                                                        <span class="fw-bold fs-6 text-dark">&#8377; <c:out value="${b.formattedAmount}"/></span>
                                                                    </div>
                                                                    <div class="text-end">
                                                                        <small class="text-muted d-block">Submitted Timestamp</small>
                                                                        <span class="small"><c:out value="${b.formattedSubmittedAt}"/></span>
                                                                    </div>
                                                                </div>

                                                                <c:if test="${not empty b.attachmentFilename}">
                                                                    <div class="p-2 border rounded bg-light mb-3 d-flex justify-content-between align-items-center">
                                                                        <span class="small text-secondary">
                                                                            &#128206; <strong>Attached Technical Schedule:</strong> <c:out value="${b.attachmentFilename}"/>
                                                                        </span>
                                                                        <a href="download?type=bid&id=${b.id}" class="btn btn-primary btn-sm">
                                                                            Download Attachment
                                                                        </a>
                                                                    </div>
                                                                </c:if>

                                                                <h6 class="fw-semibold mb-2">Technical Proposal & Methodology</h6>
                                                                <div class="p-3 bg-light rounded border text-secondary small" style="white-space: pre-wrap; line-height: 1.6; word-break: break-word;"><c:out value="${b.proposalText}"/></div>
                                                            </div>
                                                            <div class="modal-footer">
                                                                <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                                                                <a href="tender?id=${b.tenderId}" class="btn btn-primary btn-sm">Go to Tender</a>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- Empty State -->
                        <div class="text-center py-5">
                            <div class="mb-3 text-muted" style="font-size: 3rem;">📋</div>
                            <h5 class="fw-bold text-dark">No Bids Submitted Yet</h5>
                            <p class="text-muted small mx-auto" style="max-width: 420px;">
                                You haven't submitted any commercial proposals yet. Explore active published tenders to find projects matching your company's qualifications.
                            </p>
                            <a href="tenders" class="btn btn-primary px-4 py-2 mt-2">
                                Explore Active Tenders
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
