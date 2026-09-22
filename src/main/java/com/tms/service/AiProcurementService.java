package com.tms.service;

import com.tms.model.Bid;
import com.tms.model.Tender;
import com.tms.model.Vendor;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

public class AiProcurementService {

    /**
     * Contextual Page Familiarization Guide
     */
    public Map<String, Object> getPageGuide(String page, String role, String contextName) {
        Map<String, Object> guide = new LinkedHashMap<>();
        List<String> capabilities = new ArrayList<>();
        List<String> tips = new ArrayList<>();
        List<String> promptPills = new ArrayList<>();

        String pageTitle;
        String overview;

        if (page == null) page = "dashboard";

        switch (page.toLowerCase()) {
            case "dashboard":
                pageTitle = "Executive Procurement Dashboard";
                overview = "Central control hub providing executive telemetry across tenders, vendor applications, commercial quotes, and public expenditures.";
                capabilities.add("Monitor system-wide tender lifecycles (Draft, Published, Closed, Awarded).");
                capabilities.add("Track real-time fiscal commitments and total contracted procurement values.");
                capabilities.add("Audit pending vendor applications with immediate review badges.");
                capabilities.add("Access recently published tenders with one-click administrative actions.");
                tips.add("Review pending vendor approvals promptly to ensure competitive bidding pools.");
                tips.add("Keep published tender deadlines up to date to avoid late procurement cycles.");
                promptPills.add("How do I publish a new tender?");
                promptPills.add("What do the KPI metrics represent?");
                promptPills.add("How does the approval workflow operate?");
                break;

            case "tenders":
                pageTitle = "Tender Directory & Public Catalog";
                overview = "The master registry of government and enterprise procurement opportunities. Filter, search, and inspect active requests for proposals (RFPs).";
                capabilities.add("Perform multi-criteria searches by keyword, category, and minimum/maximum budget.");
                capabilities.add("Sort procurement listings by deadline urgency, budget scale, or release date.");
                capabilities.add("Download technical specifications and RFP documentation directly from list rows.");
                if ("ADMIN".equalsIgnoreCase(role)) {
                    capabilities.add("Launch new tenders via '+ Create Tender' and modify drafts.");
                } else {
                    capabilities.add("Approved vendors can open any published tender to prepare commercial bids.");
                }
                tips.add("Filter by your domain category to quickly identify high-relevance bidding opportunities.");
                tips.add("Check the deadline countdown badge to ensure timely proposal submission.");
                promptPills.add("How do I filter by budget range?");
                promptPills.add("Can I bid if my status is Pending?");
                promptPills.add("Where do I find technical RFP files?");
                break;

            case "tender-detail":
                pageTitle = "Tender Specification & Scope Dossier";
                overview = "Comprehensive tender dossier detailing scope of work, technical specifications, timelines, commercial benchmarks, and attachment downloads.";
                capabilities.add("Examine complete scope of work and technical deliverables.");
                capabilities.add("Download official RFP attachments and engineering specifications.");
                capabilities.add("Review temporal deadline countdown and commercial budget benchmarks.");
                if ("ADMIN".equalsIgnoreCase(role)) {
                    capabilities.add("Manage tender lifecycle, edit terms, or jump straight to Bid Evaluation.");
                } else {
                    capabilities.add("Approved vendors can click 'Submit Bid' to enter commercial proposals.");
                }
                tips.add("Review the AI Executive Summary on this page for a 30-second brief of key deliverables.");
                tips.add("Ensure your company meets all technical specifications before submitting commercial numbers.");
                promptPills.add("Summarize this tender scope");
                promptPills.add("What are the key technical deliverables?");
                promptPills.add("What documents must be submitted?");
                break;

            case "bid-form":
                pageTitle = "Commercial & Technical Bid Submission";
                overview = "Secure bidding interface where approved contractors lodge sealed commercial quotes and technical proposals.";
                capabilities.add("Enter commercial bid amount with real-time budget variance calculation.");
                capabilities.add("Submit technical methodology, execution schedules, and milestone delivery plans.");
                capabilities.add("Upload supporting technical drawings, certifications, or PDF bid packs.");
                capabilities.add("Use AI Proposal Assistant to draft or score proposal completeness.");
                tips.add("Aim for an AI Proposal Strength Score above 80% to ensure competitive compliance.");
                tips.add("Remember: Each vendor is restricted to a single bid per tender. Ensure accuracy before lodging.");
                promptPills.add("Draft a winning proposal for this tender");
                promptPills.add("How does budget variance affect evaluation?");
                promptPills.add("What file formats are accepted?");
                break;

            case "my-bids":
                pageTitle = "Vendor Bidding Ledger & Submissions";
                overview = "Vendor portfolio tracker monitoring the status, evaluation stage, and contract award outcome of all submitted proposals.";
                capabilities.add("Review status badges (Submitted, Under Review, Awarded, Rejected).");
                capabilities.add("Inspect full technical proposals previously lodged via the popup modal.");
                capabilities.add("View and print the Official Contract Award Certificate for winning bids.");
                tips.add("If awarded, print your official procurement contract certificate immediately for legal onboarding.");
                tips.add("Track active tenders to discover upcoming procurement opportunities.");
                promptPills.add("When are winning bids finalized?");
                promptPills.add("How do I download my award certificate?");
                promptPills.add("Can I modify a submitted bid?");
                break;

            case "bid-comparison":
                pageTitle = "Commercial Bid Evaluation & Award Tribunal";
                overview = "Administrative decision console for evaluating competing bids, inspecting proposals, calculating L1 ranks, and finalizing contract awards.";
                capabilities.add("Automatically identify L1 (Lowest Compliant Bidder) with dynamic ranking badges.");
                capabilities.add("Calculate commercial deviation and budgetary variance percentages.");
                capabilities.add("Inspect vendor technical proposals and downloaded attachments.");
                capabilities.add("Execute atomic contract award transaction closing tender and generating legal certificate.");
                tips.add("Check AI Anomaly Detector alerts before awarding to ensure the quote is not unsustainably low.");
                tips.add("Contract awards are permanent and legally binding; review justification notes thoroughly.");
                promptPills.add("What is the L1 procurement rule?");
                promptPills.add("How do I detect predatory pricing?");
                promptPills.add("What happens when I award a contract?");
                break;

            case "vendor-approvals":
                pageTitle = "Vendor Credential Verification Queue";
                overview = "Administrative compliance checkpoint reviewing corporate registrations, tax identifiers, and legal credentials before granting bidding access.";
                capabilities.add("Review business entity details, registration numbers, and contact credentials.");
                capabilities.add("Approve qualified vendors to grant immediate tender bidding privileges.");
                capabilities.add("Reject non-compliant applicants with automated audit trail logging.");
                tips.add("Verify corporate registration numbers against government registries prior to approval.");
                promptPills.add("What credentials are required for approval?");
                promptPills.add("Does rejecting a vendor notify them?");
                break;

            case "audit-logs":
                pageTitle = "Compliance Audit & Governance Trail";
                overview = "Immutable chronologic ledger recording all mission-critical events across the procurement system for statutory compliance.";
                capabilities.add("Inspect chronological timeline of tender releases, bid lodgments, and contract awards.");
                capabilities.add("Filter audit records by specific action categories.");
                capabilities.add("Verify actor identity, user ID, and timestamp stamps for compliance audits.");
                tips.add("Export or review audit entries periodically to ensure adherence to statutory procurement guidelines.");
                promptPills.add("Which actions are recorded in audit logs?");
                promptPills.add("Are audit records immutable?");
                break;

            case "signup":
            case "register":
                pageTitle = "Vendor Registration & Enterprise Onboarding";
                overview = "Official enterprise onboarding portal for prospective contractors to establish verified procurement credentials.";
                capabilities.add("Submit legal entity name, corporate registration number (CIN/GST), and contact credentials.");
                capabilities.add("Automatic verification of email uniqueness and business registration identifiers.");
                capabilities.add("Direct placement into the administrative compliance verification queue.");
                tips.add("Ensure your registered business entity matches government tax/CIN records exactly.");
                tips.add("Accounts are activated promptly once administrators verify credentials.");
                promptPills.add("What credentials do I need to register?");
                promptPills.add("How long does account approval take?");
                promptPills.add("Can I submit bids immediately after signup?");
                break;

            default:
                pageTitle = "Tender Management Platform";
                overview = "Enterprise procurement system facilitating transparent, competitive, and audited public and commercial tendering.";
                capabilities.add("Explore open tenders and procurement solicitations.");
                capabilities.add("Participate in competitive bidding under transparent L1 evaluation.");
                tips.add("Use the top navigation bar to access relevant procurement modules.");
                promptPills.add("How do I get started?");
                promptPills.add("Who can participate in tenders?");
                break;
        }

        guide.put("page", page);
        guide.put("title", pageTitle);
        guide.put("overview", overview);
        guide.put("capabilities", capabilities);
        guide.put("tips", tips);
        guide.put("quickPrompts", promptPills);

        return guide;
    }

