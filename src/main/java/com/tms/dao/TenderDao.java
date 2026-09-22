package com.tms.dao;

import com.tms.model.Tender;
import com.tms.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TenderDao {

    public List<Tender> findAllPublished() throws SQLException {
        String sql = "SELECT id, title, description, category, estimated_budget, publish_date, deadline, status, " +
                     "attachment_filename, attachment_path, created_by " +
                     "FROM tenders WHERE status = 'PUBLISHED' ORDER BY deadline ASC";

        List<Tender> tenders = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                tenders.add(mapResultSetToTender(rs));
            }
        }
        return tenders;
    }

    public List<String> getCategories() throws SQLException {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM tenders WHERE category IS NOT NULL AND TRIM(category) != '' ORDER BY category ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("category"));
            }
        }
        return list;
    }

    public List<Tender> searchAndFilter(String query, String category, BigDecimal minBudget, BigDecimal maxBudget,
                                        String sort, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT id, title, description, category, estimated_budget, publish_date, deadline, status, " +
            "attachment_filename, attachment_path, created_by FROM tenders WHERE status = 'PUBLISHED' "
        );
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(title) LIKE ? OR LOWER(description) LIKE ?) ");
            String qLike = "%" + query.trim().toLowerCase() + "%";
            params.add(qLike);
            params.add(qLike);
        }
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND category = ? ");
            params.add(category.trim());
        }
        if (minBudget != null && minBudget.compareTo(BigDecimal.ZERO) >= 0) {
            sql.append("AND estimated_budget >= ? ");
            params.add(minBudget);
        }
        if (maxBudget != null && maxBudget.compareTo(BigDecimal.ZERO) >= 0) {
            sql.append("AND estimated_budget <= ? ");
            params.add(maxBudget);
        }

        // Sorting logic
        if ("deadline_desc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY deadline DESC ");
        } else if ("budget_asc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY estimated_budget ASC ");
        } else if ("budget_desc".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY estimated_budget DESC ");
        } else if ("newest".equalsIgnoreCase(sort)) {
            sql.append("ORDER BY id DESC ");
        } else {
            // Default: deadline soonest
            sql.append("ORDER BY deadline ASC ");
        }

        sql.append("LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Tender> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToTender(rs));
                }
            }
        }
        return list;
    }

    public int countFiltered(String query, String category, BigDecimal minBudget, BigDecimal maxBudget) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tenders WHERE status = 'PUBLISHED' ");
        List<Object> params = new ArrayList<>();

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(title) LIKE ? OR LOWER(description) LIKE ?) ");
            String qLike = "%" + query.trim().toLowerCase() + "%";
            params.add(qLike);
            params.add(qLike);
        }
        if (category != null && !category.trim().isEmpty()) {
            sql.append("AND category = ? ");
            params.add(category.trim());
        }
        if (minBudget != null && minBudget.compareTo(BigDecimal.ZERO) >= 0) {
            sql.append("AND estimated_budget >= ? ");
            params.add(minBudget);
        }
        if (maxBudget != null && maxBudget.compareTo(BigDecimal.ZERO) >= 0) {
            sql.append("AND estimated_budget <= ? ");
            params.add(maxBudget);
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public Tender findById(int id) throws SQLException {
        String sql = "SELECT id, title, description, category, estimated_budget, publish_date, deadline, status, created_by, " +
                     "attachment_filename, attachment_path " +
                     "FROM tenders WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToTender(rs);
                }
                return null;
            }
        }
    }

    public int insert(Tender t) throws SQLException {
        String sql = "INSERT INTO tenders (title, description, category, estimated_budget, publish_date, deadline, status, created_by, " +
                     "attachment_filename, attachment_path) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getDescription());
            ps.setString(3, t.getCategory());
            ps.setBigDecimal(4, t.getEstimatedBudget());
            ps.setTimestamp(5, t.getPublishDate());
            ps.setTimestamp(6, t.getDeadline());
            ps.setString(7, t.getStatus());
            ps.setInt(8, t.getCreatedBy());
            ps.setString(9, t.getAttachmentFilename());
            ps.setString(10, t.getAttachmentPath());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    t.setId(id);
                    return id;
                }
            }
        }
        return t.getId();
    }

    public boolean update(Tender t) throws SQLException {
        String sql = "UPDATE tenders SET title = ?, description = ?, category = ?, estimated_budget = ?, " +
                     "publish_date = ?, deadline = ?, status = ?, attachment_filename = ?, attachment_path = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, t.getTitle());
            ps.setString(2, t.getDescription());
            ps.setString(3, t.getCategory());
            ps.setBigDecimal(4, t.getEstimatedBudget());
            ps.setTimestamp(5, t.getPublishDate());
            ps.setTimestamp(6, t.getDeadline());
            ps.setString(7, t.getStatus());
            ps.setString(8, t.getAttachmentFilename());
            ps.setString(9, t.getAttachmentPath());
            ps.setInt(10, t.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE tenders SET status = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(Connection conn, int id, String status) throws SQLException {
        String sql = "UPDATE tenders SET status = ? WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Tender mapResultSetToTender(ResultSet rs) throws SQLException {
        Tender t = new Tender();
        t.setId(rs.getInt("id"));
        t.setTitle(rs.getString("title"));
        t.setDescription(rs.getString("description"));
        t.setCategory(rs.getString("category"));
        t.setEstimatedBudget(rs.getBigDecimal("estimated_budget"));
        t.setPublishDate(rs.getTimestamp("publish_date"));
        t.setDeadline(rs.getTimestamp("deadline"));
        t.setStatus(rs.getString("status"));
        t.setCreatedBy(rs.getInt("created_by"));
        t.setAttachmentFilename(rs.getString("attachment_filename"));
        t.setAttachmentPath(rs.getString("attachment_path"));
        return t;
    }
}
