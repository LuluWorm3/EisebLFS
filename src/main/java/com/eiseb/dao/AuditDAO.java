package com.eiseb.dao;

import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditDAO {

    private final ServletContext ctx;
    public AuditDAO(ServletContext ctx) { this.ctx = ctx; }

    public void log(int userId, String username, String action, String entity, int entityId, String details) throws SQLException {
        String sql = "INSERT INTO audit_log (user_id, username, action, entity, entity_id, details) VALUES (?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, username);
            ps.setString(3, action);
            ps.setString(4, entity);
            ps.setInt(5, entityId);
            ps.setString(6, details);
            ps.executeUpdate();
        }
    }

    public List<String[]> getRecentLogs(int limit) throws SQLException {
        List<String[]> logs = new ArrayList<>();
        String sql = "SELECT username, action, entity, entity_id, details, created_at FROM audit_log ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    logs.add(new String[]{
                        rs.getString("username"),
                        rs.getString("action"),
                        rs.getString("entity"),
                        String.valueOf(rs.getInt("entity_id")),
                        rs.getString("details") != null ? rs.getString("details") : "",
                        rs.getString("created_at") != null ? rs.getString("created_at") : ""
                    });
                }
            }
        }
        return logs;
    }
}
