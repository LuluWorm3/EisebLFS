<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>My Profile — Eiseb LFS</title><link rel="stylesheet" href="<%= cp %>/css/main.css"><style>body{display:flex;}.main{flex:1;}</style></head>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">My Profile</span></div>
    <div class="content">
        <h3>Update Profile</h3>
        <form method="post" action="<%= cp %>/profile">
            <input type="hidden" name="action" value="updateProfile">
            <div class="form-group"><label>Full Name</label><input type="text" name="fullName" value="<%= currentUser.getFullName() %>" required></div>
            <div class="form-group"><label>Email</label><input type="email" name="email" value="<%= currentUser.getEmail() %>" required></div>
            <button type="submit" class="btn btn-earth">Save Changes</button>
        </form>
        <hr>
        <h3>Change Password</h3>
        <form method="post" action="<%= cp %>/profile">
            <input type="hidden" name="action" value="changePassword">
            <div class="form-group"><label>Current Password</label><input type="password" name="oldPassword" required></div>
            <div class="form-group"><label>New Password</label><input type="password" name="newPassword" required></div>
            <button type="submit" class="btn btn-earth">Update Password</button>
        </form>
    </div>
</div>
<%@ include file="/WEB-INF/toast.jsp" %>
</body>
</html>
