<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><c:out value="${tender.title}"/> — Tender Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="tenders"/>
    </jsp:include>

    <div class="container py-3" style="max-width: 860px;">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="tenders" class="text-decoration-none">&larr; Back to Tenders</a></li>
                <li class="breadcrumb-item active" aria-current="page">Tender Details</li>
            </ol>
        </nav>

        <c:if test="${param.bidSuccess == '1'}">
            <div class="alert alert-success py-2 px-3 mb-3 d-flex align-items-center">
                <span class="fs-5 me-2">&#10004;</span>
                <div>
                    <strong>Bid Submitted Successfully!</strong> Your formal quote and proposal have been securely recorded.
                </div>
            </div>
        </c:if>

        <c:if test="${hasSubmittedBid}">
            <div class="alert alert-info py-2 px-3 mb-3 small d-flex justify-content-between align-items-center">
                <div>
                    <strong>Bid On File:</strong> You submitted a bid of <strong>&#8377; <c:out value="${existingBid.formattedAmount}"/></strong> on <c:out value="${existingBid.formattedSubmittedAt}"/>.
                </div>
                <span class="badge bg-primary px-2 py-1">Status: <c:out value="${existingBid.status}"/></span>
            </div>
        </c:if>

        <c:if test="${tender.status == 'DRAFT'}">
            <div class="alert alert-secondary border-secondary-subtle py-2 px-3 mb-3 d-flex align-items-center">
                <span class="badge bg-secondary me-2">DRAFT MODE</span>
                <span class="small text-secondary">This tender is currently unpublished and visible only to administrators.</span>
            </div>
        </c:if>

        <c:if test="${sessionScope.userRole == 'VENDOR' && !isApprovedVendor}">
            <div class="alert alert-warning py-2 px-3 mb-3 small">
                <strong>Notice:</strong> Your vendor account is currently not approved. Bidding is restricted to approved vendors.
            </div>
        </c:if>

        <c:if test="${tender.status == 'PUBLISHED' && isDeadlinePassed}">
            <div class="alert alert-danger py-2 px-3 mb-3 small">
                <strong>Bidding Closed:</strong> The submission deadline for this tender passed on <c:out value="${tender.formattedDeadline}"/>.
            </div>
        </c:if>

        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-4">
                <div class="d-flex justify-content-between align-items-start mb-3">
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-2">
                            <span class="badge bg-secondary"><c:out value="${not empty tender.category ? tender.category : 'General'}"/></span>
                            <span class="tms-copyable badge bg-light text-secondary border small" 
                                  data-copy="Tender #${tender.id}" data-copy-label="Tender ID" title="Click to copy ID">
                                #${tender.id} &#128203;
                            </span>
                        </div>
                        <h3 class="card-title fw-bold text-dark mb-1"><c:out value="${tender.title}"/></h3>
                        <small class="text-muted">Official Solicitation Reference: #<c:out value="${tender.id}"/></small>
                    </div>
                    <div>
                        <c:choose>
                            <c:when test="${tender.status == 'PUBLISHED'}">
                                <span class="badge bg-success fs-6 px-3 py-2">PUBLISHED</span>
                            </c:when>
                            <c:when test="${tender.status == 'DRAFT'}">
                                <span class="badge bg-secondary fs-6 px-3 py-2">DRAFT</span>
                            </c:when>
                            <c:when test="${tender.status == 'CLOSED'}">
                                <span class="badge bg-danger fs-6 px-3 py-2">CLOSED</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-dark fs-6 px-3 py-2"><c:out value="${tender.status}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <hr class="my-3 text-muted">

                <div class="row g-3 py-2">
                    <div class="col-sm-6 col-md-3">
                        <div class="text-muted small">Estimated Budget</div>
                        <div class="fs-5 fw-semibold text-dark">
                            <c:choose>
                                <c:when test="${not empty tender.estimatedBudget}">
                                    &#8377; <c:out value="${tender.formattedBudget}"/>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted fst-italic">Not specified</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <div class="text-muted small">Publish Date</div>
                        <div class="fw-medium text-dark">
                            <c:out value="${tender.formattedPublishDate}"/>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <div class="text-muted small">Submission Deadline</div>
                        <div class="fw-medium ${isDeadlinePassed ? 'text-danger' : 'text-dark'}">
                            <c:out value="${tender.formattedDeadline}"/>
                            <div class="mt-1" data-deadline="${tender.deadline}">
                                <c:if test="${not empty tender.timeRemaining}">
                                    <span class="badge ${isDeadlinePassed ? 'bg-danger' : 'bg-info text-dark'} small">
                                        <c:out value="${tender.timeRemaining}"/>
                                    </span>
                                </c:if>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-md-3">
                        <div class="text-muted small">Bidding Status</div>
                        <div class="fw-medium">
                            <c:choose>
                                <c:when test="${tender.status == 'PUBLISHED' && !isDeadlinePassed}">
                                    <span class="text-success fw-semibold">Open for Bids</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Closed</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <hr class="my-3 text-muted">

                <div class="mb-4">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="fw-semibold mb-0">Scope of Work &amp; Requirements</h5>
                        <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-2" 
                                data-copy="${tender.title} - Scope: ${tender.description}" data-copy-label="Tender Scope">
                            &#128203; Copy Scope
                        </button>
                    </div>
                    <div class="p-3 bg-light rounded border text-secondary" style="white-space: pre-wrap; word-break: break-word; overflow-wrap: anywhere; line-height: 1.6;"><c:out value="${tender.description}"/></div>
                </div>

                <!-- AI Executive Summary & Key Highlights -->
                <div class="card ai-card-banner mb-4 shadow-sm">
                    <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center pt-3 px-3">
                        <div class="d-flex align-items-center gap-2">
                            <span class="fs-5">✨</span>
                            <h6 class="fw-bold mb-0 text-dark">AI RFP Executive Summary &amp; Deliverables Extractor</h6>
                            <span class="badge ai-tag ms-1">AI INSIGHTS</span>
                        </div>
                        <button type="button" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1" id="refreshAiSummaryBtn" style="font-size: 0.75rem;">
                            &#8635; Re-analyze
                        </button>
                    </div>
                    <div class="card-body p-3 pt-1">
                        <div id="aiSummaryLoading" class="text-center py-3 text-muted">
                            <div class="spinner-border spinner-border-sm text-primary mb-1" role="status"></div>
                            <div class="small">Extracting scope deliverables and compliance parameters...</div>
                        </div>
                        <div id="aiSummaryContent" class="d-none">
                            <p class="text-dark small mb-3 p-3 bg-white rounded border shadow-sm" id="aiExecutiveSummary" style="line-height: 1.5;"></p>
                            <div class="row g-3">
                                <div class="col-md-7">
                                    <h6 class="fw-bold text-dark small text-uppercase mb-2" style="letter-spacing: 0.5px;">📌 Key Technical Deliverables</h6>
                                    <ul class="list-unstyled mb-0" id="aiDeliverablesList"></ul>
                                </div>
                                <div class="col-md-5">
                                    <div class="p-3 bg-white rounded border shadow-sm">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="text-muted small fw-semibold">Procurement Risk:</span>
                                            <span class="badge px-2 py-1" id="aiRiskBadge"></span>
                                        </div>
                                        <p class="small text-secondary mb-2" id="aiRiskRationale" style="font-size: 0.78rem; line-height: 1.35;"></p>
                                        <hr class="my-2">
                                        <span class="text-muted small fw-bold d-block mb-1">Mandatory Vendor Credentials:</span>
                                        <ul class="list-unstyled mb-0" id="aiQualificationsList"></ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Official RFP / Specification Document Attachment -->
                <c:if test="${not empty tender.attachmentFilename}">
                    <div class="card bg-light border mb-4">
                        <div class="card-body p-3 d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-3">
                            <div class="d-flex align-items-center gap-3">
                                <span style="font-size: 2rem;">&#128196;</span>
                                <div>
                                    <h6 class="fw-bold mb-0 text-dark">Official Tender Specification Document</h6>
                                    <small class="text-muted"><c:out value="${tender.attachmentFilename}"/></small>
                                </div>
                            </div>
                            <a href="download?type=tender&id=${tender.id}" class="btn btn-primary btn-sm px-3 shadow-sm text-nowrap">
                                &#128229; Download Document
                            </a>
                        </div>
                    </div>
                </c:if>

                <!-- Concluded Award Banner -->
                <c:if test="${tender.status == 'CLOSED'}">
                    <div class="alert alert-success border-success-subtle p-3 mb-4 d-flex flex-column flex-sm-row justify-content-between align-items-sm-center gap-2">
                        <div>
                            <span class="fs-5 me-2">&#127942;</span>
                            <strong>Contract Awarded:</strong> This tender has concluded and an official contract award certificate has been issued.
                        </div>
                        <a href="award-certificate?tenderId=${tender.id}" class="btn btn-outline-success btn-sm text-nowrap">
                            View Award Certificate &rarr;
                        </a>
                    </div>
                </c:if>

                <!-- Action Triggers -->
                <div class="d-flex flex-wrap align-items-center justify-content-between pt-2">
                    <div>
                        <a href="tenders" class="btn btn-outline-secondary">&larr; Back to Tenders</a>
                    </div>
                    <div class="d-flex gap-2 mt-2 mt-sm-0">
                        <c:if test="${sessionScope.userRole == 'ADMIN'}">
                            <a href="tender-form?id=${tender.id}" class="btn btn-outline-primary">Edit Tender</a>
                            <a href="bids?tenderId=${tender.id}" class="btn btn-outline-secondary">Compare Bids</a>
                        </c:if>

                        <c:if test="${sessionScope.userRole == 'VENDOR'}">
                            <c:choose>
                                <c:when test="${hasSubmittedBid}">
                                    <button class="btn btn-outline-success px-4" disabled>&#10003; Bid Already Submitted</button>
                                </c:when>
                                <c:when test="${canSubmitBid}">
                                    <a href="bid?tenderId=${tender.id}" class="btn btn-success px-4 fw-semibold">Submit Bid</a>
                                </c:when>
                                <c:when test="${!isApprovedVendor}">
                                    <button class="btn btn-secondary px-4" disabled title="Account awaiting admin approval">Submit Bid (Approval Required)</button>
                                </c:when>
                                <c:when test="${isDeadlinePassed}">
                                    <button class="btn btn-secondary px-4" disabled title="Deadline has passed">Deadline Expired</button>
                                </c:when>
                                <c:otherwise>
                                    <button class="btn btn-secondary px-4" disabled>Bidding Not Open</button>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var tenderId = '${tender.id}';
        var contextPath = '${pageContext.request.contextPath}';

        function loadAiSummary() {
            var loading = document.getElementById('aiSummaryLoading');
            var content = document.getElementById('aiSummaryContent');
            loading.classList.remove('d-none');
            content.classList.add('d-none');

            fetch(contextPath + '/api/ai?action=summarize_tender&tenderId=' + encodeURIComponent(tenderId))
                .then(function(res) { return res.ok ? res.json() : null; })
                .then(function(data) {
                    if (!data) return;
                    loading.classList.add('d-none');
                    content.classList.remove('d-none');

                    document.getElementById('aiExecutiveSummary').textContent = data.executiveSummary || '';

                    var delivList = document.getElementById('aiDeliverablesList');
                    delivList.innerHTML = '';
                    (data.deliverables || []).forEach(function(d) {
                        var li = document.createElement('li');
                        li.className = 'small text-secondary mb-2 d-flex align-items-start gap-2';
                        li.innerHTML = '<span class="text-primary fw-bold">&bull;</span><span>' + escapeHtml(d) + '</span>';
                        delivList.appendChild(li);
                    });

                    var riskBadge = document.getElementById('aiRiskBadge');
                    var riskLevel = (data.riskLevel || 'LOW').toUpperCase();
                    riskBadge.textContent = riskLevel + ' RISK';
                    if (riskLevel === 'HIGH') {
                        riskBadge.className = 'badge bg-danger';
                    } else if (riskLevel === 'MEDIUM') {
                        riskBadge.className = 'badge bg-warning text-dark';
                    } else {
                        riskBadge.className = 'badge bg-success';
                    }

                    document.getElementById('aiRiskRationale').textContent = data.riskRationale || '';

                    var qualList = document.getElementById('aiQualificationsList');
                    qualList.innerHTML = '';
                    (data.qualifications || []).forEach(function(q) {
                        var li = document.createElement('li');
                        li.className = 'small text-secondary mb-1 d-flex align-items-start gap-2';
                        li.style.fontSize = '0.78rem';
                        li.innerHTML = '<span class="text-success fw-bold">&#10003;</span><span>' + escapeHtml(q) + '</span>';
                        qualList.appendChild(li);
                    });
                })
                .catch(function() {
                    loading.innerHTML = '<div class="small text-muted py-2">AI Summary temporarily unavailable.</div>';
                });
        }

        loadAiSummary();

        var refreshBtn = document.getElementById('refreshAiSummaryBtn');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', function() {
                loadAiSummary();
            });
        }

        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    });
    </script>
</body>
</html>
