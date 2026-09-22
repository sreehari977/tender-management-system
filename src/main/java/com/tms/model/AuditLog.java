package com.tms.model;

import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;

public class AuditLog {
    private int id;
    private Integer userId;
    private String action;
    private String entityType;
    private int entityId;
    private Timestamp timestamp;
    private String details;

    // Joined presentation fields
    private String userName;
    private String userEmail;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getEntityType() { return entityType; }
    public void setEntityType(String entityType) { this.entityType = entityType; }

    public int getEntityId() { return entityId; }
    public void setEntityId(int entityId) { this.entityId = entityId; }

    public Timestamp getTimestamp() { return timestamp; }
    public void setTimestamp(Timestamp timestamp) { this.timestamp = timestamp; }

    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getFormattedTimestamp() {
        if (timestamp == null) return "";
        return timestamp.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm:ss a"));
    }

    public String getActionBadgeClass() {
        if (action == null) return "bg-secondary";
        if (action.contains("APPROVED") || action.contains("AWARDED") || action.contains("PUBLISHED")) {
            return "bg-success";
        } else if (action.contains("REJECTED") || action.contains("DELETED")) {
            return "bg-danger";
        } else if (action.contains("SUBMITTED")) {
            return "bg-primary";
        } else {
            return "bg-info text-dark";
        }
    }
}
