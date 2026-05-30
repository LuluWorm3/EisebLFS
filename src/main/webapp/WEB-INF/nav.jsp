<%@ page import="com.eiseb.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    String cp = request.getContextPath();
    String uri = request.getRequestURI();
%>
<div class="sidebar">
    <div class="sidebar-header">
        <div class="sidebar-brand">🐄 Eiseb Country Traders</div>
        <div class="sidebar-sub">Livestock Financial System</div>
    </div>
    <div class="sidebar-user">
        <div class="user-avatar"><%= currentUser != null ? currentUser.getInitial() : "?" %></div>
        <div>
            <div class="user-name"><%= currentUser != null ? currentUser.getFullName() : "Guest" %></div>
            <div class="user-role"><%= currentUser != null ? currentUser.getRole() : "" %></div>
        </div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section-label">Main</div>
        <a href="<%= cp %>/dashboard"  class="nav-item <%= uri.contains("/dashboard")  ? "active" : "" %>"><span class="nav-icon">📊</span> Dashboard</a>
        <a href="<%= cp %>/livestock"  class="nav-item <%= uri.contains("/livestock")  ? "active" : "" %>"><span class="nav-icon">🐄</span> Livestock Registry</a>
        <a href="<%= cp %>/valuations" class="nav-item <%= uri.contains("/valuations") ? "active" : "" %>"><span class="nav-icon">📋</span> Valuations</a>

        <div class="nav-section-label">Finance</div>
        <a href="<%= cp %>/sales"    class="nav-item <%= uri.contains("/sales")    ? "active" : "" %>"><span class="nav-icon">💰</span> Sales & Income</a>
        <a href="<%= cp %>/expenses" class="nav-item <%= uri.contains("/expenses") ? "active" : "" %>"><span class="nav-icon">🧾</span> Expenses</a>
        <a href="<%= cp %>/reports"  class="nav-item <%= uri.contains("/reports")  ? "active" : "" %>"><span class="nav-icon">📈</span> Financial Reports</a>

        <div class="nav-section-label">Support</div>
        <a href="<%= cp %>/contact" class="nav-item <%= uri.contains("/contact") ? "active" : "" %>"><span class="nav-icon">✉️</span> Contact Us</a>
    </nav>
    <div class="sidebar-footer">
        <form action="<%= cp %>/logout" method="post">
            <button class="btn-logout" type="submit">⬅ Sign Out</button>
        </form>
    </div>
</div>
