package com.eiseb.model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String fullName;
    private String username;
    private String email;
    private String password; // BCrypt hash
    private String role;
    private Timestamp createdAt;

    public User() {}

    public User(int id, String fullName, String username, String email, String role) {
        this.id = id;
        this.fullName = fullName;
        this.username = username;
        this.email = email;
        this.role = role;
    }

    // ── Getters & Setters ──────────────────────────────────────
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    /** Returns the initial (first letter of full name) for the avatar. */
    public String getInitial() {
        return (fullName != null && !fullName.isEmpty())
               ? String.valueOf(fullName.charAt(0)).toUpperCase()
               : "?";
    }
}
