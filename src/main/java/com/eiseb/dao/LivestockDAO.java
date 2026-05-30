package com.eiseb.dao;

import com.eiseb.model.Livestock;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LivestockDAO {

    private final ServletContext ctx;
    public LivestockDAO(ServletContext ctx) { this.ctx = ctx; }

    /** Return all livestock, newest first. */
    public List<Livestock> findAll() throws SQLException {
        return query("SELECT * FROM livestock ORDER BY created_at DESC", ps -> {});
    }

    /** Return animals filtered by status (e.g. "Active"). */
    public List<Livestock> findByStatus(String status) throws SQLException {
        return query("SELECT * FROM livestock WHERE status = ? ORDER BY tag",
                     ps -> ps.setString(1, status));
    }

    /** Return all Active animals (for dropdowns). */
    public List<Livestock> findActive() throws SQLException {
        return findByStatus("Active");
    }

    /** Find by id. */
    public Livestock findById(int id) throws SQLException {
        List<Livestock> list = query("SELECT * FROM livestock WHERE id = ?",
                                     ps -> ps.setInt(1, id));
        return list.isEmpty() ? null : list.get(0);
    }

    /** Insert a new animal. Returns generated id. */
    public int insert(Livestock l) throws SQLException {
        String sql = "INSERT INTO livestock (tag, species, breed, gender, dob, current_value, status) " +
                     "VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, l.getTag());
            ps.setString(2, l.getSpecies());
            ps.setString(3, l.getBreed());
            ps.setString(4, l.getGender());
            if (l.getDob() != null) ps.setDate(5, l.getDob());
            else                    ps.setNull(5, Types.DATE);
            ps.setBigDecimal(6, l.getCurrentValue());
            ps.setString(7, l.getStatus() != null ? l.getStatus() : "Active");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    /** Update status only (used when marking Sold / Deceased). */
    public void updateStatus(int id, String status) throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE livestock SET status = ? WHERE id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /** Update current_value (called after a valuation is recorded). */
    public void updateValue(int id, java.math.BigDecimal value) throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE livestock SET current_value = ? WHERE id = ?")) {
            ps.setBigDecimal(1, value);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    /** Delete an animal by id. */
    public void delete(int id) throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement("DELETE FROM livestock WHERE id = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── count by status ───────────────────────────────────────
    public int countByStatus(String status) throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT COUNT(*) FROM livestock WHERE status = ?")) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ── Internal helpers ──────────────────────────────────────
    @FunctionalInterface
    interface PSetter { void set(PreparedStatement ps) throws SQLException; }

    private List<Livestock> query(String sql, PSetter setter) throws SQLException {
        List<Livestock> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setter.set(ps);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    private Livestock map(ResultSet rs) throws SQLException {
        Livestock l = new Livestock();
        l.setId(rs.getInt("id"));
        l.setTag(rs.getString("tag"));
        l.setSpecies(rs.getString("species"));
        l.setBreed(rs.getString("breed"));
        l.setGender(rs.getString("gender"));
        l.setDob(rs.getDate("dob"));
        l.setCurrentValue(rs.getBigDecimal("current_value"));
        l.setStatus(rs.getString("status"));
        l.setCreatedAt(rs.getTimestamp("created_at"));
        return l;
    }
}
