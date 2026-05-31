<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<String[]> logs = (List<String[]>) request.getAttribute("logs");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Audit Log — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>
        body  { display: flex; }
        .main { flex: 1; }
        #tableSearch {
            margin-bottom: 12px;
            padding: 8px 12px;
            width: 100%;
            max-width: 320px;
            border: 1px solid #D4A853;
            border-radius: 4px;
            font-family: 'Inter', sans-serif;
        }
        .log-detail {
            max-width: 200px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .badge-action {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            color: #fff;
        }
        .action-INSERT { background: #2E7D32; }
        .action-UPDATE { background: #E65100; }
        .action-DELETE { background: #C62828; }
        .action-STATUS { background: #6A1B9A; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">Audit Log</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Recent Activity</div>
                <div class="section-sub"><%= logs != null ? logs.size() : 0 %> entries</div>
            </div>
            <button class="btn btn-sm btn-outline" onclick="window.location.reload()">Refresh</button>
        </div>

        <input type="text" id="tableSearch" placeholder="Search by user, action, entity...">

        <div class="full-card">
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>User</th>
                            <th>Action</th>
                            <th>Entity</th>
                            <th>Entity ID</th>
                            <th>Details</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (logs == null || logs.isEmpty()) { %>
                        <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:40px 0">No activity recorded yet.</td></tr>
                    <% } else {
                        for (String[] log : logs) { %>
                            <tr>
                                <td><strong><%= log[0] %></strong></td>
                                <td><span class="badge-action action-<%= log[1] %>"><%= log[1] %></span></td>
                                <td><%= log[2] %></td>
                                <td><%= log[3] %></td>
                                <td class="log-detail" title="<%= log[4] %>"><%= log[4] %></td>
                                <td style="font-family:'DM Mono',monospace;font-size:12px"><%= log[5] %></td>
                            </tr>
                        <% }
                    } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="<%= cp %>/js/tables.js"></script>
</body>
</html>
