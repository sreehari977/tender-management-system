<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bid Comparison & Award — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Navbar -->
    <jsp:include page="/WEB-INF/includes/navbar.jsp"/>

    <div class="container py-2">

        <!-- Breadcrumb navigation -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb small">
                <li class="breadcrumb-item"><a href="tenders" class="text-decoration-none">Tenders</a></li>
                <li class="breadcrumb-item"><a href="tender?id=${tender.id}" class="text-decoration-none">Tender #${tender.id}</a></li>
                <li class="breadcrumb-item active" aria-current="page">Bid Evaluation &amp; Award</li>
            </ol>
        </nav>

        <!-- Flash alerts -->
        <c:if test="${param.awarded == '1'}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm d-flex align-items-center mb-4" role="alert">
                <div class="fs-4 me-3">&#127881;</div>
                <div>
                    <strong>Contract Successfully Awarded!</strong> The selected vendor has been officially awarded the contract. All competing bids have been marked as rejected, the tender is now <strong>CLOSED</strong>, and an immutable audit log record has been recorded.
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <c:if test="${param.alreadyAwarded == '1'}">
            <div class="alert alert-warning alert-dismissible fade show shadow-sm" role="alert">
                <strong>Notice:</strong> This tender has already been awarded and closed. No further award actions can be performed.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Tender Context Overview Card -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-4">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <span class="badge bg-secondary text-uppercase small">Tender #${tender.id}</span>
                            <span class="badge ${tender.status == 'PUBLISHED' ? 'bg-success' : 'bg-dark'} text-uppercase small">
                                <c:out value="${tender.status}"/>
                            </span>
                            <span class="badge bg-light text-dark border small"><c:out value="${tender.category}"/></span>
                        </div>
                        <h4 class="fw-bold mb-1 text-dark"><c:out value="${tender.title}"/></h4>
                        <p class="text-muted small mb-0">Commercial bid evaluation, compliance comparison, and contract awarding console</p>
                    </div>

                    <div class="d-flex align-items-center gap-4 border-start-md ps-md-4">
                        <div>
                            <small class="text-muted d-block text-uppercase" style="font-size: 0.75rem;">Estimated Budget</small>
                            <span class="fs-5 fw-bold text-dark">&#8377; <c:out value="${tender.formattedBudget}"/></span>
                        </div>
                        <div>
                            <small class="text-muted d-block text-uppercase" style="font-size: 0.75rem;">Deadline</small>
                            <span class="fs-6 fw-semibold text-secondary"><c:out value="${tender.formattedDeadline}"/></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section A: Official Award Certificate (Rendered when tender is already awarded) -->
        <c:if test="${isAwarded}">
            <div class="card award-banner shadow-sm mb-4">
                <div class="card-body p-4">
                    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-3 mb-3">
                        <div class="d-flex align-items-center gap-3">
                            <div class="fs-1 text-success">&#127942;</div>
                            <div>
                                <span class="badge bg-success text-uppercase px-3 py-1 mb-1">Contract Awarded &bull; Closed</span>
                                <h4 class="fw-bold text-dark mb-0">Official Contract Award Summary</h4>
                            </div>
                        </div>
                        <div>
                            <a href="award-certificate?tenderId=${tender.id}" class="btn btn-success px-3 py-2 shadow-sm text-nowrap">
                                &#127942; View &amp; Print Official Certificate &rarr;
                            </a>
                        </div>
                    </div>

                    <hr class="text-success my-3">

                    <div class="row g-4">
                        <div class="col-md-6">
                            <h6 class="text-muted text-uppercase small fw-bold mb-2">Awarded Vendor</h6>
                            <h5 class="fw-bold text-dark mb-1"><c:out value="${award.vendorCompanyName}"/></h5>
                            <p class="text-muted small mb-2">Registration No: <strong><c:out value="${award.vendorRegNumber}"/></strong></p>
                            <div class="p-3 bg-white rounded border">
                                <small class="text-muted d-block">Final Contract Amount</small>
                                <span class="fs-4 fw-bold text-success">&#8377; <c:out value="${award.formattedBidAmount}"/></span>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <h6 class="text-muted text-uppercase small fw-bold mb-2">Administrative Verification</h6>
                            <p class="mb-1 small"><strong>Awarded By:</strong> <c:out value="${award.awardedByName}"/> (<c:out value="${award.awardedByEmail}"/>)</p>
                            <p class="mb-2 small"><strong>Awarded Date:</strong> <c:out value="${award.formattedAwardedAt}"/></p>
                            
                            <div class="p-3 bg-white rounded border">
                                <small class="text-muted d-block fw-semibold mb-1">Award Justification &amp; Notes:</small>
                                <p class="small text-secondary mb-0">
                                    <c:choose>
                                        <c:when test="${not empty award.notes}">
                                            <c:out value="${award.notes}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <em>No specific administrative remarks recorded at the time of award.</em>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- AI Evaluation Insights & Anomaly Detector -->
        <c:if test="${not empty bids}">
            <div class="card ai-card-banner shadow-sm mb-4" id="aiBidEvalCard">
                <div class="card-body p-3">
                    <div class="d-flex flex-wrap justify-content-between align-items-center mb-2 gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <span class="fs-5">✨</span>
                            <h6 class="fw-bold mb-0 text-dark">AI Commercial Evaluation &amp; Anomaly Detector</h6>
                            <span class="badge ai-tag ms-1">AI PROCUREMENT ADVISOR</span>
                        </div>
                        <div id="aiL1StatusBadge" class="small fw-semibold text-primary"></div>
                    </div>
                    
                    <div class="row g-3 align-items-center">
                        <div class="col-lg-8">
                            <div class="p-3 bg-white rounded border shadow-sm small" id="aiEvaluationText" style="line-height: 1.5;">
                                <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                                <span class="text-muted">Analyzing commercial distribution, price variance, and outlier risk...</span>
                            </div>
                        </div>
                        <div class="col-lg-4 d-flex flex-column gap-2 justify-content-center">
                            <div id="aiAnomalyAlert"></div>
                            <c:if test="${not isAwarded}">
                                <button type="button" class="btn btn-outline-primary btn-sm py-1 shadow-sm" id="applyAiJustificationBtn" style="font-size: 0.78rem;">
                                    &#128203; Auto-fill AI Note in Award Modal
                                </button>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

        <!-- Section B: Bids Comparison Table Card -->
        <div class="card shadow-sm border-0">
            <div class="card-header bg-white py-3 border-0">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-2">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">
                            Submitted Commercial Bids
                            <span class="badge bg-secondary ms-2">${bids.size()}</span>
                        </h5>
                        <c:if test="${not isAwarded}">
                            <small class="text-muted">Compare vendor quotes and select the winning contract proposal</small>
                        </c:if>
                        <c:if test="${isAwarded}">
                            <small class="text-muted">Historical evaluation record of all submitted proposals for this tender</small>
                        </c:if>
                    </div>

                    <!-- Sorting Controls (Visible when not awarded) -->
                    <c:if test="${not isAwarded and not empty bids}">
                        <div class="d-flex align-items-center gap-2">
                            <span class="text-muted small">Sort By:</span>
                            <div class="btn-group btn-group-sm" role="group">
                                <a href="bids?tenderId=${tender.id}&sort=amount"
                                   class="btn ${sort == 'amount' ? 'btn-primary' : 'btn-outline-secondary'}">
                                    Price (Lowest First)
                                </a>
                                <a href="bids?tenderId=${tender.id}&sort=date"
                                   class="btn ${sort == 'date' ? 'btn-primary' : 'btn-outline-secondary'}">
                                    Submission Date
                                </a>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>

            <div class="card-body p-0">
                <c:choose>
                    <c:when test="${empty bids}">
                        <div class="text-center py-5">
                            <div class="mb-3 text-muted" style="font-size: 3rem;">📋</div>
                            <h5 class="fw-bold text-dark">No Bids Submitted Yet</h5>
                            <p class="text-muted small mx-auto" style="max-width: 440px;">
                                No proposals have been submitted by approved vendors for this tender yet. Once vendors submit their commercial bids, they will be listed here for side-by-side evaluation.
                            </p>
                            <a href="tenders" class="btn btn-outline-primary btn-sm mt-2">&larr; Return to Active Tenders</a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <c:if test="${not isAwarded and sort == 'amount'}">
                                            <th class="ps-4" style="width: 140px;">Procurement Rank</th>
                                        </c:if>
                                        <th class="${(not isAwarded and sort == 'amount') ? '' : 'ps-4'}">Vendor / Company</th>
                                        <th>
                                            <a href="bids?tenderId=${tender.id}&sort=amount" class="text-decoration-none text-dark">
                                                Bid Amount (&#8377;)
                                                <c:if test="${sort == 'amount'}">&uarr;</c:if>
                                            </a>
                                        </th>
                                        <th>Budget Variance</th>
                                        <th>
                                            <a href="bids?tenderId=${tender.id}&sort=date" class="text-decoration-none text-dark">
                                                Submitted Date
                                                <c:if test="${sort == 'date'}">&darr;</c:if>
                                            </a>
                                        </th>
                                        <th>Proposal</th>
                                        <th>Status</th>
                                        <c:if test="${not isAwarded}">
                                            <th class="text-end pe-4" style="width: 160px;">Action</th>
                                        </c:if>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="b" items="${bids}" varStatus="status">
                                        <tr class="${(b.status == 'AWARDED' or (not isAwarded and sort == 'amount' and status.first)) ? 'table-l1' : ''}">
                                            <c:if test="${not isAwarded and sort == 'amount'}">
                                                <td class="ps-4">
                                                    <c:choose>
                                                        <c:when test="${status.first}">
                                                            <span class="badge bg-success text-white px-2 py-1 shadow-sm">
                                                                &#9733; <c:out value="${b.rankLabel}"/>
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-light text-secondary border px-2 py-1">
                                                                <c:out value="${b.rankLabel}"/>
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </c:if>

                                            <td class="${(not isAwarded and sort == 'amount') ? '' : 'ps-4'}">
                                                <div class="fw-bold text-dark"><c:out value="${b.vendorCompanyName}"/></div>
                                                <small class="text-muted d-block">
                                                    Reg: <c:out value="${b.vendorRegNumber}"/> &bull; <c:out value="${b.vendorEmail}"/>
                                                </small>
                                            </td>

                                            <td>
                                                <span class="fs-6 fw-bold text-dark">&#8377; <c:out value="${b.formattedAmount}"/></span>
                                            </td>

                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty b.variancePercent}">
                                                        <span class="small ${b.varianceClass}">
                                                            <c:out value="${b.variancePercent}"/>
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted small">&mdash;</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <td class="small text-secondary">
                                                <c:out value="${b.formattedSubmittedAt}"/>
                                            </td>

                                            <td>
                                                <button type="button" class="btn btn-sm btn-outline-secondary"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#proposalModal"
                                                        data-vendor="<c:out value='${b.vendorCompanyName}'/>"
                                                        data-amount="&#8377; <c:out value='${b.formattedAmount}'/>"
                                                        data-proposal="<c:out value='${b.proposalText}'/>">
                                                    View Proposal
                                                </button>
                                                <c:if test="${not empty b.attachmentFilename}">
                                                    <a href="download?type=bid&id=${b.id}" class="btn btn-sm btn-outline-primary ms-1" title="Download Attached Technical Schedule">
                                                        &#128206; Schedule
                                                    </a>
                                                </c:if>
                                            </td>

                                            <td>
                                                <c:choose>
                                                    <c:when test="${b.status == 'AWARDED'}">
                                                        <span class="badge bg-success px-2 py-1">AWARDED</span>
                                                    </c:when>
                                                    <c:when test="${b.status == 'REJECTED'}">
                                                        <span class="badge bg-danger px-2 py-1">REJECTED</span>
                                                    </c:when>
                                                    <c:when test="${b.status == 'UNDER_REVIEW'}">
                                                        <span class="badge bg-warning text-dark px-2 py-1">UNDER REVIEW</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-primary px-2 py-1">SUBMITTED</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <c:if test="${not isAwarded}">
                                                <td class="text-end pe-4">
                                                    <button type="button" class="btn btn-sm btn-success px-3 fw-semibold select-winner-btn"
                                                            data-bid-id="${b.id}"
                                                            data-vendor-name="<c:out value='${b.vendorCompanyName}'/>"
                                                            data-bid-amount="<c:out value='${b.formattedAmount}'/>">
                                                        Select Winner &rarr;
                                                    </button>
                                                </td>
                                            </c:if>
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

    <!-- Award Confirmation Modal -->
    <div class="modal fade" id="awardModal" tabindex="-1" aria-labelledby="awardModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="bids" method="POST">
                    <input type="hidden" name="tenderId" value="${tender.id}">
                    <input type="hidden" name="bidId" id="awardBidId" value="">

                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title fw-bold" id="awardModalLabel">&#127942; Confirm Contract Award</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="alert alert-warning border-0 small mb-3">
                            <strong>Important Notice:</strong> Awarding a contract is a legally binding and irreversible transaction. The selected bid will be marked as <strong>AWARDED</strong>, all competing bids will be marked as <strong>REJECTED</strong>, and the tender will be changed to <strong>CLOSED</strong>.
                        </div>

                        <div class="mb-3 p-3 bg-light rounded border">
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-muted small">Winning Vendor:</span>
                                <strong id="modalVendorName" class="text-dark"></strong>
                            </div>
                            <div class="d-flex justify-content-between mb-1">
                                <span class="text-muted small">Contract Amount:</span>
                                <span class="fs-6 fw-bold text-success">&#8377; <span id="modalBidAmount"></span></span>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span class="text-muted small">Tender:</span>
                                <span class="small text-secondary"><c:out value="${tender.title}"/></span>
                            </div>
                        </div>

                        <div class="mb-2">
                            <label for="awardNotes" class="form-label small fw-semibold text-secondary">
                                Award Justification &amp; Notes (Optional):
                            </label>
                            <textarea class="form-control" id="awardNotes" name="notes" rows="3"
                                      placeholder="e.g. Lowest compliant commercial offer (L1) with proven relevant execution capabilities."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer bg-light">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-success fw-bold px-4">Confirm &amp; Award Contract</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Technical Proposal Inspection Modal -->
    <div class="modal fade" id="proposalModal" tabindex="-1" aria-labelledby="proposalModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <div>
                        <h5 class="modal-title fw-bold text-dark" id="proposalModalLabel">Technical &amp; Commercial Proposal</h5>
                        <small class="text-muted" id="modalProposalVendor"></small>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3 p-3 bg-light rounded border">
                        <span class="text-muted small">Quoted Proposal Amount:</span>
                        <span class="fs-5 fw-bold text-dark" id="modalProposalAmount"></span>
                    </div>
                    <h6 class="fw-semibold text-secondary small text-uppercase mb-2">Proposal Statement:</h6>
                    <div class="p-3 bg-white border rounded" style="min-height: 180px; max-height: 400px; overflow-y: auto; white-space: pre-wrap;" id="modalProposalContent"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Proposal Modal Population
        const proposalModal = document.getElementById('proposalModal');
        if (proposalModal) {
            proposalModal.addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget;
                const vendor = button.getAttribute('data-vendor');
                const amount = button.getAttribute('data-amount');
                const proposal = button.getAttribute('data-proposal');

                document.getElementById('modalProposalVendor').textContent = 'Submitted by ' + vendor;
                document.getElementById('modalProposalAmount').textContent = amount;
                document.getElementById('modalProposalContent').textContent = proposal || 'No proposal text submitted.';
            });
        }

        // Award Modal Population
        document.querySelectorAll('.select-winner-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const bidId = this.getAttribute('data-bid-id');
                const vendorName = this.getAttribute('data-vendor-name');
                const bidAmount = this.getAttribute('data-bid-amount');

                document.getElementById('awardBidId').value = bidId;
                document.getElementById('modalVendorName').textContent = vendorName;
                document.getElementById('modalBidAmount').textContent = bidAmount;

                const modal = new bootstrap.Modal(document.getElementById('awardModal'));
                modal.show();
            });
        });

        // AI Bid Evaluation & Anomaly Analysis
        const tenderId = '${tender.id}';
        const contextPath = '${pageContext.request.contextPath}';
        let aiSuggestedJustification = '';

        fetch(contextPath + '/api/ai?action=evaluate_bids&tenderId=' + encodeURIComponent(tenderId))
            .then(res => res.ok ? res.json() : null)
            .then(data => {
                if (!data || !data.hasBids) return;

                aiSuggestedJustification = data.suggestedJustification || '';

                const statusEl = document.getElementById('aiL1StatusBadge');
                if (statusEl && data.l1VendorName) {
                    statusEl.innerHTML = '<span class="badge bg-success me-1">L1 LEADER</span> ' + escapeHtml(data.l1VendorName) + ' (&#8377; ' + data.l1AmountFormatted + ')';
                }

                const textEl = document.getElementById('aiEvaluationText');
                if (textEl) {
                    textEl.innerHTML = '<strong>Evaluation Summary:</strong> ' + escapeHtml(data.suggestedJustification);
                }

                const alertEl = document.getElementById('aiAnomalyAlert');
                if (alertEl) {
                    if (data.hasAbnormallyLow) {
                        alertEl.innerHTML = '<span class="badge bg-danger p-2 text-wrap d-block text-start">&#9888; Warning: Abnormally low quote detected (&gt;30% below budget). Verify execution feasibility.</span>';
                    } else if (data.hasExcessive) {
                        alertEl.innerHTML = '<span class="badge bg-warning text-dark p-2 text-wrap d-block text-start">&#9888; Note: Quotes exceed estimated budget allocation.</span>';
                    } else {
                        alertEl.innerHTML = '<span class="badge bg-success-subtle text-success border border-success-subtle p-2 text-wrap d-block text-start">&#10003; Healthy commercial variance. Low execution risk.</span>';
                    }
                }
            })
            .catch(() => {});

        const applyAiBtn = document.getElementById('applyAiJustificationBtn');
        if (applyAiBtn) {
            applyAiBtn.addEventListener('click', function() {
                const notes = document.getElementById('awardNotes');
                if (notes && aiSuggestedJustification) {
                    notes.value = aiSuggestedJustification;
                    const firstBtn = document.querySelector('.select-winner-btn');
                    if (firstBtn) {
                        firstBtn.click();
                    }
                }
            });
        }

        function escapeHtml(text) {
            if (!text) return '';
            var div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>
