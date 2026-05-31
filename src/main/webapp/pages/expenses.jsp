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
    <style>
        body  { display: flex; margin: 0; }
        .main { flex: 1; min-width: 0; }

        #addModal { display:none; position:fixed; top:0;left:0;right:0;bottom:0; background:rgba(0,0,0,0.6); z-index:9999; }
        #addModal.open { display:block; }
        #addModal .modal-box {
            position:absolute; top:50%; left:50%; transform:translate(-50%,-50%);
            background:#fff; border-radius:4px; width:540px; max-width:92vw;
            max-height:90vh; overflow-y:auto;
            box-shadow:0 24px 64px rgba(0,0,0,0.35); border-top:4px solid #D4A853;
        }
        .modal-header { padding:22px 28px 14px; border-bottom:1px solid #E8D9BE; display:flex; justify-content:space-between; align-items:center; }
        .modal-title  { font-family:'Playfair Display',serif; font-size:18px; font-weight:700; color:#2C1A0E; }
        .modal-close  { background:none; border:none; font-size:24px; cursor:pointer; color:#8A7560; line-height:1; padding:0 4px; }
        .modal-body   { padding:22px 28px; }
        .modal-footer { padding:14px 28px; border-top:1px solid #E8D9BE; display:flex; gap:10px; justify-content:flex-end; }
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
            <button class="btn btn-earth" id="openAddBtn">+ Log Expense</button>
        </div>

        <form method="post" action="<%= cp %>/expenses" id="bulkDeleteForm">
            <input type="hidden" name="action" value="bulkDelete">
            <button type="button" class="btn btn-danger" onclick="if(confirm('Delete selected expenses?')) document.getElementById('bulkDeleteForm').submit();" style="margin-bottom:10px;">Delete Selected</button>
        </form>

        <input type="text" id="tableSearch" placeholder="Search..." style="margin-bottom:12px; padding:8px 12px; width:100%; max-width:300px; border:1px solid #D4A853; border-radius:4px;">

        <div class="full-card">
            <div class="table-responsive">
                <table>
                    <thead><tr><th></th><th>Date</th><th>Category</th><th>Description</th><th>Animal</th><th>Amount (N$)</th><th>Actions</th></tr></thead>
                    <tbody>
                    <% if (expenses == null || expenses.isEmpty()) { %>
                        <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:40px 0">No expenses recorded yet.</td></tr>
                    <% } else { for (Expense e : expenses) { %>
                        <tr>
                            <td><input type="checkbox" name="ids" value="<%= e.getId() %>" form="bulkDeleteForm"></td>
                            <td style="font-family:'DM Mono',monospace;font-size:12px"><%= e.getExpenseDate() %></td>
                            <td><span class="badge badge-gray"><%= e.getCategory() %></span></td>
                            <td><%= e.getDescription() != null ? e.getDescription() : "—" %></td>
                            <td><%= e.getLivestockTag() != null ? e.getLivestockTag() : "—" %></td>
                            <td><strong>N$&nbsp;<%= String.format("%,.2f", e.getAmount()) %></strong></td>
                            <td style="display:flex;gap:6px">
                                <button class="btn btn-sm btn-outline"
                                    onclick="openEditModal('<%= e.getId() %>','<%= e.getCategory() %>','<%= e.getAmount().toPlainString() %>','<%= e.getExpenseDate().toLocalDate().toString() %>','<%= e.getDescription() != null ? e.getDescription().replace("'","\\'") : "" %>','<%= e.getLivestockId() != null ? e.getLivestockId() : "" %>')">Edit</button>
                                <form method="post" action="<%= cp %>/expenses" style="display:inline"
                                      onsubmit="return confirm('Delete this expense?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id"     value="<%= e.getId() %>">
                                    <button class="btn btn-sm btn-danger" type="submit">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
            <div class="pagination"><%= expenses != null ? expenses.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title" id="modalTitle">Log Expense</span>
            <button class="modal-close" id="closeModalBtn" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/expenses">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id"     id="formId"     value="">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group"><label>Category *</label>
                        <select name="category" id="fCategory" required>
                            <option value="Feed">Feed</option>
                            <option value="Vet">Vet</option>
                            <option value="Transport">Transport</option>
                            <option value="Wages">Wages</option>
                            <option value="Equipment">Equipment</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="form-group"><label>Amount (N$) *</label><input type="number" name="amount" id="fAmount" step="0.01" min="0" required placeholder="0.00"></div>
                </div>
                <div class="form-group"><label>Expense Date *</label><input type="date" name="expenseDate" id="fDate" required></div>
                <div class="form-group"><label>Description</label><input type="text" name="description" id="fDesc" placeholder="Brief description..."></div>
                <div class="form-group"><label>Linked Animal (Optional)</label>
                    <select name="livestockId" id="fLivestock">
                        <option value="">— None —</option>
                        <% if (all != null) { for (Livestock l : all) { %>
                        <option value="<%= l.getId() %>"><%= l.getTag() %> — <%= l.getSpecies() %> [<%= l.getStatus() %>]</option>
                        <% }} %>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" id="cancelModalBtn">Cancel</button>
                <button type="submit" class="btn btn-earth"   id="submitBtn">Save Expense</button>
            </div>
        </form>
    </div>
</div>

<script>
var modal = document.getElementById('addModal');
function openModal()  { modal.classList.add('open');    document.body.style.overflow='hidden'; }
function closeModal() { modal.classList.remove('open'); document.body.style.overflow=''; }

document.getElementById('openAddBtn').addEventListener('click', function() {
    document.getElementById('modalTitle').textContent = 'Log Expense';
    document.getElementById('formAction').value = 'add';
    document.getElementById('formId').value = '';
    document.getElementById('fCategory').value = 'Feed';
    document.getElementById('fAmount').value = '';
    document.getElementById('fDate').value = '';
    document.getElementById('fDesc').value = '';
    document.getElementById('fLivestock').value = '';
    document.getElementById('submitBtn').textContent = 'Save Expense';
    openModal();
});

function openEditModal(id, category, amount, date, desc, livestockId) {
    document.getElementById('modalTitle').textContent = 'Edit Expense';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('formId').value = id;
    document.getElementById('fCategory').value = category;
    document.getElementById('fAmount').value = amount;
    document.getElementById('fDate').value = date;
    document.getElementById('fDesc').value = desc;
    document.getElementById('fLivestock').value = livestockId;
    document.getElementById('submitBtn').textContent = 'Update Expense';
    openModal();
}

document.getElementById('closeModalBtn').addEventListener('click', closeModal);
document.getElementById('cancelModalBtn').addEventListener('click', closeModal);
modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });

<% if (editExpense != null) { %>
openEditModal('<%= editExpense.getId() %>','<%= editExpense.getCategory() %>','<%= editExpense.getAmount().toPlainString() %>','<%= editExpense.getExpenseDate().toLocalDate().toString() %>','<%= editExpense.getDescription() != null ? editExpense.getDescription().replace("'","\\'") : "" %>','<%= editExpense.getLivestockId() != null ? editExpense.getLivestockId() : "" %>');
<% } %>
</script>

<script src="<%= cp %>/js/tables.js"></script>
<%@ include file="/WEB-INF/toast.jsp" %>
</body>
</html>