    /**
     * Natural Language Q&A Engine for Procurement Assistance
     */
    public Map<String, Object> answerQuery(String query, String page, String role) {
        Map<String, Object> result = new LinkedHashMap<>();
        if (query == null || query.trim().isEmpty()) {
            result.put("answer", "Please ask any question about the procurement process, platform features, or compliance guidelines.");
            return result;
        }

        String q = query.toLowerCase().trim();
        String answer;
        String topic = "General Assistance";

        if (q.contains("l1") || q.contains("lowest bidder") || q.contains("how is winner") || q.contains("evaluation")) {
            topic = "L1 Evaluation Standard";
            answer = "**L1 Evaluation Rule:** In standard public and enterprise procurement, the contract is awarded to the **Lowest Compliant Bidder (L1)** whose technical proposal meets all minimum mandatory criteria specified in the RFP. TMS automatically computes and badges the L1 vendor in green on the bid comparison screen along with the budget variance percentage.";
        } else if (q.contains("deadline") || q.contains("late") || q.contains("expired") || q.contains("passed")) {
            topic = "Submission Deadlines";
            answer = "**Submission Deadlines:** Tenders strictly enforce deadlines. Once the deadline timestamp is reached, the system automatically transitions the tender status to Closed and rejects any further bid submissions. The platform re-verifies the deadline on the server at submission time to maintain fairness.";
        } else if (q.contains("change bid") || q.contains("modify bid") || q.contains("edit bid") || q.contains("retract") || q.contains("second bid")) {
            topic = "Bid Modifiability & Immutability";
            answer = "**One-Bid Policy:** To prevent bid tampering, price-sniping, and market manipulation, TMS enforces a strict single-submission policy per vendor per tender (governed by a database unique constraint). Ensure your commercial quote and technical proposal are thoroughly verified before lodging.";
        } else if (q.contains("certificate") || q.contains("award certificate") || q.contains("proof of award")) {
            topic = "Official Contract Award Certificate";
            answer = "**Contract Award Certificate:** Once an administrator finalizes an award on `/bids`, an official printable legal contract certificate (`/award-certificate?tenderId=X`) is generated. It includes a security watermark, official procurement reference number, contractor registration, officer signatures, and `@media print` styling for PDF export. Only the winning vendor and admins can access it.";
        } else if (q.contains("approval") || q.contains("pending") || q.contains("register") || q.contains("become vendor") || q.contains("signup")) {
            topic = "Vendor Approval Lifecycle";
            answer = "**Vendor Onboarding:** New vendors register at `/signup` (or `/signup.jsp`) and default to `PENDING` approval status. Administrators review corporate registrations and tax identifiers on the `/vendor-approvals` queue before granting active bidding privileges. Bidding is restricted until approved.";
        } else if (q.contains("file") || q.contains("attachment") || q.contains("upload") || q.contains("format") || q.contains("pdf")) {
            topic = "Document Attachments & Security";
            answer = "**Document Attachments:** The system supports `.pdf`, `.doc`, `.docx`, `.zip`, `.xlsx`, and `.csv` files up to 10 MB. All uploads undergo UUID obfuscation and path-traversal sanitation. Competitor bid attachments are private and protected by HTTP 403 authorization barriers.";
        } else if (q.contains("predatory") || q.contains("anomaly") || q.contains("abnormally low") || q.contains("unusually low")) {
            topic = "Bid Risk & Outlier Detection";
            answer = "**Abnormally Low Bids:** Bids quoted more than 25–30% below the estimated budget are flagged as potential risks. Such quotes may signal misunderstanding of scope, cut-corner materials, or contractor abandonment risk. The AI Evaluation Insights panel highlights these outliers for administrative scrutiny.";
        } else if (q.contains("audit") || q.contains("log") || q.contains("compliance") || q.contains("transparency")) {
            topic = "Statutory Audit Trail";
            answer = "**Audit Compliance:** All critical state changes (vendor approval/rejection, tender release, bid submission, and contract awarding) are logged to the immutable `audit_logs` table with actor user IDs and precision timestamps, accessible to admins at `/audit-logs`.";
        } else if (q.contains("notification") || q.contains("bell") || q.contains("alert")) {
            topic = "Real-time Notification Center";
            answer = "**Notification Center:** The top navbar notification bell streams real-time procurement alerts. You receive automated notifications when new tenders in your category are released, when your vendor account is approved, or when a contract award is decided on your bids.";
        } else {
            topic = "Contextual Guidance";
            answer = "The Tender Management System is designed for transparent procurement governance. If you are a **Vendor**, you can browse open tenders on `/tenders`, review specifications, and submit bids. If you are an **Administrator**, you manage tenders, verify vendors, and award contracts on `/dashboard` and `/bids`.";
        }

        result.put("topic", topic);
        result.put("answer", answer);
        result.put("page", page);
        return result;
    }

