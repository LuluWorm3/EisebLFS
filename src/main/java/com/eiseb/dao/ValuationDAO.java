package com.eiseb.dao;

import com.eiseb.model.Valuation;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ValuationDAO {

    private final ServletContext ctx;
    public ValuationDAO(ServletContext ctx) { this.ctx = ctx; }

    public List<Valuation> findAll() throws SQLException {
        String sql = "SELECT v.*, l.tag AS livestock_tag, l.species AS livestock_species " +
                     "FROM valuations v JOIN livestock l ON v.livestock_id = l.id " +
                     "ORDER BY v.val_date DESC";
        List<Valuation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public int insert(Valuation v) throws SQLException {
        String sql = "INSERT INTO valuations (livestock_id, val_date, value, method, notes) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, v.getLivestockId());
            ps.setDate(2, v.getValDate());
            ps.setBigDecimal(3, v.getValue());
            ps.setString(4, v.getMethod());
            ps.setString(5, v.getNotes());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    private Valuation map(ResultSet rs) throws SQLException {
        Valuation v = new Valuation();
        v.setId(rs.getInt("id"));
        v.setLivestockId(rs.getInt("livestock_id"));
        v.setValDate(rs.getDate("val_date"));
        v.setValue(rs.getBigDecimal("value"));
        v.setMethod(rs.getString("method"));
        v.setNotes(rs.getString("notes"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        v.setLivestockTag(rs.getString("livestock_tag"));
        v.setLivestockSpecies(rs.getString("livestock_species"));
        return v;
    }
}
