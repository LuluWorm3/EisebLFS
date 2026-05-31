<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Help — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;}.main{flex:1;}</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">Help & User Manual</span></div>
    <div class="content">
        <h2>Getting Started</h2>
        <p>Welcome to the Eiseb Livestock Financial System. Here’s how to use each section:</p>
        
        <h3>Dashboard</h3>
        <p>Shows a summary of your farm’s financials: total income, expenses, net position, active livestock, and profit margin. The pie chart breaks down expenses by category.</p>
        
        <h3>Livestock Registry</h3>
        <p>View, add, edit, and delete animals. You can search, sort, and bulk‑delete. Click a column header to sort. Use the filter tabs (All, Active, Sold, Deceased) to see animals by status.</p>
        
        <h3>Valuations</h3>
        <p>Record valuations for animals to track their current value over time. Each valuation updates the animal’s current value automatically.</p>
        
        <h3>Sales & Income</h3>
        <p>Manage all sales. Add a new sale with buyer details, sale type, and payment status. Paid sales will mark the animal as Sold.</p>
        
        <h3>Expenses</h3>
        <p>Log expenses by category (Feed, Vet, Transport, etc.). You can optionally link an expense to a specific animal.</p>
        
        <h3>Financial Reports</h3>
        <p>View detailed summaries, filter by date range, and export CSV files of your data.</p>
        
        <h3>My Profile</h3>
        <p>Update your full name, email, and password. You must enter your current password to change it.</p>
        
        <h3>Manage Users (Admin only)</h3>
        <p>Admins can add, edit, and delete user accounts. Assign roles: admin, manager, or staff.</p>
        
        <h3>Audit Log (Admin only)</h3>
        <p>View a record of all create, update, and delete actions performed in the system.</p>
        
        <h3>Contact Us</h3>
        <p>Send an enquiry to the farm office. Logged‑in users can also view past enquiries.</p>
        
        <h2>Tips</h2>
        <ul>
            <li>Use the <strong>search bar</strong> above any table to find specific records quickly.</li>
            <li>Click any table header to <strong>sort</strong> that column.</li>
            <li>To delete multiple records, select their checkboxes and click <strong>Delete Selected</strong>.</li>
            <li>On mobile, you can swipe tables horizontally to see all columns.</li>
        </ul>
    </div>
</div>
</body>
</html>