    /**
     * AI Tender RFP Summarizer & Key Requirements Extractor
     */
    public Map<String, Object> summarizeTender(Tender t) {
        Map<String, Object> summary = new LinkedHashMap<>();
        if (t == null) return summary;

        String title = t.getTitle();
        String desc = t.getDescription() != null ? t.getDescription() : "";
        String cat = t.getCategory() != null ? t.getCategory() : "General";
        BigDecimal budget = t.getEstimatedBudget() != null ? t.getEstimatedBudget() : BigDecimal.ZERO;

        // Executive Synthesis
        String executiveSummary = "This procurement solicitation covers " + title + " under the " + cat +
                " sector with an estimated allocation of INR " + formatCurrency(budget) +
                ". The contractor will be responsible for turnkey execution, regulatory compliance, quality validation, and final handover.";

        // Deliverables Extraction
        List<String> deliverables = new ArrayList<>();
        if (cat.toLowerCase().contains("it") || cat.toLowerCase().contains("software") || desc.toLowerCase().contains("software") || desc.toLowerCase().contains("fiber")) {
            deliverables.add("Architecture design, technical blueprinting, and Bill of Materials (BOM) signoff.");
            deliverables.add("Deployment of enterprise infrastructure with high availability and redundancy.");
            deliverables.add("Integration testing, vulnerability assessment, and penetration testing (VAPT).");
            deliverables.add("User acceptance testing (UAT) and comprehensive operations training.");
            deliverables.add("24/7 technical support and warranty SLA covering 36 months.");
        } else if (cat.toLowerCase().contains("solar") || cat.toLowerCase().contains("power") || cat.toLowerCase().contains("energy")) {
            deliverables.add("Site structural feasibility survey and photovoltaic grid design approval.");
            deliverables.add("Supply, mounting, and cabling of Tier-1 solar photovoltaic panels and inverters.");
            deliverables.add("Grid synchronization, net-metering setup, and statutory electricity board approvals.");
            deliverables.add("Performance ratio (PR) testing and 5-year comprehensive operation & maintenance (O&M).");
        } else if (cat.toLowerCase().contains("civil") || cat.toLowerCase().contains("construction") || desc.toLowerCase().contains("construction")) {
            deliverables.add("Soil testing, site clearing, and structural engineering foundation work.");
            deliverables.add("Reinforced concrete framing in compliance with National Building Code (NBC).");
            deliverables.add("Quality material testing reports for cement, aggregate, and reinforcement steel.");
            deliverables.add("Architectural finishing, plumbing, fire safety compliance, and occupancy clearance.");
            deliverables.add("Defect Liability Period (DLP) maintenance warranty for a minimum of 24 months.");
        } else {
            deliverables.add("Comprehensive technical mobilization and site deployment plan.");
            deliverables.add("Execution of core scope deliverables strictly adhering to RFP standards.");
            deliverables.add("Quality control inspections and milestone signoff reports.");
            deliverables.add("Post-execution maintenance, handover dossier, and operational warranty.");
        }

        // Risk Classification
        String riskLevel = "LOW";
        String riskRationale = "Standard scope with manageable execution timelines and well-defined commercial parameters.";
        if (budget.compareTo(new BigDecimal("10000000")) > 0) {
            riskLevel = "HIGH";
            riskRationale = "Capital expenditure exceeds INR 1 Crore; demands stringent technical qualification, bank guarantees, and multi-stage milestone tracking.";
        } else if (budget.compareTo(new BigDecimal("3000000")) > 0) {
            riskLevel = "MEDIUM";
            riskRationale = "Substantial commercial value requiring verified past performance, safety certifications, and audited milestone deliverables.";
        }

        // Key Qualifications Checklist
        List<String> qualifications = new ArrayList<>();
        qualifications.add("Valid GST registration and active corporate incorporation in good standing.");
        qualifications.add("Minimum 3 years demonstrable past performance in " + cat + " projects.");
        qualifications.add("ISO 9001:2015 Quality Management certification or sector-specific equivalent.");
        qualifications.add("Solvency certificate and technical staff commitment letter.");

        summary.put("tenderId", t.getId());
        summary.put("title", title);
        summary.put("executiveSummary", executiveSummary);
        summary.put("deliverables", deliverables);
        summary.put("riskLevel", riskLevel);
        summary.put("riskRationale", riskRationale);
        summary.put("qualifications", qualifications);
        summary.put("category", cat);
        summary.put("budgetFormatted", formatCurrency(budget));

        return summary;
    }

