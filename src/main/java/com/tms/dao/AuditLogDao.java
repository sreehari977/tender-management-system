package com.tms.dao;

import com.tms.model.AuditLog;
import com.tms.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDao {

    public void log(Integer userId, String action, String entityType, int entityId, String details) throws SQLException {
        String sql = "INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, action);
            ps.setString(3, entityType);
            ps.setInt(4, entityId);
            ps.setString(5, details);
            ps.executeUpdate();
        }
    }

    public void log(Connection conn, Integer userId, String action, String entityType, int entityId, String details) throws SQLException {
        String sql = "INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, action);
            ps.setString(3, entityType);
            ps.setInt(4, entityId);
            ps.setString(5, details);
            ps.executeUpdate();
        }
    }

    public List<AuditLog> findAll(int limit, int offset, String actionFilter) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT a.id, a.user_id, a.action, a.entity_type, a.entity_id, a.timestamp, a.details, " +
            "u.name AS user_name, u.email AS user_email " +
            "FROM audit_logs a " +
            "LEFT JOIN users u ON a.user_id = u.id "
        );
        List<Object> params = new ArrayList<>();
        if (actionFilter != null && !actionFilter.trim().isEmpty()) {
            sql.append("WHERE a.action = ? ");
            params.add(actionFilter.trim());
        }
        sql.append("ORDER BY a.timestamp DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<AuditLog> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog l = new AuditLog();
                    l.setId(rs.getInt("id"));
                    int uid = rs.getInt("user_id");
                    if (!rs.wasNull()) {
                        l.setUserId(uid);
                    }
                    l.setAction(rs.getString("action"));
                    l.setEntityType(rs.getString("entity_type"));
                    l.setEntityId(rs.getInt("entity_id"));
                    l.setTimestamp(rs.getTimestamp("timestamp"));
                    l.setDetails(rs.getString("details"));
                    l.setUserName(rs.getString("user_name"));
                    l.setUserEmail(rs.getString("user_email"));
                    list.add(l);
                }
            }
        }
        return list;
    }

    public int count(String actionFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM audit_logs ");
        List<Object> params = new ArrayList<>();
        if (actionFilter != null && !actionFilter.trim().isEmpty()) {
            sql.append("WHERE action = ? ");
            params.add(actionFilter.trim());
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

    public List<String> getDistinctActions() throws SQLException {
        List<String> actions = new ArrayList<>();
        String sql = "SELECT DISTINCT action FROM audit_logs ORDER BY action ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                actions.add(rs.getString("action"));
            }
        }
        return actions;
    }
}
