<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String cp = request.getContextPath();
%>
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>My Profile — Eiseb LFS</title>
<link rel="stylesheet" href="<%= cp %>/css/main.css">
<style>body{display:flex;}.main{flex:1;}</style>
</head><body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
  <div class="topbar"><span class="page-title">My Profile</span></div>
  <div class="content">
    <div class="full-card">
      <div class="card-header"><span class="card-title">Update Profile</span></div>
      <div style="padding:24px">
        <form method="post" action="<%= cp %>/profile">
          <input type="hidden" name="action" value="updateProfile">
          <div class="form-group"><label>Full Name</label><input type="text" name="fullName" value="<%= currentUser.getFullName() %>" required></div>
          <div class="form-group"><label>Email</label><input type="email" name="email" value="<%= currentUser.getEmail() %>" required></div>
          <button type="submit" class="btn btn-earth">Save Changes</button>
        </form>
      </div>
    </div>
    <div class="full-card" style="margin-top:20px">
      <div class="card-header"><span class="card-title">Change Password</span></div>
      <div style="padding:24px">
        <form method="post" action="<%= cp %>/profile">
          <input type="hidden" name="action" value="changePassword">
          <div class="form-group"><label>Current Password</label><input type="password" name="oldPassword" required></div>
          <div class="form-group"><label>New Password</label><input type="password" name="newPassword" required></div>
          <button type="submit" class="btn btn-earth">Update Password</button>
        </form>
      </div>
    </div>
  </div>
</div>
<%@ include file="/WEB-INF/toast.jsp" %>
</body></html>
