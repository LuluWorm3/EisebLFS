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
        /* Modal — self-contained so it works regardless of main.css edits */
        .modal-overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(0,0,0,0.55); z-index: 200;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex !important; }
        .modal {
            background: white; border-radius: 4px; width: 520px;
            max-width: 95vw; max-height: 90vh; overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            border-top: 4px solid #D4A853;
        }
        .modal-header { padding: 24px 28px 16px; border-bottom: 1px solid #E8D9BE; display: flex; justify-content: space-between; align-items: center; }
        .modal-title  { font-family: 'Playfair Display', serif; font-size: 18px; font-weight: 700; color: #2C1A0E; }
        .modal-close  { background: none; border: none; font-size: 22px; cursor: pointer; color: #8A7560; }
        .modal-body   { padding: 24px 28px; }
        .modal-footer { padding: 16px 28px; border-top: 1px solid #E8D9BE; display: flex; gap: 10px; justify-content: flex-end; }
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
            <button class="btn btn-earth" onclick="openModal('addModal')">+ Add Animal</button>
        </div>

        <div class="filter-tabs">
            <a href="<%= cp %>/livestock"                 class="filter-tab <%= "All".equals(filter)      ? "active" : "" %>">All</a>
            <a href="<%= cp %>/livestock?filter=Active"   class="filter-tab <%= "Active".equals(filter)   ? "active" : "" %>">Active</a>
            <a href="<%= cp %>/livestock?filter=Sold"     class="filter-tab <%= "Sold".equals(filter)     ? "active" : "" %>">Sold</a>
            <a href="<%= cp %>/livestock?filter=Deceased" class="filter-tab <%= "Deceased".equals(filter) ? "active" : "" %>">Deceased</a>
        </div>

        <div class="full-card">
            <table>
                <thead>
                    <tr><th>Tag</th><th>Species</th><th>Breed</th><th>Gender</th><th>DOB</th><th>Value (N$)</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                <% if (livestock == null || livestock.isEmpty()) { %>
                    <tr><td colspan="8" style="text-align:center;color:var(--muted);padding:32px">No animals found. Add one above.</td></tr>
                <% } else { for (Livestock l : livestock) { %>
                    <tr>
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
                            <% if (!"Sold".equals(l.getStatus()) && !"Deceased".equals(l.getStatus())) { %>
                            <form method="post" action="<%= cp %>/livestock" style="display:inline">
                                <input type="hidden" name="action" value="status">
                                <input type="hidden" name="id"     value="<%= l.getId() %>">
                                <input type="hidden" name="status" value="Deceased">
                                <button class="btn btn-sm btn-outline" type="submit"
                                        onclick="return confirm('Mark <%= l.getTag() %> as deceased?')">✕ Deceased</button>
                            </form>
                            <% } %>
                            <form method="post" action="<%= cp %>/livestock" style="display:inline"
                                  onsubmit="return confirm('Permanently delete <%= l.getTag() %>? This cannot be undone.')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id"     value="<%= l.getId() %>">
                                <button class="btn btn-sm btn-danger" type="submit">🗑</button>
                            </form>
                        </td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= livestock != null ? livestock.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<%-- Add Animal Modal --%>
<div class="modal-overlay" id="addModal" onclick="handleOverlayClick(event,'addModal')">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Add New Animal</span>
            <button class="modal-close" onclick="closeModal('addModal')" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/livestock">
            <input type="hidden" name="action" value="add">
            <div class="modal-body">
                <div class="form-row">
                    <div class="form-group">
                        <label>Ear Tag *</label>
                        <input type="text" name="tag" placeholder="ECT-008" required>
                    </div>
                    <div class="form-group">
                        <label>Species *</label>
                        <select name="species" required>
                            <option value="">Select...</option>
                            <option value="Cattle">Cattle</option>
                            <option value="Goat">Goat</option>
                            <option value="Sheep">Sheep</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Breed</label>
                        <input type="text" name="breed" placeholder="e.g. Brahman">
                    </div>
                    <div class="form-group">
                        <label>Gender *</label>
                        <select name="gender" required>
                            <option value="">Select...</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Date of Birth</label>
                        <input type="date" name="dob">
                    </div>
                    <div class="form-group">
                        <label>Initial Value (N$)</label>
                        <input type="number" name="currentValue" step="0.01" min="0" placeholder="0.00">
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeModal('addModal')">Cancel</button>
                <button type="submit" class="btn btn-earth">Add Animal</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id)  { document.getElementById(id).classList.add('open'); }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); }
    function handleOverlayClick(e, id) {
        if (e.target === document.getElementById(id)) closeModal(id);
    }
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') document.querySelectorAll('.modal-overlay.open').forEach(m => m.classList.remove('open'));
    });
</script>
</body>
</html>