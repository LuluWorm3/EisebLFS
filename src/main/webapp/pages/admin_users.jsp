<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Users — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;} .main{flex:1;}
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:200;align-items:center;justify-content:center;}
        .modal-overlay.open{display:flex!important;}
        .modal{background:#fff;border-radius:4px;width:500px;max-width:95vw;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);border-top:4px solid #D4A853;}
        .modal-header{padding:24px 28px 16px;border-bottom:1px solid #E8D9BE;display:flex;justify-content:space-between;align-items:center;}
        .modal-title{font-family:'Playfair Display',serif;font-size:18px;font-weight:700;color:#2C1A0E;}
        .modal-close{background:none;border:none;font-size:22px;cursor:pointer;color:#8A7560;}
        .modal-body{padding:24px 28px;}
        .modal-footer{padding:16px 28px;border-top:1px solid #E8D9BE;display:flex;gap:10px;justify-content:flex-end;}
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">Manage Users</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">All Users</div>
                <div class="section-sub"><%= users != null ? users.size() : 0 %> accounts</div>
            </div>
            <button class="btn btn-earth" onclick="openModal('addUserModal')">+ Add User</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>ID</th><th>Full Name</th><th>Username</th><th>Email</th><th>Role</th><th>Actions</th></tr></thead>
                <tbody>
                <% if (users == null || users.isEmpty()) { %>
                    <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:32px">No users found.</td></tr>
                <% } else {
                    User currentUser = (User) session.getAttribute("currentUser");
                    for (User u : users) { %>
                        <tr>
                            <td><%= u.getId() %></td>
                            <td><strong><%= u.getFullName() %></strong></td>
                            <td><%= u.getUsername() %></td>
                            <td><%= u.getEmail() %></td>
                            <td><span class="badge <%= "admin".equals(u.getRole()) ? "badge-red" : "badge-green" %>"><%= u.getRole() %></span></td>
                            <td style="display:flex;gap:6px;flex-wrap:wrap">
                                <button class="btn btn-sm btn-outline" onclick="editUser('<%= u.getId() %>','<%= u.getFullName() %>','<%= u.getEmail() %>','<%= u.getRole() %>')">Edit</button>
                                <% if (currentUser == null || currentUser.getId() != u.getId()) { %>
                                <form method="post" action="<%= cp %>/admin/users" style="display:inline"
                                      onsubmit="return confirm('Delete user <%= u.getUsername() %>?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= u.getId() %>">
                                    <button class="btn btn-sm btn-danger" type="submit">🗑</button>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                    <% }
                } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- Add User Modal --%>
<div class="modal-overlay" id="addUserModal" onclick="handleOverlayClick(event,'addUserModal')">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Add User</span>
            <button class="modal-close" onclick="closeModal('addUserModal')" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/admin/users">
            <input type="hidden" name="action" value="add">
            <div class="modal-body">
                <div class="form-group"><label>Full Name *</label><input type="text" name="fullName" required></div>
                <div class="form-group"><label>Username *</label><input type="text" name="username" required></div>
                <div class="form-group"><label>Email *</label><input type="email" name="email" required></div>
                <div class="form-group"><label>Password *</label><input type="password" name="password" required></div>
                <div class="form-group"><label>Role *</label>
                    <select name="role" required>
                        <option value="staff">Staff</option>
                        <option value="manager">Manager</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeModal('addUserModal')">Cancel</button>
                <button type="submit" class="btn btn-earth">Create User</button>
            </div>
        </form>
    </div>
</div>

<%-- Edit User Modal --%>
<div class="modal-overlay" id="editUserModal" onclick="handleOverlayClick(event,'editUserModal')">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Edit User</span>
            <button class="modal-close" onclick="closeModal('editUserModal')" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/admin/users">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="id" id="editUserId">
            <div class="modal-body">
                <div class="form-group"><label>Full Name</label><input type="text" name="fullName" id="editFullName" required></div>
                <div class="form-group"><label>Email</label><input type="email" name="email" id="editEmail" required></div>
                <div class="form-group"><label>Role</label>
                    <select name="role" id="editRole">
                        <option value="staff">Staff</option>
                        <option value="manager">Manager</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeModal('editUserModal')">Cancel</button>
                <button type="submit" class="btn btn-earth">Update User</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id){document.getElementById(id).classList.add('open');}
    function closeModal(id){document.getElementById(id).classList.remove('open');}
    function handleOverlayClick(e,id){if(e.target===document.getElementById(id))closeModal(id);}
    document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.modal-overlay.open').forEach(m=>m.classList.remove('open'));});

    function editUser(id, fullName, email, role) {
        document.getElementById('editUserId').value = id;
        document.getElementById('editFullName').value = fullName;
        document.getElementById('editEmail').value = email;
        document.getElementById('editRole').value = role;
        openModal('editUserModal');
    }
</script>
</body>
</html>