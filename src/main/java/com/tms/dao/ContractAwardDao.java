package com.tms.dao;

import com.tms.model.Bid;
import com.tms.model.ContractAward;
import com.tms.model.Notification;
import com.tms.model.Vendor;
import com.tms.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;

public class ContractAwardDao {

    private final BidDao bidDao = new BidDao();
    private final TenderDao tenderDao = new TenderDao();
    private final AuditLogDao auditLogDao = new AuditLogDao();
    private final VendorDao vendorDao = new VendorDao();

    /**
     * Inserts a contract award record (standalone connection).
     */
    public int insert(ContractAward a) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            return insert(conn, a);
        }
    }

    /**
     * Inserts a contract award record within an active database transaction.
     */
    public int insert(Connection conn, ContractAward a) throws SQLException {
        String sql = "INSERT INTO contract_awards (tender_id, bid_id, notes, awarded_by) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, a.getTenderId());
            ps.setInt(2, a.getBidId());
            ps.setString(3, a.getNotes());
            ps.setInt(4, a.getAwardedBy());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    a.setId(id);
                    return id;
                }
            }
        }
        return a.getId();
    }

    /**
     * Finds the contract award record for a given tender, joined with vendor, user, and bid details.
     * Returns null if the tender has not yet been awarded.
     */
    public ContractAward findByTenderId(int tenderId) throws SQLException {
        String sql = "SELECT ca.id, ca.tender_id, ca.bid_id, ca.awarded_at, ca.notes, ca.awarded_by, " +
                     "t.title AS tender_title, " +
                     "u.name AS awarded_by_name, u.email AS awarded_by_email, " +
                     "v.company_name AS vendor_company_name, v.registration_number AS vendor_reg_no, " +
                     "b.amount AS bid_amount " +
                     "FROM contract_awards ca " +
                     "JOIN tenders t ON ca.tender_id = t.id " +
                     "JOIN users u ON ca.awarded_by = u.id " +
                     "JOIN bids b ON ca.bid_id = b.id " +
                     "JOIN vendors v ON b.vendor_id = v.id " +
                     "WHERE ca.tender_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tenderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ContractAward ca = new ContractAward();
                    ca.setId(rs.getInt("id"));
                    ca.setTenderId(rs.getInt("tender_id"));
                    ca.setBidId(rs.getInt("bid_id"));
                    ca.setAwardedAt(rs.getTimestamp("awarded_at"));
                    ca.setNotes(rs.getString("notes"));
                    ca.setAwardedBy(rs.getInt("awarded_by"));

                    ca.setTenderTitle(rs.getString("tender_title"));
                    ca.setAwardedByName(rs.getString("awarded_by_name"));
                    ca.setAwardedByEmail(rs.getString("awarded_by_email"));
                    ca.setVendorCompanyName(rs.getString("vendor_company_name"));
                    ca.setVendorRegNumber(rs.getString("vendor_reg_no"));
                    ca.setBidAmount(rs.getBigDecimal("bid_amount"));
                    return ca;
                }
                return null;
            }
        }
    }

    /**
     * Executes the complete contract award transaction atomically across multiple tables:
     * 1. Inserts record into contract_awards
     * 2. Sets winning bid status to AWARDED
     * 3. Sets all other bids on the tender to REJECTED
     * 4. Sets tender status to CLOSED
     * 5. Inserts audit_logs record with action = CONTRACT_AWARDED
     */
    public boolean awardContractTransaction(int tenderId, int winningBidId, int adminUserId, String notes) throws SQLException {
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Concurrency Guard: verify no award exists yet
                String checkSql = "SELECT id FROM contract_awards WHERE tender_id = ? FOR UPDATE";
                try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                    checkPs.setInt(1, tenderId);
                    try (ResultSet rs = checkPs.executeQuery()) {
                        if (rs.next()) {
                            throw new IllegalStateException("This tender has already been awarded.");
                        }
                    }
                }

                // 2. Insert contract_awards row
                ContractAward award = new ContractAward();
                award.setTenderId(tenderId);
                award.setBidId(winningBidId);
                award.setNotes(notes);
                award.setAwardedBy(adminUserId);
                int awardId = insert(conn, award);

                // 3. Update winning bid to AWARDED
                bidDao.updateStatus(conn, winningBidId, "AWARDED");

                // 4. Update all other bids on this tender to REJECTED
                bidDao.rejectOtherBids(conn, tenderId, winningBidId);

                // 5. Update tender status to CLOSED
                tenderDao.updateStatus(conn, tenderId, "CLOSED");

                // 6. Insert audit trail
                String auditDetails = "Contract awarded for Tender #" + tenderId + " to Bid #" + winningBidId;
                if (notes != null && !notes.trim().isEmpty()) {
                    auditDetails += " | Justification: " + notes.trim();
                }
                auditLogDao.log(conn, adminUserId, "CONTRACT_AWARDED", "CONTRACT_AWARD", awardId, auditDetails);

                // 7. Notify winning vendor and other participating bidders
                NotificationDao notificationDao = new NotificationDao();
                List<Bid> tenderBids = bidDao.findByTender(tenderId);
                for (Bid b : tenderBids) {
                    Vendor bidder = vendorDao.findById(b.getVendorId());
                    if (bidder != null) {
                        Notification notif = new Notification();
                        notif.setUserId(bidder.getUserId());
                        if (b.getId() == winningBidId) {
                            notif.setTitle("Tender Awarded! Contract Certificate Ready");
                            notif.setMessage("Congratulations! Your proposal was selected and awarded the contract for Tender #" + tenderId);
                            notif.setLink("award-certificate?tenderId=" + tenderId);
                        } else {
                            notif.setTitle("Tender Bidding Concluded");
                            notif.setMessage("Tender #" + tenderId + " evaluation has concluded and the contract has been awarded.");
                            notif.setLink("my-bids");
                        }
                        notificationDao.insert(conn, notif);
                    }
                }

                // Commit transaction
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                if (e instanceof SQLException) {
                    throw (SQLException) e;
                }
                throw new SQLException("Transaction rolled back: " + e.getMessage(), e);
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }
}
