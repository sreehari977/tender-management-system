package com.tms.dao;

import com.tms.model.Bid;
import com.tms.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BidDao {

    /**
     * Inserts a new bid into the database.
     * @return The auto-generated bid ID.
     */
    public int insert(Bid b) throws SQLException {
        String sql = "INSERT INTO bids (tender_id, vendor_id, amount, proposal_text, status, attachment_filename, attachment_path) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, b.getTenderId());
            ps.setInt(2, b.getVendorId());
            ps.setBigDecimal(3, b.getAmount());
            ps.setString(4, b.getProposalText());
            ps.setString(5, b.getStatus() != null ? b.getStatus() : "SUBMITTED");
            ps.setString(6, b.getAttachmentFilename());
            ps.setString(7, b.getAttachmentPath());

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    b.setId(id);
                    return id;
                }
            }
        }
        return b.getId();
    }

    /**
     * Finds a bid submitted by a specific vendor on a specific tender.
     */
    public Bid findByTenderAndVendor(int tenderId, int vendorId) throws SQLException {
        String sql = "SELECT id, tender_id, vendor_id, amount, proposal_text, submitted_at, status, " +
                     "attachment_filename, attachment_path " +
                     "FROM bids WHERE tender_id = ? AND vendor_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tenderId);
            ps.setInt(2, vendorId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
                return null;
            }
        }
    }

    /**
     * Checks whether a vendor has already submitted a bid for a given tender.
     */
    public boolean hasVendorBid(int tenderId, int vendorId) throws SQLException {
        String sql = "SELECT id FROM bids WHERE tender_id = ? AND vendor_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tenderId);
            ps.setInt(2, vendorId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Finds all bids submitted by a specific vendor, joined with tender details.
     */
    public List<Bid> findByVendor(int vendorId) throws SQLException {
        String sql = "SELECT b.id, b.tender_id, b.vendor_id, b.amount, b.proposal_text, b.submitted_at, b.status, " +
                     "b.attachment_filename, b.attachment_path, " +
                     "t.title AS tender_title, t.category AS tender_category, t.status AS tender_status " +
                     "FROM bids b " +
                     "JOIN tenders t ON b.tender_id = t.id " +
                     "WHERE b.vendor_id = ? " +
                     "ORDER BY b.submitted_at DESC";

        List<Bid> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, vendorId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bid b = mapRow(rs);
                    b.setTenderTitle(rs.getString("tender_title"));
                    b.setTenderCategory(rs.getString("tender_category"));
                    b.setTenderStatus(rs.getString("tender_status"));
                    list.add(b);
                }
            }
        }
        return list;
    }

    /**
     * Finds all bids for a given tender, sorted by amount (default) or date.
     * Enriched with vendor profile information.
     */
    public List<Bid> findByTender(int tenderId, String sortBy) throws SQLException {
        String orderBy = " ORDER BY b.amount ASC";
        if ("date".equalsIgnoreCase(sortBy)) {
            orderBy = " ORDER BY b.submitted_at DESC";
        }

        String sql = "SELECT b.id, b.tender_id, b.vendor_id, b.amount, b.proposal_text, b.submitted_at, b.status, " +
                     "b.attachment_filename, b.attachment_path, " +
                     "v.company_name AS vendor_company_name, v.registration_number AS vendor_reg_no, v.phone AS vendor_phone, " +
                     "u.email AS vendor_email " +
                     "FROM bids b " +
                     "JOIN vendors v ON b.vendor_id = v.id " +
                     "JOIN users u ON v.user_id = u.id " +
                     "WHERE b.tender_id = ?" + orderBy;

        List<Bid> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, tenderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Bid b = mapRow(rs);
                    b.setVendorCompanyName(rs.getString("vendor_company_name"));
                    b.setVendorRegNumber(rs.getString("vendor_reg_no"));
                    b.setVendorPhone(rs.getString("vendor_phone"));
                    b.setVendorEmail(rs.getString("vendor_email"));
                    list.add(b);
                }
            }
        }
        return list;
    }

    /**
     * Finds all bids for a given tender, defaulting to lowest amount first.
     */
    public List<Bid> findByTender(int tenderId) throws SQLException {
        return findByTender(tenderId, "amount");
    }

    /**
     * Finds a single bid by ID with joined vendor details.
     */
    public Bid findById(int bidId) throws SQLException {
        String sql = "SELECT b.id, b.tender_id, b.vendor_id, b.amount, b.proposal_text, b.submitted_at, b.status, " +
                     "b.attachment_filename, b.attachment_path, " +
                     "v.company_name AS vendor_company_name, v.registration_number AS vendor_reg_no, v.phone AS vendor_phone, " +
                     "u.email AS vendor_email " +
                     "FROM bids b " +
                     "JOIN vendors v ON b.vendor_id = v.id " +
                     "JOIN users u ON v.user_id = u.id " +
                     "WHERE b.id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bidId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Bid b = mapRow(rs);
                    b.setVendorCompanyName(rs.getString("vendor_company_name"));
                    b.setVendorRegNumber(rs.getString("vendor_reg_no"));
                    b.setVendorPhone(rs.getString("vendor_phone"));
                    b.setVendorEmail(rs.getString("vendor_email"));
                    return b;
                }
                return null;
            }
        }
    }

    /**
     * Updates status of a bid (standalone connection).
     */
    public boolean updateStatus(int bidId, String status) throws SQLException {
        String sql = "UPDATE bids SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bidId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Updates status of a bid within an active database transaction.
     */
    public boolean updateStatus(Connection conn, int bidId, String status) throws SQLException {
        String sql = "UPDATE bids SET status = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, bidId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Sets all other bids on a tender to REJECTED within an active database transaction.
     */
    public int rejectOtherBids(Connection conn, int tenderId, int winningBidId) throws SQLException {
        String sql = "UPDATE bids SET status = 'REJECTED' WHERE tender_id = ? AND id != ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tenderId);
            ps.setInt(2, winningBidId);
            return ps.executeUpdate();
        }
    }

    private Bid mapRow(ResultSet rs) throws SQLException {
        Bid b = new Bid();
        b.setId(rs.getInt("id"));
        b.setTenderId(rs.getInt("tender_id"));
        b.setVendorId(rs.getInt("vendor_id"));
        b.setAmount(rs.getBigDecimal("amount"));
        b.setProposalText(rs.getString("proposal_text"));
        b.setSubmittedAt(rs.getTimestamp("submitted_at"));
        b.setStatus(rs.getString("status"));
        b.setAttachmentFilename(rs.getString("attachment_filename"));
        b.setAttachmentPath(rs.getString("attachment_path"));
        return b;
    }
}
