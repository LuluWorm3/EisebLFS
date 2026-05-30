package com.eiseb.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Expense {
    private int id;
    private String category;
    private BigDecimal amount;
    private Date expenseDate;
    private String description;
    private Integer livestockId;   // nullable
    private Timestamp createdAt;

    // Joined field
    private String livestockTag;

    public Expense() {}

    // ── Getters & Setters ──────────────────────────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public Date getExpenseDate() { return expenseDate; }
    public void setExpenseDate(Date expenseDate) { this.expenseDate = expenseDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getLivestockId() { return livestockId; }
    public void setLivestockId(Integer livestockId) { this.livestockId = livestockId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getLivestockTag() { return livestockTag; }
    public void setLivestockTag(String livestockTag) { this.livestockTag = livestockTag; }
}
