package com.eiseb.dao;

import com.eiseb.model.User;
import com.eiseb.util.DBConnection;
import com.eiseb.util.PasswordUtil;
import jakarta.servlet.ServletContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    private final ServletContext ctx;
    public UserDAO(ServletContext ctx) { this.ctx = ctx; }

    /** Find user by username — returns null if not found. */
    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT id, full_name, username, email, password, role FROM users WHERE username = ?";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    /** Authenticate: verify username + password. Returns User if OK, null otherwise. */
    public User authenticate(String username, String password) throws SQLException {
        User u = findByUsername(username);
        if (u == null) return null;
        return PasswordUtil.verify(password, u.getPassword()) ? u : null;
    }

    /** Register a new user. Returns false if username/email already exists. */
    public boolean register(String fullName, String username, String email,
                            String plainPassword, String role) throws SQLException {
        String sql = "INSERT INTO users (full_name, username, email, password, role) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, username);
            ps.setString(3, email);
            ps.setString(4, PasswordUtil.hash(plainPassword));
            ps.setString(5, role);
            ps.executeUpdate();
            return true;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false;
        }
    }

    /** Return all users (for admin management). */
    public List<User> findAll() throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, full_name, username, email, password, role FROM users ORDER BY id";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    /** Update a user's full name, email and role (admin only). */
    public void updateUser(int id, String fullName, String email, String role) throws SQLException {
        String sql = "UPDATE users SET full_name=?, email=?, role=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, role);
            ps.setInt(4, id);
            ps.executeUpdate();
        }
    }

    /** Delete a user (admin only). */
    public void deleteUser(int id) throws SQLException {
        String sql = "DELETE FROM users WHERE id=?";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Mapping ───────────────────────────────────────────────
    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        return u;
    }
}
