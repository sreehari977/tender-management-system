package com.tms.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

public class Bid {
    private int id;
    private int tenderId;
    private int vendorId;
    private BigDecimal amount;
    private String proposalText;
    private Timestamp submittedAt;
    private String status = "SUBMITTED";
    private String attachmentFilename;
    private String attachmentPath;

    public String getAttachmentFilename() { return attachmentFilename; }
    public void setAttachmentFilename(String attachmentFilename) { this.attachmentFilename = attachmentFilename; }

    public String getAttachmentPath() { return attachmentPath; }
    public void setAttachmentPath(String attachmentPath) { this.attachmentPath = attachmentPath; }

    // Joined presentation fields
    private String tenderTitle;
    private String tenderCategory;
    private String tenderStatus;
    private String vendorCompanyName;
    private String vendorRegNumber;
    private String vendorPhone;
    private String vendorEmail;
    private String rankLabel;
    private String variancePercent;
    private String varianceClass = "text-muted";
    private BigDecimal varianceAmount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTenderId() { return tenderId; }
    public void setTenderId(int tenderId) { this.tenderId = tenderId; }

    public int getVendorId() { return vendorId; }
    public void setVendorId(int vendorId) { this.vendorId = vendorId; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getProposalText() { return proposalText; }
    public void setProposalText(String proposalText) { this.proposalText = proposalText; }

    public Timestamp getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Timestamp submittedAt) { this.submittedAt = submittedAt; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTenderTitle() { return tenderTitle; }
    public void setTenderTitle(String tenderTitle) { this.tenderTitle = tenderTitle; }

    public String getTenderCategory() { return tenderCategory; }
    public void setTenderCategory(String tenderCategory) { this.tenderCategory = tenderCategory; }

    public String getTenderStatus() { return tenderStatus; }
    public void setTenderStatus(String tenderStatus) { this.tenderStatus = tenderStatus; }

    public String getVendorCompanyName() { return vendorCompanyName; }
    public void setVendorCompanyName(String vendorCompanyName) { this.vendorCompanyName = vendorCompanyName; }

    public String getVendorName() { return vendorCompanyName != null ? vendorCompanyName : ""; }

    public String getVendorRegNumber() { return vendorRegNumber; }
    public void setVendorRegNumber(String vendorRegNumber) { this.vendorRegNumber = vendorRegNumber; }

    public String getVendorPhone() { return vendorPhone; }
    public void setVendorPhone(String vendorPhone) { this.vendorPhone = vendorPhone; }

    public String getVendorEmail() { return vendorEmail; }
    public void setVendorEmail(String vendorEmail) { this.vendorEmail = vendorEmail; }

    public String getRankLabel() { return rankLabel; }
    public void setRankLabel(String rankLabel) { this.rankLabel = rankLabel; }

    public String getVariancePercent() { return variancePercent; }
    public void setVariancePercent(String variancePercent) { this.variancePercent = variancePercent; }

    public String getVarianceClass() { return varianceClass; }
    public void setVarianceClass(String varianceClass) { this.varianceClass = varianceClass; }

    public BigDecimal getVarianceAmount() { return varianceAmount; }
    public void setVarianceAmount(BigDecimal varianceAmount) { this.varianceAmount = varianceAmount; }

    /** Returns formatted amount with comma grouping (e.g. 2,300,000.00). */
    public String getFormattedAmount() {
        if (amount == null) return "0.00";
        return String.format("%,.2f", amount);
    }

    /** Returns formatted submission timestamp. */
    public String getFormattedSubmittedAt() {
        if (submittedAt == null) return "";
        return submittedAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
    }
}
