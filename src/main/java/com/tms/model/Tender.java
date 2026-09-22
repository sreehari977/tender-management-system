package com.tms.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

public class Tender {
    private int id;
    private String title;
    private String description;
    private String category;
    private BigDecimal estimatedBudget;
    private Timestamp publishDate;
    private Timestamp deadline;
    private String status;
    private int createdBy;
    private String attachmentFilename;
    private String attachmentPath;

    public String getAttachmentFilename() { return attachmentFilename; }
    public void setAttachmentFilename(String attachmentFilename) { this.attachmentFilename = attachmentFilename; }

    public String getAttachmentPath() { return attachmentPath; }
    public void setAttachmentPath(String attachmentPath) { this.attachmentPath = attachmentPath; }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public BigDecimal getEstimatedBudget() { return estimatedBudget; }
    public void setEstimatedBudget(BigDecimal estimatedBudget) { this.estimatedBudget = estimatedBudget; }

    public Timestamp getPublishDate() { return publishDate; }
    public void setPublishDate(Timestamp publishDate) { this.publishDate = publishDate; }

    public Timestamp getDeadline() { return deadline; }
    public void setDeadline(Timestamp deadline) { this.deadline = deadline; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    /** Returns deadline formatted as yyyy-MM-ddTHH:mm for HTML datetime-local inputs. */
    public String getDeadlineForInput() {
        if (deadline == null) return "";
        return deadline.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    }

    /** Returns formatted deadline (e.g. 18 Sep 2026, 02:18 PM) */
    public String getFormattedDeadline() {
        if (deadline == null) return "Not specified";
        return deadline.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
    }

    /** Returns formatted publish date (e.g. 04 Sep 2026, 02:18 PM) */
    public String getFormattedPublishDate() {
        if (publishDate == null) return "Not yet published";
        return publishDate.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a"));
    }

    /** Returns estimated budget with comma formatting, or 'Not specified' */
    public String getFormattedBudget() {
        if (estimatedBudget == null) return "Not specified";
        return String.format("%,.2f", estimatedBudget);
    }

    /** Returns true if deadline is in the past. */
    public boolean isDeadlinePassed() {
        if (deadline == null) return false;
        return !deadline.after(new Timestamp(System.currentTimeMillis()));
    }

    /** Returns human-readable remaining time text. */
    public String getTimeRemaining() {
        if (deadline == null) return "";
        long diffMillis = deadline.getTime() - System.currentTimeMillis();
        if (diffMillis <= 0) return "Deadline passed";
        long days = diffMillis / (1000 * 60 * 60 * 24);
        long hours = (diffMillis / (1000 * 60 * 60)) % 24;
        if (days > 1) {
            return days + " days remaining";
        } else if (days == 1) {
            return "1 day remaining";
        } else if (hours > 0) {
            return hours + " hours remaining";
        } else {
            return "Ending soon";
        }
    }
}
