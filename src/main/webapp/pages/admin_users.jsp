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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { display: flex; }
        .main { flex: 1; }

        /* ── Bulletproof Modal Styles ── */
        .modal-overlay {
            display: none; 
            position: fixed; 
            inset: 0;
            background: rgba(0,0,0,0.55); 
            z-index: 9999;
        }
        .modal-overlay.open {
            display: block !important;
        }
        .modal {
            position: absolute;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            background: #fff; 
            border-radius: 4px; 
            width: 500px;
            max-width: 95vw; 
            max-height: 90vh; 
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            border-top: 4px solid #D4A853;
        }
        .modal-header { 
            padding: 24px 28px 16px; 
            border-bottom: 1px solid #E8D9BE; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
        }
        .modal-title { 
            font-family: 'Playfair Display', serif; 
            font-size: 18px; 
            font-weight: 700; 
            color: #2C1A0E; 
        }
        .modal-close { 
            background: none; 
            border: none; 
            font-size: 22px; 
            cursor: pointer; 
            color: #8A7560; 
        }
        .modal-body { padding: 24px 28px; }
        .modal-footer { 
            padding: 16px 28px; 
            border-top: 1px solid #E8D9BE; 
            display: flex; 
            gap: 10px; 
            justify-content: flex-end; 
        }
        #tableSearch {
            margin-bottom: 12px;
            padding: 8px 12px;
            width: 100%;
            max-width: 300px;
            border: 1px solid #D4A853;
            border-radius: 4px;
        }
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
            <button class="btn btn-earth" id="btnAddUser">+ Add User</button>
        </div>

        <input type="text" id="tableSearch" placeholder="Search...">

        <div class="full-card">
            <div class="table-responsive">
<div class="table-responsive">
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
                                <button class="btn btn-sm btn-outline" onclick='editUser(<%= u.getId() %>,"<%= u.getFullName() %>","<%= u.getEmail() %>","<%= u.getRole() %>")'>Edit</button>
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
    </div>
</div>

<%-- Add User Modal --%>
<div class="modal-overlay" id="addUserModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Add User</span>
            <button class="modal-close" type="button">&times;</button>
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
                <button type="button" class="btn btn-outline cancel-btn">Cancel</button>
                <button type="submit" class="btn btn-earth">Create User</button>
            </div>
        </form>
    </div>
</div>

<%-- Edit User Modal --%>
<div class="modal-overlay" id="editUserModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Edit User</span>
            <button class="modal-close" type="button">&times;</button>
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
                <button type="button" class="btn btn-outline cancel-btn">Cancel</button>
                <button type="submit" class="btn btn-earth">Update User</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id) { 
        var m = document.getElementById(id);
        m.classList.add('open');
        document.body.style.overflow = 'hidden';
    }
    function closeModal(id) { 
        var m = document.getElementById(id);
        m.classList.remove('open');
        document.body.style.overflow = '';
    }

    document.getElementById('btnAddUser').addEventListener('click', function() { openModal('addUserModal'); });

    document.querySelectorAll('.modal-close').forEach(function(btn) {
        btn.addEventListener('click', function() {
            this.closest('.modal-overlay').classList.remove('open');
            document.body.style.overflow = '';
        });
    });

    document.querySelectorAll('.cancel-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            this.closest('.modal-overlay').classList.remove('open');
            document.body.style.overflow = '';
        });
    });

    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === overlay) {
                overlay.classList.remove('open');
                document.body.style.overflow = '';
            }
        });
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.open').forEach(function(m) {
                m.classList.remove('open');
            });
            document.body.style.overflow = '';
        }
    });

    function editUser(id, fullName, email, role) {
        document.getElementById('editUserId').value = id;
        document.getElementById('editFullName').value = fullName;
        document.getElementById('editEmail').value = email;
        document.getElementById('editRole').value = role;
        openModal('editUserModal');
    }

    var searchInput = document.getElementById('tableSearch');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            var filter = this.value.toUpperCase();
            var rows = document.querySelectorAll('table tbody tr');
            rows.forEach(function(row) {
                var text = row.textContent.toUpperCase();
                row.style.display = text.indexOf(filter) > -1 ? '' : 'none';
            });
        });
    }
</script>
<script>
document.querySelectorAll('table thead th').forEach(function(th, colIndex) {
    th.style.cursor = 'pointer';
    th.addEventListener('click', function() {
        var table = th.closest('table');
        var tbody = table.querySelector('tbody');
        var rows = Array.from(tbody.querySelectorAll('tr'));
        var ascending = th.classList.contains('sorted-asc');
        // Reset all headers
        table.querySelectorAll('th').forEach(function(h) { h.classList.remove('sorted-asc', 'sorted-desc'); });
        // Toggle direction
        th.classList.add(ascending ? 'sorted-desc' : 'sorted-asc');
        rows.sort(function(a, b) {
            var aVal = a.cells[colIndex].textContent.trim().toLowerCase();
            var bVal = b.cells[colIndex].textContent.trim().toLowerCase();
            // Try numeric
            var aNum = parseFloat(aVal.replace(/[^0-9.-]/g, ''));
            var bNum = parseFloat(bVal.replace(/[^0-9.-]/g, ''));
            if (!isNaN(aNum) && !isNaN(bNum)) {
                return ascending ? (bNum - aNum) : (aNum - bNum);
            }
            return ascending ? bVal.localeCompare(aVal) : aVal.localeCompare(bVal);
        });
        rows.forEach(function(row) { tbody.appendChild(row); });
    });
});
</script>
<%@ include file="/WEB-INF/toast.jsp" %>
</body>
</html>
