package com.eiseb.dao;

import com.eiseb.model.Sale;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SaleDAO {

    private final ServletContext ctx;
    public SaleDAO(ServletContext ctx) { this.ctx = ctx; }

    public List<Sale> findAll() throws SQLException {
        String sql = "SELECT s.*, l.tag AS livestock_tag " +
                     "FROM sales s JOIN livestock l ON s.livestock_id = l.id " +
                     "ORDER BY s.sale_date DESC";
        List<Sale> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public int insert(Sale s) throws SQLException {
        String sql = "INSERT INTO sales (livestock_id, buyer, sale_type, sale_date, price, payment_status, notes) " +
                     "VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, s.getLivestockId());
            ps.setString(2, s.getBuyer());
            ps.setString(3, s.getSaleType());
            ps.setDate(4, s.getSaleDate());
            ps.setBigDecimal(5, s.getPrice());
            ps.setString(6, s.getPaymentStatus());
            ps.setString(7, s.getNotes());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    /** Total revenue from paid sales. */
    public BigDecimal totalPaidIncome() throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COALESCE(SUM(price),0) FROM sales WHERE payment_status = 'Paid'");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    public int countPaidSales() throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COUNT(*) FROM sales WHERE payment_status = 'Paid'");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    private Sale map(ResultSet rs) throws SQLException {
        Sale s = new Sale();
        s.setId(rs.getInt("id"));
        s.setLivestockId(rs.getInt("livestock_id"));
        s.setBuyer(rs.getString("buyer"));
        s.setSaleType(rs.getString("sale_type"));
        s.setSaleDate(rs.getDate("sale_date"));
        s.setPrice(rs.getBigDecimal("price"));
        s.setPaymentStatus(rs.getString("payment_status"));
        s.setNotes(rs.getString("notes"));
        s.setCreatedAt(rs.getTimestamp("created_at"));
        s.setLivestockTag(rs.getString("livestock_tag"));
        return s;
    }
}
