<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Livestock> livestock = (List<Livestock>) request.getAttribute("livestock");
    String filter = (String) request.getAttribute("filter");
    if (filter == null) filter = "All";
    String cp = request.getContextPath();
    Livestock editLivestock = (Livestock) request.getAttribute("editLivestock");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Livestock Registry — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>
        body { display: flex; }
        .main { flex: 1; }

        #addModal { display:none; position:fixed; top:0;left:0;right:0;bottom:0; background:rgba(0,0,0,0.6); z-index:9999; }
        #addModal.open { display:block; }
        #addModal .modal-box {
            position:absolute; top:50%; left:50%; transform:translate(-50%,-50%);
            background:#fff; border-radius:4px; width:520px; max-width:92vw;
            max-height:90vh; overflow-y:auto;
            box-shadow:0 24px 64px rgba(0,0,0,0.35); border-top:4px solid #D4A853;
        }
        .modal-header { padding:22px 28px 14px; border-bottom:1px solid #E8D9BE; display:flex; justify-content:space-between; align-items:center; }
        .modal-title  { font-family:'Playfair Display',serif; font-size:18px; font-weight:700; color:#2C1A0E; }
        .modal-close  { background:none; border:none; font-size:24px; cursor:pointer; color:#8A7560; line-height:1; padding:0 4px; }
        .modal-body   { padding:22px 28px; }
        .modal-footer { padding:14px 28px; border-top:1px solid #E8D9BE; display:flex; gap:10px; justify-content:flex-end; }

        #tableSearch { margin-bottom:12px; padding:8px 12px; width:100%; max-width:300px; border:1px solid #D4A853; border-radius:4px; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar">
        <span class="page-title">Livestock Registry</span>
    </div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">All Animals</div>
                <div class="section-sub"><%= livestock != null ? livestock.size() : 0 %> records</div>
            </div>
            <button class="btn btn-earth" id="openAddBtn">+ Add Animal</button>
        </div>

        <div class="filter-tabs">
            <a href="<%= cp %>/livestock"                 class="filter-tab <%= "All".equals(filter)      ? "active" : "" %>">All</a>
            <a href="<%= cp %>/livestock?filter=Active"   class="filter-tab <%= "Active".equals(filter)   ? "active" : "" %>">Active</a>
            <a href="<%= cp %>/livestock?filter=Sold"     class="filter-tab <%= "Sold".equals(filter)     ? "active" : "" %>">Sold</a>
            <a href="<%= cp %>/livestock?filter=Deceased" class="filter-tab <%= "Deceased".equals(filter) ? "active" : "" %>">Deceased</a>
        </div>

        <form method="post" action="<%= cp %>/livestock" id="bulkDeleteForm">
            <input type="hidden" name="action" value="bulkDelete">
            <button type="button" class="btn btn-danger" onclick="if(confirm('Delete selected animals?')) document.getElementById('bulkDeleteForm').submit();" style="margin-bottom:10px;">Delete Selected</button>
        </form>

        <input type="text" id="tableSearch" placeholder="Search...">

        <div class="full-card">
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr><th></th><th>Tag</th><th>Species</th><th>Breed</th><th>Gender</th><th>DOB</th><th>Value (N$)</th><th>Status</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                    <% if (livestock == null || livestock.isEmpty()) { %>
                        <tr><td colspan="9" style="text-align:center;color:var(--muted);padding:40px 0">No animals found. Add one above.</td></tr>
                    <% } else { for (Livestock l : livestock) { %>
                        <tr>
                            <td><input type="checkbox" name="ids" value="<%= l.getId() %>" form="bulkDeleteForm"></td>
                            <td><strong style="font-family:'DM Mono',monospace"><%= l.getTag() %></strong></td>
                            <td><%= l.getSpecies() %></td>
                            <td><%= l.getBreed() != null ? l.getBreed() : "—" %></td>
                            <td><%= l.getGender() %></td>
                            <td style="font-family:'DM Mono',monospace;font-size:12px"><%= l.getDob() != null ? l.getDob() : "—" %></td>
                            <td><%= String.format("%,.2f", l.getCurrentValue()) %></td>
                            <td>
                                <span class="badge <%= "Active".equals(l.getStatus()) ? "badge-green" : "Sold".equals(l.getStatus()) ? "badge-blue" : "badge-red" %>">
                                    <%= l.getStatus() %>
                                </span>
                            </td>
                            <td style="display:flex;gap:6px;flex-wrap:wrap">
                                <button class="btn btn-sm btn-outline"
                                    onclick="openEditModal(
                                        '<%= l.getId() %>',
                                        '<%= l.getTag() %>',
                                        '<%= l.getSpecies() %>',
                                        '<%= l.getBreed() != null ? l.getBreed() : "" %>',
                                        '<%= l.getGender() %>',
                                        '<%= l.getDob() != null ? l.getDob().toLocalDate().toString() : "" %>',
                                        '<%= l.getCurrentValue().toPlainString() %>',
                                        '<%= l.getStatus() %>'
                                    )">Edit</button>
                                <% if (!"Sold".equals(l.getStatus()) && !"Deceased".equals(l.getStatus())) { %>
                                <form method="post" action="<%= cp %>/livestock" style="display:inline">
                                    <input type="hidden" name="action" value="status">
                                    <input type="hidden" name="id"     value="<%= l.getId() %>">
                                    <input type="hidden" name="status" value="Deceased">
                                    <button class="btn btn-sm btn-outline" type="submit"
                                            onclick="return confirm('Mark <%= l.getTag() %> as deceased?')">X Deceased</button>
                                </form>
                                <% } %>
                                <form method="post" action="<%= cp %>/livestock" style="display:inline"
                                      onsubmit="return confirm('Permanently delete <%= l.getTag() %>? This cannot be undone.')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id"     value="<%= l.getId() %>">
                                    <button class="btn btn-sm btn-danger" type="submit">Delete</button>
                                </form>
                            </td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
            <div class="pagination"><%= livestock != null ? livestock.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<!-- ADD / EDIT MODAL -->
<div id="addModal">
    <div class="modal-box">
        <div class="modal-header">
            <span class="modal-title" id="modalTitle">Add New Animal</span>
            <button class="modal-close" id="closeModalBtn" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/livestock">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id"     id="formId"     value="">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group">
                        <label>Ear Tag *</label>
                        <input type="text" name="tag" id="fTag" placeholder="ECT-008" required>
                    </div>
                    <div class="form-group">
                        <label>Species *</label>
                        <select name="species" id="fSpecies" required>
                            <option value="">Select...</option>
                            <option value="Cattle">Cattle</option>
                            <option value="Goat">Goat</option>
                            <option value="Sheep">Sheep</option>
                        </select>
                    </div>
                </div>
                <div class="form-group" id="categoryGroup" style="display:none;">
                    <label>Category / Type</label>
                    <select name="category" id="fCategory">
                        <option value="">Select...</option>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Breed</label>
                        <input type="text" name="breed" id="fBreed" placeholder="e.g. Brahman">
                    </div>
                    <div class="form-group">
                        <label>Gender *</label>
                        <select name="gender" id="fGender" required>
                            <option value="">Select...</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Date of Birth</label>
                        <input type="date" name="dob" id="fDob">
                    </div>
                    <div class="form-group">
                        <label>Initial Value (N$)</label>
                        <input type="number" name="currentValue" id="fValue" step="0.01" min="0" placeholder="0.00">
                    </div>
                </div>
                <div class="form-group" id="statusRow" style="display:none">
                    <label>Status</label>
                    <select name="status" id="fStatus">
                        <option value="Active">Active</option>
                        <option value="Sold">Sold</option>
                        <option value="Deceased">Deceased</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" id="cancelModalBtn">Cancel</button>
                <button type="submit" class="btn btn-earth"   id="submitBtn">Add Animal</button>
            </div>
        </form>
    </div>
</div>

<script>
var modal = document.getElementById('addModal');
function openModal()  { modal.classList.add('open');    document.body.style.overflow='hidden'; }
function closeModal() { modal.classList.remove('open'); document.body.style.overflow=''; }

document.getElementById('openAddBtn').addEventListener('click', function() {
    document.getElementById('modalTitle').textContent = 'Add New Animal';
    document.getElementById('formAction').value = 'add';
    document.getElementById('formId').value = '';
    document.getElementById('fTag').value = '';
    document.getElementById('fSpecies').value = '';
    document.getElementById('fBreed').value = '';
    document.getElementById('fGender').value = '';
    document.getElementById('fDob').value = '';
    document.getElementById('fValue').value = '';
    document.getElementById('fStatus').value = 'Active';
    document.getElementById('statusRow').style.display = 'none';
    document.getElementById('categoryGroup').style.display = 'none';
    document.getElementById('submitBtn').textContent = 'Add Animal';
    openModal();
});

function openEditModal(id, tag, species, breed, gender, dob, value, status) {
    document.getElementById('modalTitle').textContent = 'Edit Animal';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('formId').value = id;
    document.getElementById('fTag').value = tag;
    document.getElementById('fSpecies').value = species;
    document.getElementById('fBreed').value = breed;
    document.getElementById('fGender').value = gender;
    document.getElementById('fDob').value = dob;
    document.getElementById('fValue').value = value;
    document.getElementById('fStatus').value = status;
    document.getElementById('statusRow').style.display = 'block';
    document.getElementById('categoryGroup').style.display = 'none';
    document.getElementById('submitBtn').textContent = 'Update Animal';
    openModal();
}

document.getElementById('closeModalBtn').addEventListener('click', closeModal);
document.getElementById('cancelModalBtn').addEventListener('click', closeModal);
modal.addEventListener('click', function(e) { if (e.target === modal) closeModal(); });
document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });

<% if (editLivestock != null) { %>
openEditModal(
    '<%= editLivestock.getId() %>',
    '<%= editLivestock.getTag() %>',
    '<%= editLivestock.getSpecies() %>',
    '<%= editLivestock.getBreed() != null ? editLivestock.getBreed() : "" %>',
    '<%= editLivestock.getGender() %>',
    '<%= editLivestock.getDob() != null ? editLivestock.getDob().toLocalDate().toString() : "" %>',
    '<%= editLivestock.getCurrentValue().toPlainString() %>',
    '<%= editLivestock.getStatus() %>'
);
<% } %>
</script>

<script src="<%= cp %>/js/tables.js"></script>

<%@ include file="/WEB-INF/toast.jsp" %>
<script>
var categoriesBySpecies = {
    "Goat": [
        "Kid (young)",
        "Meat Goat (Boer, Kiko)",
        "Dairy Goat (Nubian, Alpine)",
        "Registered Breeding Stock"
    ],
    "Cattle": [
        "Calf (weaner)",
        "Yearling / Grower",
        "Mature Cow (breeding)",
        "Ox / Steer (draught)",
        "Registered Bull"
    ],
    "Sheep": [
        "Lamb (young)",
        "Meat Sheep (Dorper)",
        "Wool Sheep (Merino)",
        "Registered Ram / Ewe"
    ]
};

var speciesSelect = document.getElementById("fSpecies");
var categoryGroup = document.getElementById("categoryGroup");
var categorySelect = document.getElementById("fCategory");

speciesSelect.addEventListener("change", function() {
    var species = this.value;
    if (categoriesBySpecies[species]) {
        categorySelect.innerHTML = "<option value=\"\">Select...</option>";
        categoriesBySpecies[species].forEach(function(cat) {
            var opt = document.createElement("option");
            opt.value = cat;
            opt.textContent = cat;
            categorySelect.appendChild(opt);
        });
        categoryGroup.style.display = "block";
    } else {
        categoryGroup.style.display = "none";
    }
});

if (speciesSelect.value) {
    var event = new Event("change");
    speciesSelect.dispatchEvent(event);
}
</script>
</body>
</html>
