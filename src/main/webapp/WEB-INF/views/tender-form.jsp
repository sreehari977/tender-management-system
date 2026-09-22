<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${not empty tender && tender.id > 0 ? "Edit Tender" : "Create Tender"} — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/includes/navbar.jsp"/>

    <div class="container py-3" style="max-width: 720px;">
        <div class="card shadow-sm border-0">
            <div class="card-body p-4">
                <h4 class="card-title mb-1">${not empty tender && tender.id > 0 ? "Edit Tender" : "Create New Tender"}</h4>
                <p class="text-muted small mb-4">Provide tender details and schedule below</p>

                <c:if test="${not empty error}">
                    <div class="alert alert-danger py-2 mb-3">
                        <c:out value="${error}"/>
                    </div>
                </c:if>

                <form action="tender-form" method="post" enctype="multipart/form-data">
                    <c:if test="${not empty tender && tender.id > 0}">
                        <input type="hidden" name="id" value="${tender.id}">
                    </c:if>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Tender Title <span class="text-danger">*</span></label>
                        <input type="text" name="title" class="form-control" placeholder="e.g. Construction of Public Library" value="<c:out value='${tender.title}'/>" required>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Category</label>
                            <input type="text" name="category" class="form-control" placeholder="e.g. Civil Works, IT Procurement" value="<c:out value='${tender.category}'/>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Estimated Budget (&#8377;)</label>
                            <input type="number" step="0.01" min="0" name="estimatedBudget" class="form-control" placeholder="e.g. 2500000.00" value="<c:out value='${not empty inputBudget ? inputBudget : tender.estimatedBudget}'/>">
                        </div>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Submission Deadline <span class="text-danger">*</span></label>
                            <input type="datetime-local" name="deadline" class="form-control" value="<c:out value='${not empty inputDeadline ? inputDeadline : tender.deadlineForInput}'/>" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Status</label>
                            <select name="status" class="form-select">
                                <option value="DRAFT" ${tender.status == 'DRAFT' ? 'selected' : ''}>DRAFT</option>
                                <option value="PUBLISHED" ${tender == null || tender.status == 'PUBLISHED' ? 'selected' : ''}>PUBLISHED</option>
                                <option value="CLOSED" ${tender.status == 'CLOSED' ? 'selected' : ''}>CLOSED</option>
                                <option value="ARCHIVED" ${tender.status == 'ARCHIVED' ? 'selected' : ''}>ARCHIVED</option>
                            </select>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label fw-semibold">Description & Scope of Work <span class="text-danger">*</span></label>
                        <textarea name="description" class="form-control" rows="5" placeholder="Detailed technical specifications, requirements, and deliverables..." required><c:out value='${tender.description}'/></textarea>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-semibold">Tender Specification / RFP Document (Optional)</label>
                        <input type="file" name="attachment" class="form-control" accept=".pdf,.doc,.docx,.zip,.xlsx,.csv">
                        <c:if test="${not empty tender.attachmentFilename}">
                            <div class="form-text text-success d-flex align-items-center gap-1 mt-1">
                                <span>&#10004; Current Document:</span>
                                <strong><c:out value="${tender.attachmentFilename}"/></strong> 
                                <span>(Uploading a new file replaces this document)</span>
                            </div>
                        </c:if>
                        <div class="form-text text-muted">Allowed formats: PDF, Word, Excel, CSV, ZIP (Max 10MB).</div>
                    </div>

                    <div class="d-flex align-items-center">
                        <button type="submit" class="btn btn-primary px-4 py-2">
                            ${not empty tender && tender.id > 0 ? "Save Changes" : "Create Tender"}
                        </button>
                        <a href="tenders" class="btn btn-outline-secondary ms-2 py-2">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
