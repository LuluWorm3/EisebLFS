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

        /* Lightbox */
        #lightbox {
            display:none; position:fixed; top:0;left:0;right:0;bottom:0; background:rgba(0,0,0,0.85); z-index:9999;
            align-items:center; justify-content:center;
        }
        #lightbox.open { display:flex; }
        #lightbox img { max-width:90vw; max-height:90vh; border-radius:4px; }
        #lightbox .close-lightbox { position:absolute; top:20px; right:30px; font-size:30px; color:white; cursor:pointer; }
        .photo-thumb { width:40px; height:40px; object-fit:cover; border-radius:3px; cursor:pointer; border:1px solid #ddd; }
        .no-photo { font-size:11px; color:#ccc; }
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
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr><th></th><th>Tag</th><th>Species</th><th>Breed</th><th>Category</th><th>Gender</th><th>DOB</th><th>Value (N$)</th><th>Status</th><th>Photo</th><th>Actions</th></tr>
                    </thead>
                    <tbody>
                    <% if (livestock == null || livestock.isEmpty()) { %>
                        <tr><td colspan="11" style="text-align:center;color:var(--muted);padding:40px 0">No animals found. Add one above.</div></td></tr>
                    <% } else { for (Livestock l : livestock) { %>
                        <tr>
                            <td><input type="checkbox" name="ids" value="<%= l.getId() %>" form="bulkDeleteForm"></div></td>
                            <td><strong style="font-family:'DM Mono',monospace"><%= l.getTag() %></strong></div></td>
                            <td><%= l.getSpecies() %></div></td>
                            <td><%= l.getBreed() != null ? l.getBreed() : "—" %></div></td>
                            <td><%= l.getCategory() != null ? l.getCategory() : "—" %></div></td>
                            <td><%= l.getGender() %></div></td>
                            <td style="font-family:'DM Mono',monospace;font-size:12px"><%= l.getDob() != null ? l.getDob() : "—" %></div></td>
                            <td><%= String.format("%,.2f", l.getCurrentValue()) %></div></td>
                            <td>
                                <span class="badge <%= "Active".equals(l.getStatus()) ? "badge-green" : "Sold".equals(l.getStatus()) ? "badge-blue" : "badge-red" %>">
                                    <%= l.getStatus() %>
                                </span>
                            </div></td>
                            <td>
                                <% if (l.getImagePath() != null && !l.getImagePath().isEmpty()) { %>
                                    <img src="<%= cp %>/image?file=livestock/<%= l.getImagePath() %>" class="photo-thumb" onclick="openLightbox('<%= cp %>/image?file=livestock/<%= l.getImagePath() %>')">
                                <% } else { %>
                                    <span class="no-photo">No photo</span>
                                <% } %>
                            </div></td>
                            <td style="white-space:nowrap"><div style="display:inline-flex;gap:6px;align-items:center">
                                <button class="btn btn-sm btn-outline"
                                    onclick="openEditModal(
                                        '<%= l.getId() %>',
                                        '<%= l.getTag() %>',
                                        '<%= l.getSpecies() %>',
                                        '<%= l.getBreed() != null ? l.getBreed() : "" %>',
                                        '<%= l.getCategory() != null ? l.getCategory() : "" %>',
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
                                    <button class="btn btn-sm btn-outline" type="button"
                                            onclick="event.preventDefault(); Swal.fire({title:'Mark <%= l.getTag() %> as deceased?', text:'This cannot be easily undone.', icon:'warning', showCancelButton:true, confirmButtonColor:'#D4A853', confirmButtonText:'Yes, mark deceased'}).then(function(result){ if(result.isConfirmed) this.form.submit(); })">X Deceased</button>
                                </form>
                                <% } %>
                                <form method="post" action="<%= cp %>/livestock" style="display:inline"
                                      onsubmit="return confirm('Permanently delete <%= l.getTag() %>? This cannot be undone.')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id"     value="<%= l.getId() %>">
                                    <button class="btn btn-sm btn-danger" type="button">Delete</button>
                                </form>
                            </div></td>
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
        <form method="post" action="<%= cp %>/livestock" enctype="multipart/form-data">
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
                <div class="form-group">
                    <label>Photo (optional)</label>
                    <input type="file" name="image" id="fImage" accept="image/*">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" id="cancelModalBtn">Cancel</button>
                <button type="submit" class="btn btn-earth"   id="submitBtn">Add Animal</button>
            </div>
        </form>
    </div>
</div>

<!-- LIGHTBOX -->
<div id="lightbox">
    <span class="close-lightbox" onclick="closeLightbox()">&times;</span>
    <img id="lightbox-img" src="">
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
    document.getElementById('fCategory').value = '';
    document.getElementById('fGender').value = '';
    document.getElementById('fDob').value = '';
    document.getElementById('fValue').value = '';
    document.getElementById('fStatus').value = 'Active';
    document.getElementById('statusRow').style.display = 'none';
    document.getElementById('categoryGroup').style.display = 'none';
    document.getElementById('fImage').value = '';
    document.getElementById('submitBtn').textContent = 'Add Animal';
    openModal();
});

function openEditModal(id, tag, species, breed, category, gender, dob, value, status) {
    document.getElementById('modalTitle').textContent = 'Edit Animal';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('formId').value = id;
    document.getElementById('fTag').value = tag;
    document.getElementById('fSpecies').value = species;
    document.getElementById('fBreed').value = breed;
    document.getElementById('fCategory').value = category;
    document.getElementById('fGender').value = gender;
    document.getElementById('fDob').value = dob;
    document.getElementById('fValue').value = value;
    document.getElementById('fStatus').value = status;
    document.getElementById('statusRow').style.display = 'block';
    document.getElementById('categoryGroup').style.display = 'none';
    document.getElementById('fImage').value = '';
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
    '<%= editLivestock.getCategory() != null ? editLivestock.getCategory() : "" %>',
    '<%= editLivestock.getGender() %>',
    '<%= editLivestock.getDob() != null ? editLivestock.getDob().toLocalDate().toString() : "" %>',
    '<%= editLivestock.getCurrentValue().toPlainString() %>',
    '<%= editLivestock.getStatus() %>'
);
<% } %>

// Lightbox
function openLightbox(src) {
    document.getElementById('lightbox-img').src = src;
    document.getElementById('lightbox').classList.add('open');
}
function closeLightbox() {
    document.getElementById('lightbox').classList.remove('open');
}
document.getElementById('lightbox').addEventListener('click', function(e) {
    if (e.target === this) closeLightbox();
});
</script>

<script src="<%= cp %>/js/tables.js"></script>

<%@ include file="/WEB-INF/toast.jsp" %>
<script>
var categoriesBySpecies = {
    "Goat": ["Kid (young)", "Meat Goat (Boer, Kiko)", "Dairy Goat (Nubian, Alpine)", "Registered Breeding Stock"],
    "Cattle": ["Calf (weaner)", "Yearling / Grower", "Mature Cow (breeding)", "Ox / Steer (draught)", "Registered Bull"],
    "Sheep": ["Lamb (young)", "Meat Sheep (Dorper)", "Wool Sheep (Merino)", "Registered Ram / Ewe"]
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
<script>
var cbs=document.querySelectorAll("[name=\"ids\"]");
var btn=document.querySelector("#bulkDeleteForm button");
if(btn) btn.style.display="none";
cbs.forEach(function(cb){cb.addEventListener("change",function(){var any=Array.from(cbs).some(function(c){return c.checked});if(btn)btn.style.display=any?"":"none";});});
</script>
</body>
</html>
