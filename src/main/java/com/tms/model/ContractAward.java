package com.tms.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

public class ContractAward {
    private int id;
    private int tenderId;
    private int bidId;
    private Timestamp awardedAt;
    private String notes;
    private int awardedBy;

    // Joined presentation fields
    private String tenderTitle;
    private String awardedByName;
    private String awardedByEmail;
    private String vendorCompanyName;
    private String vendorRegNumber;
    private BigDecimal bidAmount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTenderId() { return tenderId; }
    public void setTenderId(int tenderId) { this.tenderId = tenderId; }

    public int getBidId() { return bidId; }
    public void setBidId(int bidId) { this.bidId = bidId; }

    public Timestamp getAwardedAt() { return awardedAt; }
    public void setAwardedAt(Timestamp awardedAt) { this.awardedAt = awardedAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public int getAwardedBy() { return awardedBy; }
    public void setAwardedBy(int awardedBy) { this.awardedBy = awardedBy; }

    public String getTenderTitle() { return tenderTitle; }
    public void setTenderTitle(String tenderTitle) { this.tenderTitle = tenderTitle; }

    public String getAwardedByName() { return awardedByName; }
    public void setAwardedByName(String awardedByName) { this.awardedByName = awardedByName; }

    public String getAwardedByEmail() { return awardedByEmail; }
    public void setAwardedByEmail(String awardedByEmail) { this.awardedByEmail = awardedByEmail; }

    public String getVendorCompanyName() { return vendorCompanyName; }
    public void setVendorCompanyName(String vendorCompanyName) { this.vendorCompanyName = vendorCompanyName; }

    public String getVendorRegNumber() { return vendorRegNumber; }
    public void setVendorRegNumber(String vendorRegNumber) { this.vendorRegNumber = vendorRegNumber; }

    public BigDecimal getBidAmount() { return bidAmount; }
    public void setBidAmount(BigDecimal bidAmount) { this.bidAmount = bidAmount; }

    /** Formats the awarded bid amount with currency grouping. */
    public String getFormattedBidAmount() {
        if (bidAmount == null) return "0.00";
        return String.format("%,.2f", bidAmount);
    }

    /** Formats the award timestamp (dd MMM yyyy, hh:mm a). */
    public String getFormattedAwardedAt() {
        if (awardedAt == null) return "";
        return awardedAt.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
    }
}