    /**
     * AI Proposal Generator / Smart Drafter
     */
    public String draftProposal(Tender t, Vendor v) {
        String company = (v != null && v.getCompanyName() != null) ? v.getCompanyName() : "Our Enterprise";
        String title = (t != null) ? t.getTitle() : "Government Procurement Project";
        String cat = (t != null && t.getCategory() != null) ? t.getCategory() : "Commercial Works";
        BigDecimal budget = (t != null && t.getEstimatedBudget() != null) ? t.getEstimatedBudget() : BigDecimal.ZERO;

        StringBuilder sb = new StringBuilder();
        sb.append("1. EXECUTIVE OVERVIEW & UNDERSTANDING OF SCOPE:\n");
        sb.append(company).append(" is pleased to submit this comprehensive technical and commercial proposal for '")
          .append(title).append("'. Having rigorously reviewed the RFP specifications, our engineering leadership confirms full technical capability, licensed workforce availability, and logistical readiness to execute the entire scope within stipulated timelines and budget expectations.\n\n");

        sb.append("2. EXECUTION METHODOLOGY & TECHNICAL APPROACH:\n");
        sb.append("- Phase 1 (Mobilization & Site Readiness): Complete technical reconnaissance, milestone baseline signoff, and stakeholder alignment within 14 calendar days of Work Order issuance.\n");
        sb.append("- Phase 2 (Core Deployment & Procurement): Procurement of Tier-1 certified equipment and materials matching all RFP standard specifications.\n");
        sb.append("- Phase 3 (Installation, Rigorous Testing & QA): Staged implementation supervised by certified Project Management Professionals (PMP), ensuring zero safety incidents.\n");
        sb.append("- Phase 4 (Commissioning & Handover): Execution of end-to-end integration tests, statutory approvals, as-built documentation, and operations training.\n\n");

        sb.append("3. QUALITY ASSURANCE, HEALTH & SAFETY (EHS):\n");
        sb.append("Our operations adhere strictly to ISO 9001 (Quality Management) and ISO 45001 (Occupational Health & Safety). All deployed equipment will be backed by OEM manufacturer test certificates, and daily safety toolbox briefings will be conducted on site.\n\n");

        sb.append("4. MILESTONES & TIMELINE COMMITMENT:\n");
        sb.append("We commit to delivering the completed project prior to the tender deadline, adhering to bi-weekly progress reports and milestone verification signoffs.\n\n");

        sb.append("5. WARRANTY, MAINTENANCE & SLA:\n");
        sb.append("This proposal includes a comprehensive 24-month Defect Liability Period (DLP) and warranty, covering routine preventive maintenance, immediate replacement of defective parts, and a 4-hour emergency response SLA.");

        return sb.toString();
    }

