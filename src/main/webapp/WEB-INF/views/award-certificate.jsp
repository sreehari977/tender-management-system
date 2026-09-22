<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Official Contract Award Certificate — Tender #${tender.id}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
    <style>
        @media screen {
            .certificate-container {
                max-width: 860px;
                margin: 20px auto;
                background: #ffffff;
                box-shadow: 0 0.5rem 1.5rem rgba(0,0,0,0.12);
                border-radius: 8px;
                padding: 45px;
                border: 12px double #0d6efd;
                position: relative;
            }
        }
        @media print {
            body {
                background: #ffffff !important;
                margin: 0;
                padding: 0;
            }
            .no-print, nav, footer {
                display: none !important;
            }
            .certificate-container {
                width: 100% !important;
                max-width: 100% !important;
                margin: 0 !important;
                padding: 30px !important;
                border: 8px double #0d6efd !important;
                box-shadow: none !important;
                page-break-inside: avoid;
            }
        }
        .watermark {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-30deg);
            font-size: 6rem;
            color: rgba(13, 110, 253, 0.04);
            font-weight: 900;
            pointer-events: none;
            letter-spacing: 0.2em;
            text-transform: uppercase;
        }
    </style>
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <div class="no-print">
        <jsp:include page="/WEB-INF/includes/navbar.jsp"/>
    </div>

    <!-- Controls Bar -->
    <div class="container mb-3 no-print" style="max-width: 860px;">
        <div class="d-flex justify-content-between align-items-center bg-white p-3 rounded shadow-sm">
            <div>
                <a href="${pageContext.request.contextPath}/bids?tenderId=${tender.id}" class="btn btn-outline-secondary btn-sm">
                    &larr; Back to Evaluation Console
                </a>
            </div>
            <div class="d-flex gap-2">
                <button onclick="window.print()" class="btn btn-primary btn-sm px-4 shadow-sm fw-semibold">
                    &#128424; Print / Save as PDF
                </button>
            </div>
        </div>
    </div>

    <!-- Official Certificate Document -->
    <div class="certificate-container">
        <div class="watermark">AWARDED</div>

        <!-- Header -->
        <div class="text-center mb-4">
            <div style="font-size: 3rem; line-height: 1;">&#127942;</div>
            <span class="text-uppercase tracking-wider small fw-bold text-muted d-block mt-1">
                Central E-Procurement Authority &bull; Government of India Standards
            </span>
            <h2 class="fw-bold text-dark text-uppercase mt-2 mb-1" style="letter-spacing: 1px;">
                Certificate of Contract Award
            </h2>
            <p class="text-secondary small mb-0">
                Official Certification of Commercial Procurement Selection and Tender Award
            </p>
            <div class="d-inline-block border-bottom border-primary border-2 mt-2" style="width: 140px;"></div>
        </div>

        <!-- Formal Proclamation Statement -->
        <div class="py-2 text-center text-secondary mb-4" style="line-height: 1.8;">
            This document certifies that pursuant to competitive commercial tender evaluation conducted under
            applicable public procurement regulations, the commercial bid submitted for the procurement requirement
            specified herein has been formally reviewed, accepted, and contractually awarded.
        </div>

        <!-- Tender Specification Table -->
        <div class="card border mb-4">
            <div class="card-header bg-light py-2">
                <strong class="text-dark small text-uppercase">1. Procurement Requirement Details</strong>
            </div>
            <div class="card-body p-0">
                <table class="table table-bordered mb-0 small">
                    <tbody>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary" style="width: 25%;">Tender Title</td>
                            <td class="fw-bold text-dark"><c:out value="${tender.title}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Tender Reference ID</td>
                            <td>#TMS-TND-<c:out value="${tender.id}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Procurement Category</td>
                            <td><c:out value="${not empty tender.category ? tender.category : 'General Procurement'}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Original Estimated Budget</td>
                            <td>&#8377; <c:out value="${tender.formattedBudget}"/></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Awardee Information Table -->
        <div class="card border mb-4">
            <div class="card-header bg-light py-2">
                <strong class="text-dark small text-uppercase">2. Contract Awardee &amp; Financial Terms</strong>
            </div>
            <div class="card-body p-0">
                <table class="table table-bordered mb-0 small">
                    <tbody>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary" style="width: 25%;">Awarded Contractor</td>
                            <td class="fw-bold text-dark fs-6"><c:out value="${award.vendorCompanyName}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Corporate Registration No.</td>
                            <td class="fw-semibold text-primary"><c:out value="${award.vendorRegNumber}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Winning Bid Reference</td>
                            <td>Bid #<c:out value="${award.bidId}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Total Contract Value</td>
                            <td class="fw-bold fs-5 text-success">&#8377; <c:out value="${award.formattedBidAmount}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Date of Award</td>
                            <td><c:out value="${award.formattedAwardedAt}"/></td>
                        </tr>
                        <tr>
                            <td class="bg-light fw-semibold text-secondary">Official Justification</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty award.notes}">
                                        <c:out value="${award.notes}"/>
                                    </c:when>
                                    <c:otherwise>
                                        <em>Lowest conforming responsive commercial offer satisfying all qualification criteria (L1).</em>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Signatory Endorsements -->
        <div class="row pt-4 mt-4 border-top">
            <div class="col-6 text-center">
                <div class="border-bottom border-dark mx-auto mb-2" style="width: 180px; height: 40px;"></div>
                <strong class="d-block small text-dark"><c:out value="${award.awardedByName}"/></strong>
                <span class="text-muted small d-block">Authorized Procurement Officer</span>
                <span class="text-muted" style="font-size: 0.75rem;">Executive Procurement Authority</span>
            </div>
            <div class="col-6 text-center">
                <div class="border-bottom border-dark mx-auto mb-2" style="width: 180px; height: 40px;"></div>
                <strong class="d-block small text-dark"><c:out value="${award.vendorCompanyName}"/></strong>
                <span class="text-muted small d-block">Contractor Representative Signatory</span>
                <span class="text-muted" style="font-size: 0.75rem;">Reg: <c:out value="${award.vendorRegNumber}"/></span>
            </div>
        </div>

        <!-- Security Hash & Document Timestamp Footer -->
        <div class="mt-4 pt-3 border-top text-center text-muted" style="font-size: 0.75rem;">
            Security Audit ID: TMS-AWD-${award.id}-${award.tenderId} &bull; Validated via Cryptographic Procurement Audit Log &bull; Generated on <c:out value="${award.formattedAwardedAt}"/>
        </div>
    </div>

    <!-- Footer -->
    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small no-print">
        &copy; 2026 Tender Management System &bull; Official Procurement Certification System
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
