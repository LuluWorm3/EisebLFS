<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Expense>   expenses     = (List<Expense>)   request.getAttribute("expenses");
    List<Livestock> all          = (List<Livestock>) request.getAttribute("allLivestock");
    Expense editExpense          = (Expense) request.getAttribute("editExpense");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Expenses — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;} .main{flex:1;}
        .modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:200;align-items:center;justify-content:center;}
        .modal-overlay.open{display:flex!important;}
        .modal{background:#fff;border-radius:4px;width:520px;max-width:95vw;max-height:90vh;overflow-y:auto;box-shadow:0 20px 60px rgba(0,0,0,0.3);border-top:4px solid #D4A853;}
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
    <div class="topbar"><span class="page-title">Expenses</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Expense Records</div>
                <div class="section-sub"><%= expenses != null ? expenses.size() : 0 %> entries</div>
            </div>
            <button class="btn btn-earth" onclick="openModal('addModal')">+ Log Expense</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Category</th><th>Description</th><th>Animal</th><th>Amount (N$)</th><th>Actions</th></tr></thead>
                <tbody>
                <% if (expenses == null || expenses.isEmpty()) { %>
                    <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:32px">No expenses recorded yet.</td></tr>
                <% } else { for (Expense e : expenses) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= e.getExpenseDate() %></td>
                        <td><span class="badge badge-gray"><%= e.getCategory() %></span></td>
                        <td><%= e.getDescription() != null ? e.getDescription() : "—" %></td>
                        <td><%= e.getLivestockTag() != null ? e.getLivestockTag() : "—" %></td>
                        <td><strong>N$&nbsp;<%= String.format("%,.2f", e.getAmount()) %></strong></td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <form method="get" action="<%= cp %>/expenses" style="display:inline">
                                <input type="hidden" name="action" value="editForm">
                                <input type="hidden" name="id" value="<%= e.getId() %>">
                                <button class="btn btn-sm btn-outline" type="submit">Edit</button>
                            </form>
                            <form method="post" action="<%= cp %>/expenses" style="display:inline"
                                  onsubmit="return confirm('Delete this expense?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= e.getId() %>">
                                <button class="btn btn-sm btn-danger" type="submit">🗑</button>
                            </form>
                        </td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= expenses != null ? expenses.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<%-- Add / Edit Modal --%>
<div class="modal-overlay" id="addModal" onclick="handleOverlayClick(event,'addModal')">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title"><%= editExpense != null ? "Edit Expense" : "Log Expense" %></span>
            <button class="modal-close" onclick="closeModal('addModal')" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/expenses">
            <input type="hidden" name="action" value="<%= editExpense != null ? "edit" : "add" %>">
            <% if (editExpense != null) { %>
                <input type="hidden" name="id" value="<%= editExpense.getId() %>">
            <% } %>
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group">
                        <label>Category *</label>
                        <select name="category" required>
                            <option value="Feed" <%= editExpense != null && "Feed".equals(editExpense.getCategory()) ? "selected" : "" %>>Feed</option>
                            <option value="Vet" <%= editExpense != null && "Vet".equals(editExpense.getCategory()) ? "selected" : "" %>>Vet</option>
                            <option value="Transport" <%= editExpense != null && "Transport".equals(editExpense.getCategory()) ? "selected" : "" %>>Transport</option>
                            <option value="Wages" <%= editExpense != null && "Wages".equals(editExpense.getCategory()) ? "selected" : "" %>>Wages</option>
                            <option value="Equipment" <%= editExpense != null && "Equipment".equals(editExpense.getCategory()) ? "selected" : "" %>>Equipment</option>
                            <option value="Other" <%= editExpense != null && "Other".equals(editExpense.getCategory()) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Amount (N$) *</label>
                        <input type="number" name="amount" step="0.01" min="0" required placeholder="0.00"
                               value="<%= editExpense != null ? editExpense.getAmount().toString() : "" %>">
                    </div>
                </div>
                <div class="form-group">
                    <label>Expense Date *</label>
                    <input type="date" name="expenseDate" required
                           value="<%= editExpense != null ? editExpense.getExpenseDate().toLocalDate().toString() : "" %>">
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <input type="text" name="description" placeholder="Brief description..."
                           value="<%= editExpense != null && editExpense.getDescription() != null ? editExpense.getDescription() : "" %>">
                </div>
                <div class="form-group">
                    <label>Linked Animal (Optional)</label>
                    <select name="livestockId">
                        <option value="">— None —</option>
                        <% if (all != null) { for (Livestock l : all) {
                            String sel = (editExpense != null && editExpense.getLivestockId() != null && editExpense.getLivestockId() == l.getId()) ? "selected" : "";
                        %>
                            <option value="<%= l.getId() %>" <%= sel %>><%= l.getTag() %> — <%= l.getSpecies() %> [<%= l.getStatus() %>]</option>
                        <% }} %>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeModal('addModal')">Cancel</button>
                <button type="submit" class="btn btn-earth"><%= editExpense != null ? "Update Expense" : "Save Expense" %></button>
            </div>
        </form>
    </div>
</div>
<script>
    function openModal(id){document.getElementById(id).classList.add('open');}
    function closeModal(id){document.getElementById(id).classList.remove('open');}
    function handleOverlayClick(e,id){if(e.target===document.getElementById(id))closeModal(id);}
    document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.modal-overlay.open').forEach(m=>m.classList.remove('open'));});
    <% if (editExpense != null) { %> openModal('addModal'); <% } %>
</script>
</body>
</html>