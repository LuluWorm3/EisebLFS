<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Sale>      sales  = (List<Sale>)      request.getAttribute("sales");
    List<Livestock> active = (List<Livestock>) request.getAttribute("activeLivestock");
    Sale editSale          = (Sale) request.getAttribute("editSale");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Sales & Income — Eiseb LFS</title>
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
    <div class="topbar"><span class="page-title">Sales & Income</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Sales Records</div>
                <div class="section-sub"><%= sales != null ? sales.size() : 0 %> transactions</div>
            </div>
            <button class="btn btn-earth" id="openAddBtn">+ Record Sale</button>
        </div>

        <form method="post" action="<%= cp %>/sales" id="bulkDeleteForm">
            <input type="hidden" name="action" value="bulkDelete">
            <button type="button" class="btn btn-danger" onclick="if(confirm('Delete selected sales?')) document.getElementById('bulkDeleteForm').submit();" style="margin-bottom:10px;">Delete Selected</button>
        </form>


        <input type="text" id="tableSearch" placeholder="Search..." style="margin-bottom:12px; padding:8px 12px; width:100%; max-width:300px; border:1px solid #D4A853; border-radius:4px;">

        <div class="full-card">
            <div class="table-wrap">
                <table>
                    <thead><tr><th></th><th>Date</th><th>Tag</th><th>Buyer</th><th>Type</th><th>Price (N$)</th><th>Payment</th><th>Notes</th><th>Actions</th></tr></thead>
                    <tbody>
                    <% if (sales == null || sales.isEmpty()) { %>
                        <tr><td colspan="9" style="text-align:center;color:var(--muted);padding:40px 0">No sales recorded yet.</td></tr>
                    <% } else { for (Sale s : sales) { %>
                        <tr>
                            <td><input type="checkbox" name="ids" value="<%= s.getId() %>" form="bulkDeleteForm"></td>
                            <td style="font-family:'DM Mono',monospace;font-size:12px"><%= s.getSaleDate() %></td>
                            <td><strong style="font-family:'DM Mono',monospace"><%= s.getLivestockTag() %></strong></td>
                            <td><%= s.getBuyer() %></td>
                            <td><span class="badge badge-gray"><%= s.getSaleType() %></span></td>
                            <td><strong>N$&nbsp;<%= String.format("%,.2f", s.getPrice()) %></strong></td>
                            <td><span class="badge <%= "Paid".equals(s.getPaymentStatus()) ? "badge-green" : "Pending".equals(s.getPaymentStatus()) ? "badge-yellow" : "badge-blue" %>"><%= s.getPaymentStatus() %></span></td>
                            <td><%= s.getNotes() != null ? s.getNotes() : "—" %></td>
                            <td style="display:flex;gap:6px">
                                <button class="btn btn-sm btn-outline"
                                    onclick="openEditModal('<%= s.getId() %>','<%= s.getLivestockId() %>','<%= s.getBuyer().replace("'","\\'") %>','<%= s.getSaleType() %>','<%= s.getSaleDate().toLocalDate().toString() %>','<%= s.getPrice().toPlainString() %>','<%= s.getPaymentStatus() %>','<%= s.getNotes() != null ? s.getNotes().replace("'","\\'") : "" %>')">Edit</button>
                                <form method="post" action="<%= cp %>/sales" style="display:inline"
                                      onsubmit="return confirm('Delete this sale?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id"     value="<%= s.getId() %>">
                                    <button class="btn btn-sm btn-danger" type="submit">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
            <div class="pagination"><%= sales != null ? sales.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<!-- MODAL -->
<div id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title" id="modalTitle">Record Sale</span>
            <button class="modal-close" id="closeModalBtn" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/sales">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id"     id="formId"     value="">
            <div class="modal-body">
                <div class="form-group">
                    <label>Animal *</label>
                    <div class="searchable-select" id="animalSearch">
                        <input type="text" id="animalSearchInput" placeholder="Type to search animal..." autocomplete="off"
                               style="width:100%; padding:8px; border:1px solid #D4A853; border-radius:4px;">
                        <input type="hidden" name="livestockId" id="fLivestock">
                        <div class="dropdown-list" id="animalDropdown"></div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Buyer *</label><input type="text" name="buyer" id="fBuyer" placeholder="Buyer name" required></div>
                    <div class="form-group"><label>Sale Type *</label>
                        <select name="saleType" id="fSaleType" required>
                            <option value="Direct">Direct</option>
                            <option value="Auction">Auction</option>
                            <option value="Export">Export</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Sale Date *</label><input type="date" name="saleDate" id="fDate" required></div>
                    <div class="form-group"><label>Price (N$) *</label><input type="number" name="price" id="fPrice" step="0.01" min="0" required placeholder="0.00"></div>
                </div>
                <div class="form-group"><label>Payment Status *</label>
                    <select name="paymentStatus" id="fPayment" required>
                        <option value="Pending">Pending</option>
                        <option value="Paid">Paid (marks animal as Sold)</option>
                        <option value="Partial">Partial</option>
                    </select>
                </div>
                <div class="form-group"><label>Notes</label><textarea name="notes" id="fNotes" rows="2"></textarea></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" id="cancelModalBtn">Cancel</button>
                <button type="submit" class="btn btn-earth"   id="submitBtn">Save Sale</button>
            </div>
        </form>
    </div>
</div>

<script>
var modal = document.getElementById('addModal');
function openModal()  { modal.classList.add('open');    document.body.style.overflow='hidden'; }
function closeModal() { modal.classList.remove('open'); document.body.style.overflow=''; }

document.getElementById('openAddBtn').addEventListener('click', function() {
    document.getElementById('modalTitle').textContent = 'Record Sale';
    document.getElementById('formAction').value = 'add';
    document.getElementById('formId').value = '';
    document.getElementById('fLivestock').value = '';
    document.getElementById('animalSearchInput').value = '';
    document.getElementById('fBuyer').value = '';
    document.getElementById('fSaleType').value = 'Direct';
    document.getElementById('fDate').value = '';
    document.getElementById('fPrice').value = '';
    document.getElementById('fPayment').value = 'Pending';
    document.getElementById('fNotes').value = '';
    document.getElementById('submitBtn').textContent = 'Save Sale';
    openModal();
});

function openEditModal(id, livestockId, buyer, saleType, date, price, payment, notes) {
    document.getElementById('modalTitle').textContent = 'Edit Sale';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('formId').value = id;
    document.getElementById('fLivestock').value = livestockId;
    document.getElementById('fBuyer').value = buyer;
    document.getElementById('fSaleType').value = saleType;
    document.getElementById('fDate').value = date;
    document.getElementById('fPrice').value = price;
    document.getElementById('fPayment').value = payment;
    document.getElementById('fNotes').value = notes;
    document.getElementById('submitBtn').textContent = 'Update Sale';
    var found = activeLivestock.find(function(item) { return item.id == livestockId; });
    document.getElementById('animalSearchInput').value = found ? found.text : '';
    openModal();
}

document.getElementById('closeModalBtn').addEventListener('click', closeModal);
document.getElementById('cancelModalBtn').addEventListener('click', closeModal);
modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });

<% if (editSale != null) { %>
openEditModal('<%= editSale.getId() %>','<%= editSale.getLivestockId() %>','<%= editSale.getBuyer().replace("'","\\'") %>','<%= editSale.getSaleType() %>','<%= editSale.getSaleDate().toLocalDate().toString() %>','<%= editSale.getPrice().toPlainString() %>','<%= editSale.getPaymentStatus() %>','<%= editSale.getNotes() != null ? editSale.getNotes().replace("'","\\'") : "" %>');
<% } %>
</script>

<script>
// Searchable dropdown
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
<script>
var cbs=document.querySelectorAll("[name=\"ids\"]");
var btn=document.querySelector("#bulkDeleteForm button");
if(btn) btn.style.display="none";
cbs.forEach(function(cb){cb.addEventListener("change",function(){var any=Array.from(cbs).some(function(c){return c.checked});if(btn)btn.style.display=any?"":"none";});});
</script>
</body>
</html>
