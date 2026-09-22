package com.tms.dao;

import com.tms.model.User;
import com.tms.model.Vendor;
import com.tms.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class VendorDao {

    /** Checks whether a vendor with the given registration number already exists. */
    public boolean existsByRegistrationNumber(String regNumber) throws SQLException {
        String sql = "SELECT id FROM vendors WHERE registration_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, regNumber);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Inserts one row into users (role=VENDOR, status=ACTIVE) and one row into vendors (approval_status=PENDING)
     * in the same transaction. Rolls back both if either insert fails.
     */
    public boolean registerVendor(User user, Vendor vendor) throws SQLException {
        String insertUserSql = "INSERT INTO users (name, email, password, role, status) VALUES (?, ?, ?, 'VENDOR', 'ACTIVE')";
        String insertVendorSql = "INSERT INTO vendors (user_id, company_name, registration_number, phone, address, approval_status) VALUES (?, ?, ?, ?, ?, 'PENDING')";

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            int userId;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, user.getName());
                psUser.setString(2, user.getEmail());
                psUser.setString(3, user.getPassword());
                psUser.executeUpdate();

                try (ResultSet rs = psUser.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to retrieve generated user ID.");
                    }
                }
            }

            try (PreparedStatement psVendor = conn.prepareStatement(insertVendorSql, Statement.RETURN_GENERATED_KEYS)) {
                psVendor.setInt(1, userId);
                psVendor.setString(2, vendor.getCompanyName());
                psVendor.setString(3, vendor.getRegistrationNumber());
                psVendor.setString(4, vendor.getPhone());
                psVendor.setString(5, vendor.getAddress());
                psVendor.executeUpdate();

                try (ResultSet rs = psVendor.getGeneratedKeys()) {
                    if (rs.next()) {
                        vendor.setId(rs.getInt(1));
                    }
                }
            }

            conn.commit();
            user.setId(userId);
            vendor.setUserId(userId);
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }

    /** Returns all vendors matching the specified approval status, joined with their user account details. */
    public List<Vendor> findByApprovalStatus(String status) throws SQLException {
        String sql = "SELECT v.id, v.user_id, v.company_name, v.registration_number, v.phone, v.address, v.approval_status, " +
                     "u.name AS contact_name, u.email AS contact_email " +
                     "FROM vendors v " +
                     "JOIN users u ON v.user_id = u.id " +
                     "WHERE v.approval_status = ? " +
                     "ORDER BY v.id ASC";

        List<Vendor> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Vendor v = new Vendor();
                    v.setId(rs.getInt("id"));
                    v.setUserId(rs.getInt("user_id"));
                    v.setCompanyName(rs.getString("company_name"));
                    v.setRegistrationNumber(rs.getString("registration_number"));
                    v.setPhone(rs.getString("phone"));
                    v.setAddress(rs.getString("address"));
                    v.setApprovalStatus(rs.getString("approval_status"));
                    v.setContactName(rs.getString("contact_name"));
                    v.setContactEmail(rs.getString("contact_email"));
                    list.add(v);
                }
            }
        }
        return list;
    }

    /** Updates the approval status of a vendor (e.g. APPROVED or REJECTED) only if currently PENDING. */
    public boolean updateApprovalStatus(int vendorId, String newStatus) throws SQLException {
        String sql = "UPDATE vendors SET approval_status = ? WHERE id = ? AND approval_status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, vendorId);
            return ps.executeUpdate() > 0;
        }
    }

    /** Finds a vendor by the associated user ID. */
    public Vendor findByUserId(int userId) throws SQLException {
        String sql = "SELECT id, user_id, company_name, registration_number, phone, address, approval_status " +
                     "FROM vendors WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Vendor v = new Vendor();
                    v.setId(rs.getInt("id"));
                    v.setUserId(rs.getInt("user_id"));
                    v.setCompanyName(rs.getString("company_name"));
                    v.setRegistrationNumber(rs.getString("registration_number"));
                    v.setPhone(rs.getString("phone"));
                    v.setAddress(rs.getString("address"));
                    v.setApprovalStatus(rs.getString("approval_status"));
                    return v;
                }
            }
        }
        return null;
    }

    /** Finds a vendor by primary key ID. */
    public Vendor findById(int id) throws SQLException {
        String sql = "SELECT id, user_id, company_name, registration_number, phone, address, approval_status " +
                     "FROM vendors WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Vendor v = new Vendor();
                    v.setId(rs.getInt("id"));
                    v.setUserId(rs.getInt("user_id"));
                    v.setCompanyName(rs.getString("company_name"));
                    v.setRegistrationNumber(rs.getString("registration_number"));
                    v.setPhone(rs.getString("phone"));
                    v.setAddress(rs.getString("address"));
                    v.setApprovalStatus(rs.getString("approval_status"));
                    return v;
                }
                return null;
            }
        }
    }
}
