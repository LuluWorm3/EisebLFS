package com.eiseb.dao;

import com.eiseb.model.Expense;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ExpenseDAO {

    private final ServletContext ctx;
    public ExpenseDAO(ServletContext ctx) { this.ctx = ctx; }

    public List<Expense> findAll() throws SQLException {
        String sql = "SELECT e.*, l.tag AS livestock_tag " +
                     "FROM expenses e LEFT JOIN livestock l ON e.livestock_id = l.id " +
                     "ORDER BY e.expense_date DESC";
        List<Expense> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public int insert(Expense e) throws SQLException {
        String sql = "INSERT INTO expenses (category, amount, expense_date, description, livestock_id) " +
                     "VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, e.getCategory());
            ps.setBigDecimal(2, e.getAmount());
            ps.setDate(3, e.getExpenseDate());
            ps.setString(4, e.getDescription());
            if (e.getLivestockId() != null) ps.setInt(5, e.getLivestockId());
            else                             ps.setNull(5, Types.INTEGER);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }

    /** Total of all expenses. */
    public BigDecimal totalExpenses() throws SQLException {
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT COALESCE(SUM(amount),0) FROM expenses");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        }
    }

    /** Totals grouped by category — used in reports chart. */
    public List<Object[]> sumByCategory() throws SQLException {
        String sql = "SELECT category, SUM(amount) AS total FROM expenses GROUP BY category ORDER BY total DESC";
        List<Object[]> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(ctx);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new Object[]{ rs.getString("category"), rs.getBigDecimal("total") });
            }
        }
        return rows;
    }

    private Expense map(ResultSet rs) throws SQLException {
        Expense e = new Expense();
        e.setId(rs.getInt("id"));
        e.setCategory(rs.getString("category"));
        e.setAmount(rs.getBigDecimal("amount"));
        e.setExpenseDate(rs.getDate("expense_date"));
        e.setDescription(rs.getString("description"));
        int lid = rs.getInt("livestock_id");
        e.setLivestockId(rs.wasNull() ? null : lid);
        e.setCreatedAt(rs.getTimestamp("created_at"));
        e.setLivestockTag(rs.getString("livestock_tag"));
        return e;
    }
}
