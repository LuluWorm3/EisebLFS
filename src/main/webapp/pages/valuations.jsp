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

        .searchable-select { position: relative; }
        .searchable-select input { width: 100%; padding: 8px; border: 1px solid #D4A853; border-radius: 4px; }
        .dropdown-list { position: absolute; top: 100%; left: 0; right: 0; max-height: 200px; overflow-y: auto; background: #fff; border: 1px solid #D4A853; border-top: none; border-radius: 0 0 4px 4px; z-index: 1000; display: none; }
        .dropdown-list.open { display: block; }
        .dropdown-item { padding: 8px 12px; cursor: pointer; font-size: 13px; }
        .dropdown-item:hover { background: #F5E6CC; }
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

        <form method="post" action="<%= cp %>/valuations" id="bulkDeleteForm">
            <input type="hidden" name="action" value="bulkDelete">
            <button type="button" class="btn btn-danger" onclick="if(confirm('Delete selected valuations?')) document.getElementById('bulkDeleteForm').submit();" style="margin-bottom:10px;">Delete Selected</button>
        </form>

        <input type="text" id="tableSearch" placeholder="Search..." style="margin-bottom:12px; padding:8px 12px; width:100%; max-width:300px; border:1px solid #D4A853; border-radius:4px;">

        <div class="full-card">
            <div class="table-responsive">
                <table>
                    <thead><tr><th></th><th>Date</th><th>Tag</th><th>Species</th><th>Value (N$)</th><th>Method</th><th>Notes</th><th>Actions</th></tr></thead>
                    <tbody>
                    <% if (valuations == null || valuations.isEmpty()) { %>
                        <tr><td colspan="8" style="text-align:center;color:var(--muted);padding:40px 0">No valuations recorded yet.</td></tr>
                    <% } else { for (Valuation v : valuations) { %>
                        <tr>
                            <td><input type="checkbox" name="ids" value="<%= v.getId() %>" form="bulkDeleteForm"></td>
                            <td style="font-family:'DM Mono',monospace;font-size:12px"><%= v.getValDate() %></td>
                            <td><strong style="font-family:'DM Mono',monospace"><%= v.getLivestockTag() %></strong></td>
                            <td><%= v.getLivestockSpecies() %></td>
                            <td><strong>N$&nbsp;<%= String.format("%,.2f", v.getValue()) %></strong></td>
                            <td><%= v.getMethod() != null ? v.getMethod() : "—" %></td>
                            <td><%= v.getNotes()  != null ? v.getNotes()  : "—" %></td>
                            <td style="display:flex;gap:6px">
                                <button class="btn btn-sm btn-outline"
                                    onclick="openEditModal('<%= v.getId() %>','<%= v.getLivestockId() %>','<%= v.getValDate().toLocalDate().toString() %>','<%= v.getValue().toPlainString() %>','<%= v.getMethod() != null ? v.getMethod().replace("'","\\'") : "" %>','<%= v.getNotes()  != null ? v.getNotes().replace("'","\\'")  : "" %>')">Edit</button>
                                <form method="post" action="<%= cp %>/valuations" style="display:inline"
                                      onsubmit="return confirm('Delete this valuation?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id"     value="<%= v.getId() %>">
                                    <button class="btn btn-sm btn-danger" type="submit">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
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
                <div class="form-group"><label>Animal *</label>
                    <div class="searchable-select" id="animalSearch">
                        <input type="text" id="animalSearchInput" placeholder="Type to search animal..." autocomplete="off"
                               style="width:100%; padding:8px; border:1px solid #D4A853; border-radius:4px;">
                        <input type="hidden" name="livestockId" id="fLivestock">
                        <div class="dropdown-list" id="animalDropdown"></div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Valuation Date *</label><input type="date" name="valDate" id="fDate" required></div>
                    <div class="form-group"><label>Value (N$) *</label><input type="number" name="value" id="fValue" step="0.01" min="0" required placeholder="0.00"></div>
                </div>
                <div class="form-group"><label>Method</label><input type="text" name="method" id="fMethod" placeholder="e.g. Market Survey"></div>
                <div class="form-group"><label>Notes</label><textarea name="notes" id="fNotes" rows="3"></textarea></div>
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
    document.getElementById('formId').value = '';
    document.getElementById('fLivestock').value = '';
    document.getElementById('animalSearchInput').value = '';
    document.getElementById('fDate').value = '';
    document.getElementById('fValue').value = '';
    document.getElementById('fMethod').value = '';
    document.getElementById('fNotes').value = '';
    document.getElementById('submitBtn').textContent = 'Save Valuation';
    openModal();
});

function openEditModal(id, livestockId, date, value, method, notes) {
    document.getElementById('modalTitle').textContent = 'Edit Valuation';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('formId').value = id;
    document.getElementById('fLivestock').value = livestockId;
    document.getElementById('fDate').value = date;
    document.getElementById('fValue').value = value;
    document.getElementById('fMethod').value = method;
    document.getElementById('fNotes').value = notes;
    document.getElementById('submitBtn').textContent = 'Update Valuation';
    var found = activeLivestock.find(function(item) { return item.id == livestockId; });
    document.getElementById('animalSearchInput').value = found ? found.text : '';
    openModal();
}

document.getElementById('closeModalBtn').addEventListener('click', closeModal);
document.getElementById('cancelModalBtn').addEventListener('click', closeModal);
modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });

<% if (editValuation != null) { %>
openEditModal('<%= editValuation.getId() %>','<%= editValuation.getLivestockId() %>','<%= editValuation.getValDate().toLocalDate().toString() %>','<%= editValuation.getValue().toPlainString() %>','<%= editValuation.getMethod() != null ? editValuation.getMethod().replace("'","\\'") : "" %>','<%= editValuation.getNotes()  != null ? editValuation.getNotes().replace("'","\\'")  : "" %>');
<% } %>
</script>

<script>
var activeLivestock = [
    <% if (active != null) { 
        for (Livestock l : active) { %>
            {id: "<%= l.getId() %>", text: "<%= l.getTag() %> \u2014 <%= l.getSpecies() %> (<%= l.getBreed() != null ? l.getBreed() : "Unknown" %>) \u2014 N$<%= String.format("%,.0f", l.getCurrentValue()) %>"},
    <% }} %>
];

var searchInput = document.getElementById("animalSearchInput");
var dropdown = document.getElementById("animalDropdown");
var hiddenInput = document.getElementById("fLivestock");

function showDropdown(items) {
    dropdown.innerHTML = "";
    if (items.length === 0) { dropdown.classList.remove("open"); return; }
    items.forEach(function(item) {
        var div = document.createElement("div");
        div.className = "dropdown-item";
        div.textContent = item.text;
        div.addEventListener("click", function() {
            searchInput.value = item.text;
            hiddenInput.value = item.id;
            dropdown.classList.remove("open");
        });
        dropdown.appendChild(div);
    });
    dropdown.classList.add("open");
}

searchInput.addEventListener("focus", function() { showDropdown(activeLivestock); });
searchInput.addEventListener("input", function() {
    var filter = this.value.toLowerCase();
    var filtered = activeLivestock.filter(function(item) { return item.text.toLowerCase().indexOf(filter) !== -1; });
    showDropdown(filtered);
});
document.addEventListener("click", function(e) {
    if (!document.getElementById("animalSearch").contains(e.target)) dropdown.classList.remove("open");
});
</script>

<script src="<%= cp %>/js/tables.js"></script>
<%@ include file="/WEB-INF/toast.jsp" %>
</body>
</html>
