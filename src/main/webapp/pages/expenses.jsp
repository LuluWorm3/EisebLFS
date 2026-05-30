<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Expense>   expenses = (List<Expense>)   request.getAttribute("expenses");
    List<Livestock> all      = (List<Livestock>) request.getAttribute("allLivestock");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Expenses — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;} .main{flex:1;}</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">Expenses</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Expense Records</div>
                <div class="section-sub"><%= expenses != null ? expenses.size() : 0 %> entries</div>
            </div>
            <button class="btn btn-earth" onclick="document.getElementById('addModal').classList.add('open')">+ Log Expense</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Category</th><th>Description</th><th>Animal</th><th>Amount (N$)</th></tr></thead>
                <tbody>
                <% if (expenses == null || expenses.isEmpty()) { %>
                    <tr><td colspan="5" style="text-align:center;color:var(--muted);padding:32px">No expenses recorded yet.</td></tr>
                <% } else { for (Expense e : expenses) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= e.getExpenseDate() %></td>
                        <td><span class="badge badge-gray"><%= e.getCategory() %></span></td>
                        <td><%= e.getDescription() != null ? e.getDescription() : "—" %></td>
                        <td><%= e.getLivestockTag() != null ? e.getLivestockTag() : "—" %></td>
                        <td><strong>N$&nbsp;<%= String.format("%,.2f", e.getAmount()) %></strong></td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= expenses != null ? expenses.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Log Expense</span>
            <button class="modal-close" onclick="document.getElementById('addModal').classList.remove('open')">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/expenses">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group">
                        <label>Category *</label>
                        <select name="category" required>
                            <option value="Feed">Feed</option>
                            <option value="Vet">Vet</option>
                            <option value="Transport">Transport</option>
                            <option value="Wages">Wages</option>
                            <option value="Equipment">Equipment</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Amount (N$) *</label>
                        <input type="number" name="amount" step="0.01" min="0" required placeholder="0.00">
                    </div>
                </div>
                <div class="form-group">
                    <label>Expense Date *</label>
                    <input type="date" name="expenseDate" required>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <input type="text" name="description" placeholder="Brief description...">
                </div>
                <div class="form-group">
                    <label>Linked Animal (Optional)</label>
                    <select name="livestockId">
                        <option value="">— None —</option>
                        <% if (all != null) { for (Livestock l : all) { %>
                            <option value="<%= l.getId() %>"><%= l.getTag() %> — <%= l.getSpecies() %> [<%= l.getStatus() %>]</option>
                        <% }} %>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="document.getElementById('addModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-earth">Save Expense</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
