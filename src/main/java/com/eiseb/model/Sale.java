package com.eiseb.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Sale {
    private int id;
    private int livestockId;
    private String buyer;
    private String saleType;
    private Date saleDate;
    private BigDecimal price;
    private String paymentStatus;
    private String notes;
    private Timestamp createdAt;

    // Joined field (not in sales table directly)
    private String livestockTag;

    public Sale() {}

    // ── Getters & Setters ──────────────────────────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getLivestockId() { return livestockId; }
    public void setLivestockId(int livestockId) { this.livestockId = livestockId; }

    public String getBuyer() { return buyer; }
    public void setBuyer(String buyer) { this.buyer = buyer; }

    public String getSaleType() { return saleType; }
    public void setSaleType(String saleType) { this.saleType = saleType; }

    public Date getSaleDate() { return saleDate; }
    public void setSaleDate(Date saleDate) { this.saleDate = saleDate; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getLivestockTag() { return livestockTag; }
    public void setLivestockTag(String livestockTag) { this.livestockTag = livestockTag; }
}
