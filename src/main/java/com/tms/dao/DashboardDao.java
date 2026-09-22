package com.tms.dao;

import com.tms.model.Tender;
import com.tms.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DashboardDao {

    public int getTotalVendors() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM vendors");
    }

    public int getPendingVendorApprovals() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM vendors WHERE approval_status = 'PENDING'");
    }

    public int getTotalTenders() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM tenders");
    }

    public int getPublishedTenders() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM tenders WHERE status = 'PUBLISHED'");
    }

    public int getClosedTenders() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM tenders WHERE status = 'CLOSED'");
    }

    public int getTotalBids() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM bids");
    }

    public int getTotalContractAwards() throws SQLException {
        return queryCount("SELECT COUNT(*) FROM contract_awards");
    }

    public BigDecimal getTotalAwardedValue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(b.amount), 0) FROM contract_awards ca JOIN bids b ON ca.bid_id = b.id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
            return BigDecimal.ZERO;
        }
    }

    /**
     * Retrieves the most recently published tenders up to the specified limit.
     */
    public List<Tender> getRecentPublishedTenders(int limit) throws SQLException {
        String sql = "SELECT id, title, description, category, estimated_budget, publish_date, deadline, status " +
                     "FROM tenders " +
                     "WHERE status = 'PUBLISHED' " +
                     "ORDER BY publish_date DESC, id DESC " +
                     "LIMIT ?";

        List<Tender> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Tender t = new Tender();
                    t.setId(rs.getInt("id"));
                    t.setTitle(rs.getString("title"));
                    t.setDescription(rs.getString("description"));
                    t.setCategory(rs.getString("category"));
                    t.setEstimatedBudget(rs.getBigDecimal("estimated_budget"));
                    t.setPublishDate(rs.getTimestamp("publish_date"));
                    t.setDeadline(rs.getTimestamp("deadline"));
                    t.setStatus(rs.getString("status"));
                    list.add(t);
                }
            }
        }
        return list;
    }

    private int queryCount(String sql) throws SQLException {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }
}
