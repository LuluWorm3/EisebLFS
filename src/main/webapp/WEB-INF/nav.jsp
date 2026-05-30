<%@ page pageEncoding="UTF-8" %>
<%@ page import="com.eiseb.model.User" %>
<%
    User navUser = (User) session.getAttribute("currentUser");
    String navCp = request.getContextPath();
    String navUri = request.getRequestURI();
%>
<!-- Hamburger toggle (visible on mobile) -->
<button class="hamburger" id="hamburgerBtn" aria-label="Menu">☰</button>

<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="sidebar-brand">&#x1F404; Eiseb Country Traders</div>
        <div class="sidebar-sub">Livestock Financial System</div>
    </div>
    <div class="sidebar-user">
        <div class="user-avatar"><%= navUser != null ? navUser.getFullName().substring(0,1).toUpperCase() : "?" %></div>
        <div>
            <div class="user-name"><%= navUser != null ? navUser.getFullName() : "Guest" %></div>
            <div class="user-role"><%= navUser != null ? navUser.getRole() : "" %></div>
        </div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section-label">Main</div>
        <a href="<%= navCp %>/dashboard"  class="nav-item <%= navUri.contains("/dashboard")  ? "active" : "" %>"><span class="nav-icon">&#x1F4CA;</span> Dashboard</a>
        <a href="<%= navCp %>/livestock"  class="nav-item <%= navUri.contains("/livestock")  ? "active" : "" %>"><span class="nav-icon">&#x1F404;</span> Livestock Registry</a>
        <a href="<%= navCp %>/valuations" class="nav-item <%= navUri.contains("/valuations") ? "active" : "" %>"><span class="nav-icon">&#x1F4CB;</span> Valuations</a>

        <div class="nav-section-label">Finance</div>
        <a href="<%= navCp %>/sales"    class="nav-item <%= navUri.contains("/sales")    ? "active" : "" %>"><span class="nav-icon">&#x1F4B0;</span> Sales & Income</a>
        <a href="<%= navCp %>/expenses" class="nav-item <%= navUri.contains("/expenses") ? "active" : "" %>"><span class="nav-icon">&#x1F9FE;</span> Expenses</a>
        <a href="<%= navCp %>/reports"  class="nav-item <%= navUri.contains("/reports")  ? "active" : "" %>"><span class="nav-icon">&#x1F4C8;</span> Financial Reports</a>

        <div class="nav-section-label">Support</div>
        <a href="<%= navCp %>/profile" class="nav-item <%= navUri.contains("/profile") ? "active" : "" %>"><span class="nav-icon">&#x1F464;</span> My Profile</a>
        <a href="<%= navCp %>/contact" class="nav-item <%= navUri.contains("/contact") ? "active" : "" %>"><span class="nav-icon">&#x2709;&#xFE0F;</span> Contact Us</a>

        <% if (navUser != null && "admin".equals(navUser.getRole())) { %>
        <div class="nav-section-label">Administration</div>
        <a href="<%= navCp %>/admin/users" class="nav-item <%= navUri.contains("/admin/users") ? "active" : "" %>"><span class="nav-icon">&#x1F465;</span> Manage Users</a>
        <% } %>
    </nav>
    <div class="sidebar-footer">
        <form action="<%= navCp %>/logout" method="post">
            <button class="btn-logout" type="submit">&#x2B05; Sign Out</button>
        </form>
    </div>
</div>

<script>
(function() {
    var btn = document.getElementById('hamburgerBtn');
    var sidebar = document.getElementById('sidebar');
    if (btn && sidebar) {
        btn.addEventListener('click', function() {
            sidebar.classList.toggle('open');
        });
        sidebar.querySelectorAll('a').forEach(function(link) {
            link.addEventListener('click', function() {
                sidebar.classList.remove('open');
            });
        });
    }
})();
</script>