    /**
     * Real-time Proposal Quality & Strength Scorer
     */
    public Map<String, Object> analyzeProposal(String proposalText, BigDecimal tenderBudget, BigDecimal bidAmount) {
        Map<String, Object> analysis = new LinkedHashMap<>();
        int score = 0;
        List<String> strengths = new ArrayList<>();
        List<String> improvements = new ArrayList<>();

        if (proposalText == null || proposalText.trim().isEmpty()) {
            analysis.put("score", 0);
            analysis.put("grade", "INSUFFICIENT");
            analysis.put("summary", "No proposal text entered yet. Use the 'AI Draft Proposal' button to start with a strong baseline.");
            analysis.put("strengths", strengths);
            improvements.add("Add a detailed technical methodology statement.");
            improvements.add("Include quality assurance and testing commitments.");
            improvements.add("Mention execution timeline and milestones.");
            analysis.put("improvements", improvements);
            return analysis;
        }

        String text = proposalText.toLowerCase();
        int wordCount = proposalText.trim().split("\\s+").length;

        // Metric 1: Depth & Scope Coverage (25 pts)
        if (wordCount >= 150) {
            score += 25;
            strengths.add("Comprehensive technical length (" + wordCount + " words) providing thorough scope coverage.");
        } else if (wordCount >= 75) {
            score += 15;
            strengths.add("Adequate length (" + wordCount + " words), though additional execution details are recommended.");
        } else {
            score += 5;
            improvements.add("Proposal is quite brief (" + wordCount + " words). Expand on execution specifics to build credibility.");
        }

        // Metric 2: Quality, Safety & ISO Standards (20 pts)
        boolean hasQuality = text.contains("iso") || text.contains("quality") || text.contains("standard") ||
                             text.contains("safety") || text.contains("compliance") || text.contains("testing");
        if (hasQuality) {
            score += 20;
            strengths.add("Demonstrated commitment to quality assurance, testing protocols, or safety standards.");
        } else {
            improvements.add("Mention quality standards (e.g. ISO 9001, BIS standards, safety protocols, or testing phases).");
        }

        // Metric 3: Milestones & Project Timelines (20 pts)
        boolean hasTimeline = text.contains("milestone") || text.contains("timeline") || text.contains("phase") ||
                              text.contains("schedule") || text.contains("month") || text.contains("week") || text.contains("delivery");
        if (hasTimeline) {
            score += 20;
            strengths.add("Clear phased delivery schedule and milestone commitments identified.");
        } else {
            improvements.add("Include clear milestone phases (e.g. Phase 1 Mobilization, Phase 2 Deployment, Final Handover).");
        }

        // Metric 4: Warranty, DLP & Maintenance SLA (15 pts)
        boolean hasWarranty = text.contains("warranty") || text.contains("maintenance") || text.contains("defect") ||
                              text.contains("dlp") || text.contains("sla") || text.contains("support");
        if (hasWarranty) {
            score += 15;
            strengths.add("Explicit post-execution warranty, Defect Liability Period (DLP), or support SLA included.");
        } else {
            improvements.add("State your warranty coverage or defect liability period (e.g. 12 or 24 months post-completion).");
        }

        // Metric 5: Pricing Realism & Budget Consistency (20 pts)
        if (bidAmount != null && tenderBudget != null && tenderBudget.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal variance = bidAmount.subtract(tenderBudget)
                    .divide(tenderBudget, 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal(100));

            double varVal = variance.doubleValue();
            if (varVal >= -25.0 && varVal <= 5.0) {
                score += 20;
                strengths.add("Highly realistic pricing (" + String.format("%.1f", Math.abs(varVal)) + "% " +
                              (varVal < 0 ? "below" : "above") + " budget benchmark) indicating low execution risk.");
            } else if (varVal < -30.0) {
                score += 8;
                improvements.add("Quote is unusually low (" + String.format("%.1f", Math.abs(varVal)) + "% below budget). Justify how quality standards will be maintained without cost-cutting.");
            } else if (varVal > 10.0) {
                score += 10;
                improvements.add("Quote is higher than the allocated budget (" + String.format("%.1f", varVal) + "% above). Consider optimizing margins to remain competitive against L1 bidders.");
            } else {
                score += 15;
            }
        } else {
            score += 15; // default allocation if budget not entered yet
        }

        if (score > 100) score = 100;

        String grade;
        if (score >= 85) grade = "EXCELLENT";
        else if (score >= 70) grade = "GOOD";
        else if (score >= 50) grade = "SATISFACTORY";
        else grade = "NEEDS IMPROVEMENT";

        analysis.put("score", score);
        analysis.put("grade", grade);
        analysis.put("strengths", strengths);
        analysis.put("improvements", improvements);

        return analysis;
    }

