<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Valuation> valuations = (List<Valuation>) request.getAttribute("valuations");
    List<Livestock> active     = (List<Livestock>) request.getAttribute("activeLivestock");
    Valuation editValuation    = (Valuation) request.getAttribute("editValuation");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Valuations — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>
        body  { display: flex; margin: 0; }
        .main { flex: 1; min-width: 0; }

        #addModal { display: none; position: fixed; top:0;left:0;right:0;bottom:0; background:rgba(0,0,0,0.6); z-index:9999; }
        #addModal.open { display: block; }
        #addModal .modal-box {
            position: absolute; top:50%; left:50%; transform:translate(-50%,-50%);
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
    <div class="topbar"><span class="page-title">Valuations</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Valuation History</div>
                <div class="section-sub">Track current value changes per animal</div>
            </div>
            <button class="btn btn-earth" id="openAddBtn">+ Record Valuation</button>
        </div>

        <div class="full-card">
<input type="text" id="tableSearch" placeholder="Search..." style="margin-bottom:12px; padding:8px 12px; width:100%; max-width:300px; border:1px solid #D4A853; border-radius:4px;">
            <table>
                <thead><tr><th>Date</th><th>Tag</th><th>Species</th><th>Value (N$)</th><th>Method</th><th>Notes</th><th>Actions</th></tr></thead>
                <tbody>
                <% if (valuations == null || valuations.isEmpty()) { %>
                    <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:40px 0">No valuations recorded yet. Click <strong>+ Record Valuation</strong> to start.</td></tr>
                <% } else { for (Valuation v : valuations) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= v.getValDate() %></td>
                        <td><strong style="font-family:'DM Mono',monospace"><%= v.getLivestockTag() %></strong></td>
                        <td><%= v.getLivestockSpecies() %></td>
                        <td><strong>N$&nbsp;<%= String.format("%,.2f", v.getValue()) %></strong></td>
                        <td><%= v.getMethod()  != null ? v.getMethod()  : "—" %></td>
                        <td><%= v.getNotes()   != null ? v.getNotes()   : "—" %></td>
                        <td style="display:flex;gap:6px">
                            <button class="btn btn-sm btn-outline"
                                onclick="openEditModal(
                                    '<%= v.getId() %>',
                                    '<%= v.getLivestockId() %>',
                                    '<%= v.getValDate().toLocalDate().toString() %>',
                                    '<%= v.getValue().toPlainString() %>',
                                    '<%= v.getMethod() != null ? v.getMethod().replace("'","\\'") : "" %>',
                                    '<%= v.getNotes()  != null ? v.getNotes().replace("'","\\'")  : "" %>'
                                )">Edit</button>
                            <form method="post" action="<%= cp %>/valuations" style="display:inline"
                                  onsubmit="return confirm('Delete this valuation?')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id"     value="<%= v.getId() %>">
                                <button class="btn btn-sm btn-danger" type="submit">🗑</button>
                            </form>
                        </td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= valuations != null ? valuations.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title" id="modalTitle">Record Valuation</span>
            <button class="modal-close" id="closeModalBtn" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/valuations">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id"     id="formId"     value="">
            <div class="modal-body">
                <div class="form-group">
                    <label>Animal *</label>
                    <select name="livestockId" id="fLivestock" required>
                        <option value="">Select animal...</option>
                        <% if (active != null) { for (Livestock l : active) { %>
                        <option value="<%= l.getId() %>">
                            <%= l.getTag() %> — <%= l.getSpecies() %> (<%= l.getBreed() != null ? l.getBreed() : "Unknown" %>)
                        </option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Valuation Date *</label>
                        <input type="date" name="valDate" id="fDate" required>
                    </div>
                    <div class="form-group">
                        <label>Value (N$) *</label>
                        <input type="number" name="value" id="fValue" step="0.01" min="0" required placeholder="0.00">
                    </div>
                </div>
                <div class="form-group">
                    <label>Method</label>
                    <input type="text" name="method" id="fMethod" placeholder="e.g. Market Survey, Vet Assessment">
                </div>
                <div class="form-group">
                    <label>Notes</label>
                    <textarea name="notes" id="fNotes" rows="3" placeholder="Additional notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" id="cancelModalBtn">Cancel</button>
                <button type="submit" class="btn btn-earth"   id="submitBtn">Save Valuation</button>
            </div>
        </form>
    </div>
</div>

<script>
var modal = document.getElementById('addModal');
function openModal()  { modal.classList.add('open');    document.body.style.overflow='hidden'; }
function closeModal() { modal.classList.remove('open'); document.body.style.overflow=''; }

document.getElementById('openAddBtn').addEventListener('click', function() {
    document.getElementById('modalTitle').textContent = 'Record Valuation';
    document.getElementById('formAction').value = 'add';
    document.getElementById('formId').value     = '';
    document.getElementById('fLivestock').value = '';
    document.getElementById('fDate').value      = '';
    document.getElementById('fValue').value     = '';
    document.getElementById('fMethod').value    = '';
    document.getElementById('fNotes').value     = '';
    document.getElementById('submitBtn').textContent = 'Save Valuation';
    openModal();
});

function openEditModal(id, livestockId, date, value, method, notes) {
    document.getElementById('modalTitle').textContent = 'Edit Valuation';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('formId').value     = id;
    document.getElementById('fLivestock').value = livestockId;
    document.getElementById('fDate').value      = date;
    document.getElementById('fValue').value     = value;
    document.getElementById('fMethod').value    = method;
    document.getElementById('fNotes').value     = notes;
    document.getElementById('submitBtn').textContent = 'Update Valuation';
    openModal();
}

document.getElementById('closeModalBtn').addEventListener('click',  closeModal);
document.getElementById('cancelModalBtn').addEventListener('click', closeModal);
modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });

<% if (editValuation != null) { %>
openEditModal(
    '<%= editValuation.getId() %>',
    '<%= editValuation.getLivestockId() %>',
    '<%= editValuation.getValDate().toLocalDate().toString() %>',
    '<%= editValuation.getValue().toPlainString() %>',
    '<%= editValuation.getMethod() != null ? editValuation.getMethod().replace("'","\\'") : "" %>',
    '<%= editValuation.getNotes()  != null ? editValuation.getNotes().replace("'","\\'")  : "" %>'
);
<% } %>
</script>
<script>document.getElementById("tableSearch").addEventListener("keyup",function(){var f=this.value.toUpperCase();document.querySelectorAll("table tbody tr").forEach(function(r){r.style.display=r.textContent.toUpperCase().indexOf(f)>-1?"":"none";});});</script>
</body>
</html>
