<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Submit Bid — <c:out value="${tender.title}"/></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/includes/navbar.jsp">
        <jsp:param name="activeNav" value="tenders"/>
    </jsp:include>

    <div class="container py-3" style="max-width: 800px;">
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="tenders" class="text-decoration-none">&larr; Active Tenders</a></li>
                <li class="breadcrumb-item"><a href="tender?id=${tender.id}" class="text-decoration-none">Tender Details</a></li>
                <li class="breadcrumb-item active" aria-current="page">Submit Bid</li>
            </ol>
        </nav>

        <!-- Tender Context Summary Card -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="card-body p-4 bg-white rounded">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="badge bg-secondary mb-2"><c:out value="${not empty tender.category ? tender.category : 'General'}"/></span>
                        <h4 class="fw-bold mb-1 text-dark"><c:out value="${tender.title}"/></h4>
                        <small class="text-muted">Tender ID: #<c:out value="${tender.id}"/></small>
                    </div>
                    <div class="text-end">
                        <span class="badge bg-success px-3 py-2">PUBLISHED</span>
                    </div>
                </div>

                <div class="row g-3 mt-2 pt-2 border-top">
                    <div class="col-sm-6">
                        <small class="text-muted d-block">Estimated Budget</small>
                        <span class="fw-bold text-dark fs-5">&#8377; <c:out value="${tender.formattedBudget}"/></span>
                    </div>
                    <div class="col-sm-6">
                        <small class="text-muted d-block">Submission Deadline</small>
                        <span class="fw-semibold text-dark"><c:out value="${tender.formattedDeadline}"/></span>
                        <c:if test="${not empty tender.timeRemaining}">
                            <span class="badge bg-info text-dark ms-1"><c:out value="${tender.timeRemaining}"/></span>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bid Submission Form Card -->
        <div class="card shadow-sm border-0">
            <div class="card-body p-4">
                <h5 class="card-title fw-bold mb-1">Your Commercial Bid & Proposal</h5>
                <p class="text-muted small mb-4">Submit your formal price quote and execution proposal for this project.</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2 mb-3">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <form action="bid" method="post" enctype="multipart/form-data" id="bidForm">
                    <input type="hidden" name="tenderId" value="${tender.id}">

                    <!-- Bid Amount with Real-time Benchmark Analysis -->
                    <div class="mb-4">
                        <label class="form-label fw-semibold">
                            Bid Amount (&#8377;) <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text fw-bold">&#8377;</span>
                            <input type="number" step="0.01" min="0.01" name="amount" id="amountInput"
                                   class="form-control form-control-lg"
                                   placeholder="e.g. 2400000.00"
                                   value="<c:out value='${inputAmount}'/>"
                                   data-budget="${tender.estimatedBudget}"
                                   required>
                        </div>
                        <div id="budgetFeedback" class="form-text mt-2" style="display: none;"></div>
                    </div>

                    <!-- Proposal Text with Template Helper, AI Drafter, and Quality Meter -->
                    <div class="mb-4">
                        <div class="d-flex flex-wrap justify-content-between align-items-center mb-1 gap-2">
                            <label class="form-label fw-semibold mb-0">
                                Detailed Technical Proposal & Scope <span class="text-danger">*</span>
                            </label>
                            <div class="d-flex gap-2">
                                <button type="button" class="btn btn-sm btn-outline-secondary py-0" id="insertTemplateBtn">
                                    + Basic Template
                                </button>
                                <button type="button" class="btn btn-sm btn-gradient-ai py-0 px-2 fw-semibold" id="aiDraftBtn">
                                    ✨ AI Auto-Draft Proposal
                                </button>
                            </div>
                        </div>
                        <textarea name="proposalText" id="proposalInput" rows="8" class="form-control"
                                  placeholder="Outline your execution methodology, staffing, key milestones, materials, and compliance with the tender specifications..."
                                  required><c:out value='${inputProposal}'/></textarea>
                        <div class="d-flex justify-content-between text-muted small mt-1">
                            <span>Be thorough: proposals are evaluated for technical competency and deliverables.</span>
                            <span id="charCount">0 characters</span>
                        </div>

                        <!-- AI Proposal Strength Meter -->
                        <div class="card ai-card-banner mt-3 p-3 shadow-sm border" id="aiStrengthCard">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="fs-6">✨</span>
                                    <span class="fw-bold small text-dark">AI Proposal Quality &amp; Compliance Score</span>
                                    <span class="badge bg-secondary" id="aiScoreBadge">0% - INSUFFICIENT</span>
                                </div>
                                <button type="button" class="btn btn-link btn-sm p-0 text-decoration-none fw-semibold" id="reanalyzeBtn" style="font-size: 0.75rem;">
                                    Re-score
                                </button>
                            </div>
                            <div class="progress mb-2" style="height: 8px;">
                                <div class="progress-bar bg-danger" id="aiProgressBar" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <div class="row g-2 mt-1" id="aiFeedbackRow">
                                <div class="col-md-6">
                                    <div class="small fw-semibold text-success mb-1" id="aiStrengthsHeading" style="display:none;">Strengths Identified:</div>
                                    <ul class="list-unstyled mb-0" id="aiStrengthsList"></ul>
                                </div>
                                <div class="col-md-6">
                                    <div class="small fw-semibold text-warning-emphasis mb-1" id="aiImprovementsHeading" style="display:none;">Recommendations to Improve:</div>
                                    <ul class="list-unstyled mb-0" id="aiImprovementsList"></ul>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Technical Document Attachment (Optional) -->
                    <div class="mb-4">
                        <label class="form-label fw-semibold">
                            Technical Schedule / Cost Breakdown Document (Optional)
                        </label>
                        <input type="file" name="attachment" class="form-control" accept=".pdf,.doc,.docx,.zip,.xlsx,.csv">
                        <div class="form-text text-muted">Attach detailed financial spreadsheets, architecture blueprints, or company compliance portfolios (PDF, Word, Excel, ZIP; max 10MB).</div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="d-flex align-items-center justify-content-between pt-2">
                        <a href="tender?id=${tender.id}" class="btn btn-outline-secondary px-3">Cancel</a>
                        <button type="submit" class="btn btn-success px-4 py-2 fw-semibold">
                            Confirm & Submit Bid
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        const amountInput = document.getElementById('amountInput');
        const budgetFeedback = document.getElementById('budgetFeedback');
        const proposalInput = document.getElementById('proposalInput');
        const charCount = document.getElementById('charCount');
        const insertTemplateBtn = document.getElementById('insertTemplateBtn');

        const estimatedBudget = parseFloat(amountInput.dataset.budget);

        function updateBudgetAnalysis() {
            const val = parseFloat(amountInput.value);
            if (!isNaN(val) && val > 0 && !isNaN(estimatedBudget) && estimatedBudget > 0) {
                const diff = val - estimatedBudget;
                const percent = Math.abs((diff / estimatedBudget) * 100).toFixed(1);
                budgetFeedback.style.display = 'block';

                if (diff < 0) {
                    budgetFeedback.innerHTML = '<span class="badge bg-success-subtle text-success border border-success-subtle px-2 py-1">' +
                        percent + '% below estimated budget (Cost Competitive)</span>';
                } else if (diff > 0) {
                    budgetFeedback.innerHTML = '<span class="badge bg-warning-subtle text-warning-emphasis border border-warning-subtle px-2 py-1">' +
                        percent + '% above estimated budget (Premium Pricing)</span>';
                } else {
                    budgetFeedback.innerHTML = '<span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">Exactly matches estimated budget</span>';
                }
            } else {
                budgetFeedback.style.display = 'none';
            }
        }

        function updateCharCount() {
            const length = proposalInput.value.length;
            const words = proposalInput.value.trim() ? proposalInput.value.trim().split(/\s+/).length : 0;
            charCount.textContent = length + ' characters (' + words + ' words)';
        }

        insertTemplateBtn.addEventListener('click', function() {
            const template = "1. Executive Summary:\n" +
                "- Brief overview of our capability and proposed solution.\n\n" +
                "2. Technical Approach & Methodology:\n" +
                "- Key steps to execute the scope of work according to specifications.\n\n" +
                "3. Work Schedule & Timeline:\n" +
                "- Estimated completion time and key milestone deliverables.\n\n" +
                "4. Team & Resources:\n" +
                "- Qualified personnel and equipment deployed.\n\n" +
                "5. Pricing & Warranty:\n" +
                "- Price justification and post-completion warranty commitment.";

            if (proposalInput.value.trim() === '' || confirm('Replace current text with structured template?')) {
                proposalInput.value = template;
                updateCharCount();
            }
        });

        amountInput.addEventListener('input', updateBudgetAnalysis);
        proposalInput.addEventListener('input', updateCharCount);

        // Initial triggers on load if values exist
        updateBudgetAnalysis();
        updateCharCount();

        // AI Proposal Drafting & Real-time Quality Scoring
        const aiDraftBtn = document.getElementById('aiDraftBtn');
        const tenderId = '${tender.id}';
        const contextPath = '${pageContext.request.contextPath}';

        if (aiDraftBtn) {
            aiDraftBtn.addEventListener('click', function() {
                if (proposalInput.value.trim() !== '' && !confirm('Generate new AI tailored proposal? Existing text will be replaced.')) {
                    return;
                }
                const originalText = aiDraftBtn.innerHTML;
                aiDraftBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Generating...';
                aiDraftBtn.disabled = true;

                const formData = new URLSearchParams();
                formData.append('action', 'draft_proposal');
                formData.append('tenderId', tenderId);

                fetch(contextPath + '/api/ai', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData.toString()
                })
                .then(res => res.json())
                .then(data => {
                    aiDraftBtn.innerHTML = originalText;
                    aiDraftBtn.disabled = false;
                    if (data && data.draft) {
                        proposalInput.value = data.draft;
                        updateCharCount();
                        analyzeProposalStrength();
                    }
                })
                .catch(() => {
                    aiDraftBtn.innerHTML = originalText;
                    aiDraftBtn.disabled = false;
                    alert('Unable to generate AI draft at this moment.');
                });
            });
        }

        let analyzeTimeout = null;
        function debouncedAnalyzeStrength() {
            clearTimeout(analyzeTimeout);
            analyzeTimeout = setTimeout(analyzeProposalStrength, 500);
        }

        function analyzeProposalStrength() {
            const text = proposalInput.value;
            const amount = amountInput.value;

            const formData = new URLSearchParams();
            formData.append('action', 'analyze_proposal');
            formData.append('tenderId', tenderId);
            formData.append('proposalText', text);
            formData.append('amount', amount);

            fetch(contextPath + '/api/ai', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (!data) return;
                const score = data.score || 0;
                const grade = data.grade || 'INSUFFICIENT';

                const badge = document.getElementById('aiScoreBadge');
                badge.textContent = score + '% - ' + grade;

                const pBar = document.getElementById('aiProgressBar');
                pBar.style.width = score + '%';
                pBar.setAttribute('aria-valuenow', score);

                pBar.className = 'progress-bar';
                if (score >= 80) {
                    pBar.classList.add('bg-success');
                    badge.className = 'badge bg-success';
                } else if (score >= 50) {
                    pBar.classList.add('bg-warning');
                    badge.className = 'badge bg-warning text-dark';
                } else {
                    pBar.classList.add('bg-danger');
                    badge.className = 'badge bg-danger';
                }

                const sList = document.getElementById('aiStrengthsList');
                const sHead = document.getElementById('aiStrengthsHeading');
                sList.innerHTML = '';
                if (data.strengths && data.strengths.length > 0) {
                    sHead.style.display = 'block';
                    data.strengths.forEach(s => {
                        const li = document.createElement('li');
                        li.className = 'small text-secondary mb-1 d-flex align-items-start gap-1';
                        li.style.fontSize = '0.75rem';
                        li.innerHTML = '<span class="text-success fw-bold">&#10003;</span><span>' + s + '</span>';
                        sList.appendChild(li);
                    });
                } else {
                    sHead.style.display = 'none';
                }

                const iList = document.getElementById('aiImprovementsList');
                const iHead = document.getElementById('aiImprovementsHeading');
                iList.innerHTML = '';
                if (data.improvements && data.improvements.length > 0) {
                    iHead.style.display = 'block';
                    data.improvements.forEach(imp => {
                        const li = document.createElement('li');
                        li.className = 'small text-secondary mb-1 d-flex align-items-start gap-1';
                        li.style.fontSize = '0.75rem';
                        li.innerHTML = '<span class="text-warning-emphasis fw-bold">&#9888;</span><span>' + imp + '</span>';
                        iList.appendChild(li);
                    });
                } else {
                    iHead.style.display = 'none';
                }
            })
            .catch(() => {});
        }

        proposalInput.addEventListener('input', debouncedAnalyzeStrength);
        amountInput.addEventListener('input', debouncedAnalyzeStrength);

        const reanalyzeBtn = document.getElementById('reanalyzeBtn');
        if (reanalyzeBtn) {
            reanalyzeBtn.addEventListener('click', analyzeProposalStrength);
        }

        analyzeProposalStrength();
    </script>
</body>
</html>
