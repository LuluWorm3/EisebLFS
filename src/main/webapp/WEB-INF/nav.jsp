<%@ include file="/WEB-INF/head_scripts.jsp" %>
<%@ page pageEncoding="UTF-8" %>
<%@ page import="com.eiseb.model.User" %>
<%
    User navUser = (User) session.getAttribute("currentUser");
    String navCp = request.getContextPath();
    String navUri = request.getRequestURI();
%>
<button class="hamburger" id="hamburgerBtn" aria-label="Menu">☰</button>

<div class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="sidebar-brand">Eiseb Country Traders</div>
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
        <a href="<%= navCp %>/dashboard"  class="nav-item <%= navUri.contains("/dashboard")  ? "active" : "" %>">Dashboard</a>
        <a href="<%= navCp %>/livestock"  class="nav-item <%= navUri.contains("/livestock")  ? "active" : "" %>">Livestock Registry</a>
        <a href="<%= navCp %>/valuations" class="nav-item <%= navUri.contains("/valuations") ? "active" : "" %>">Valuations</a>

        <div class="nav-section-label">Finance</div>
        <a href="<%= navCp %>/sales"    class="nav-item <%= navUri.contains("/sales")    ? "active" : "" %>">Sales & Income</a>
        <a href="<%= navCp %>/expenses" class="nav-item <%= navUri.contains("/expenses") ? "active" : "" %>">Expenses</a>
        <a href="<%= navCp %>/reports"  class="nav-item <%= navUri.contains("/reports")  ? "active" : "" %>">Financial Reports</a>

        <div class="nav-section-label">Support</div>
        <a href="<%= navCp %>/profile" class="nav-item <%= navUri.contains("/profile") ? "active" : "" %>">My Profile</a>
        <a href="<%= navCp %>/help" class="nav-item <%= navUri.contains("/help") ? "active" : "" %>">Help</a>
        <a href="<%= navCp %>/contact" class="nav-item <%= navUri.contains("/contact") ? "active" : "" %>">Contact Us</a>

        <% if (navUser != null && "admin".equals(navUser.getRole())) { %>
        <div class="nav-section-label">Administration</div>
        <a href="<%= navCp %>/admin/users" class="nav-item <%= navUri.contains("/admin/users") ? "active" : "" %>">Manage Users</a>
        <a href="<%= navCp %>/admin/enquiries" class="nav-item <%= navUri.contains("/admin/enquiries") ? "active" : "" %>">Enquiries</a>
        <a href="<%= navCp %>/admin/audit" class="nav-item <%= navUri.contains("/admin/audit") ? "active" : "" %>">Audit Log</a>
        <% } %>
    </nav>
    <div class="sidebar-footer">
        <form action="<%= navCp %>/logout" method="post">
            <button class="btn-logout" type="submit">Sign Out</button>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
