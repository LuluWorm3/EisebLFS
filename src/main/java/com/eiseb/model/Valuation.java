package com.eiseb.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

public class Valuation {
    private int id;
    private int livestockId;
    private Date valDate;
    private BigDecimal value;
    private String method;
    private String notes;
    private Timestamp createdAt;

    // Joined fields
    private String livestockTag;
    private String livestockSpecies;

    public Valuation() {}

    // ── Getters & Setters ──────────────────────────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getLivestockId() { return livestockId; }
    public void setLivestockId(int livestockId) { this.livestockId = livestockId; }

    public Date getValDate() { return valDate; }
    public void setValDate(Date valDate) { this.valDate = valDate; }

    public BigDecimal getValue() { return value; }
    public void setValue(BigDecimal value) { this.value = value; }

    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getLivestockTag() { return livestockTag; }
    public void setLivestockTag(String livestockTag) { this.livestockTag = livestockTag; }

    public String getLivestockSpecies() { return livestockSpecies; }
    public void setLivestockSpecies(String livestockSpecies) { this.livestockSpecies = livestockSpecies; }
}