    /**
     * AI Anomaly & Bid Outlier Risk Detector for Awarding Authority
     */
    public Map<String, Object> evaluateBidsRisk(Tender tender, List<Bid> bids) {
        Map<String, Object> eval = new LinkedHashMap<>();
        if (tender == null || bids == null || bids.isEmpty()) {
            eval.put("hasBids", false);
            eval.put("summary", "No bids submitted yet to evaluate.");
            return eval;
        }

        eval.put("hasBids", true);
        BigDecimal budget = tender.getEstimatedBudget() != null ? tender.getEstimatedBudget() : BigDecimal.ZERO;

        // Find L1 bidder
        Bid l1Bid = null;
        for (Bid b : bids) {
            if (l1Bid == null || b.getAmount().compareTo(l1Bid.getAmount()) < 0) {
                l1Bid = b;
            }
        }

        List<Map<String, Object>> bidRiskItems = new ArrayList<>();
        boolean foundAbnormallyLow = false;
        boolean foundExcessive = false;

        for (Bid b : bids) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("bidId", b.getId());
            item.put("vendorName", b.getVendorName());
            item.put("amountFormatted", formatCurrency(b.getAmount()));

            double variancePercent = 0.0;
            if (budget.compareTo(BigDecimal.ZERO) > 0) {
                variancePercent = b.getAmount().subtract(budget)
                        .divide(budget, 4, RoundingMode.HALF_UP)
                        .multiply(new BigDecimal(100)).doubleValue();
            }
            item.put("variancePercent", variancePercent);

            String riskBadge;
            String riskNote;

            if (variancePercent < -30.0) {
                riskBadge = "HIGH_RISK_OUTLIER";
                riskNote = "Abnormally low commercial quote (> 30% below budget). Heightened risk of contractor default, corner-cutting, or variation-claim disputes.";
                foundAbnormallyLow = true;
            } else if (variancePercent < -15.0) {
                riskBadge = "COMPETITIVE_SAVING";
                riskNote = "Aggressive yet feasible commercial pricing offering substantial fiscal savings.";
            } else if (variancePercent > 10.0) {
                riskBadge = "ABOVE_BUDGET";
                riskNote = "Quote exceeds sanctioned budget allocation; would require supplementary appropriation.";
                foundExcessive = true;
            } else {
                riskBadge = "OPTIMAL_BENCHMARK";
                riskNote = "Balanced quote aligning closely with engineered cost estimates.";
            }

            item.put("riskBadge", riskBadge);
            item.put("riskNote", riskNote);
            bidRiskItems.add(item);
        }

        eval.put("bidEvaluations", bidRiskItems);
        eval.put("l1BidId", l1Bid != null ? l1Bid.getId() : null);
        eval.put("l1VendorName", l1Bid != null ? l1Bid.getVendorName() : "");
        eval.put("l1AmountFormatted", l1Bid != null ? formatCurrency(l1Bid.getAmount()) : "");

        // Automated Justification Suggestion
        String suggestedJustification;
        if (l1Bid != null) {
            suggestedJustification = "L1 lowest compliant commercial offer submitted by " + l1Bid.getVendorName() +
                    " at INR " + formatCurrency(l1Bid.getAmount()) +
                    ". Technical proposal meets all mandatory requirements with acceptable risk profile and proven execution capabilities.";
        } else {
            suggestedJustification = "Commercial award evaluation in progress.";
        }

        eval.put("suggestedJustification", suggestedJustification);
        eval.put("hasAbnormallyLow", foundAbnormallyLow);
        eval.put("hasExcessive", foundExcessive);

        return eval;
    }

    private String formatCurrency(BigDecimal amount) {
        if (amount == null) return "0.00";
        return String.format("%,.2f", amount);
    }
}
