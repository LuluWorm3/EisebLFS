package com.eiseb.dao;

import com.eiseb.model.Enquiry;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EnquiryDAO {

    private final ServletContext ctx;
    public EnquiryDAO(ServletContext ctx) { this.ctx = ctx; }

    public List<Enquiry> findAll() throws SQLException {
        String sql = "SELECT * FROM enquiries ORDER BY submitted_at DESC";
        List<Enquiry> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public int insert(Enquiry e) throws SQLException {
        String sql = "INSERT INTO enquiries (full_name, email, subject, message) VALUES (?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, e.getFullName());
            ps.setString(2, e.getEmail());
            ps.setString(3, e.getSubject());
            ps.setString(4, e.getMessage());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    public void reply(int id, String replyText) throws SQLException {
        String sql = "UPDATE enquiries SET reply = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, replyText);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    private Enquiry map(ResultSet rs) throws SQLException {
        Enquiry e = new Enquiry();
        e.setId(rs.getInt("id"));
        e.setFullName(rs.getString("full_name"));
        e.setEmail(rs.getString("email"));
        e.setSubject(rs.getString("subject"));
        e.setMessage(rs.getString("message"));
        e.setReply(rs.getString("reply"));
        e.setSubmittedAt(rs.getTimestamp("submitted_at"));
        return e;
    }
}
