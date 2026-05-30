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
    <div class="topbar"><span class="page-title">Valuations</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Valuation History</div>
                <div class="section-sub">Track current value changes per animal</div>
            </div>
            <button class="btn btn-earth" onclick="openModal('addModal')">+ Record Valuation</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Tag</th><th>Species</th><th>Value (N$)</th><th>Method</th><th>Notes</th><th>Actions</th></tr></thead>
                <tbody>
                <% if (valuations == null || valuations.isEmpty()) { %>
                    <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:32px">No valuations recorded yet.</td></tr>
                <% } else { for (Valuation v : valuations) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= v.getValDate() %></td>
                        <td><strong style="font-family:'DM Mono',monospace"><%= v.getLivestockTag() %></strong></td>
                        <td><%= v.getLivestockSpecies() %></td>
                        <td><strong>N$&nbsp;<%= String.format("%,.2f", v.getValue()) %></strong></td>
                        <td><%= v.getMethod() != null ? v.getMethod() : "—" %></td>
                        <td><%= v.getNotes() != null ? v.getNotes() : "—" %></td>
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <form method="get" action="<%= cp %>/valuations" style="display:inline">
                                <input type="hidden" name="action" value="editForm">
                                <input type="hidden" name="id" value="<%= v.getId() %>">
                                <button class="btn btn-sm btn-outline" type="submit">Edit</button>
                            </form>
                            <form method="post" action="<%= cp %>/valuations" style="display:inline"
                                  onsubmit="return confirm('Delete this valuation?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= v.getId() %>">
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

<%-- Add / Edit Modal --%>
<div class="modal-overlay" id="addModal" onclick="handleOverlayClick(event,'addModal')">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title"><%= editValuation != null ? "Edit Valuation" : "Record Valuation" %></span>
            <button class="modal-close" onclick="closeModal('addModal')" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/valuations">
            <input type="hidden" name="action" value="<%= editValuation != null ? "edit" : "add" %>">
            <% if (editValuation != null) { %>
                <input type="hidden" name="id" value="<%= editValuation.getId() %>">
            <% } %>
            <div class="modal-body">
                <div class="form-group">
                    <label>Animal *</label>
                    <select name="livestockId" required>
                        <option value="">Select animal...</option>
                        <% if (active != null) { for (Livestock l : active) {
                            String sel = (editValuation != null && editValuation.getLivestockId() == l.getId()) ? "selected" : "";
                        %>
                            <option value="<%= l.getId() %>" <%= sel %>><%= l.getTag() %> — <%= l.getSpecies() %> (<%= l.getBreed() != null ? l.getBreed() : "Unknown breed" %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Valuation Date *</label>
                        <input type="date" name="valDate" required
                               value="<%= editValuation != null ? editValuation.getValDate().toLocalDate().toString() : "" %>">
                    </div>
                    <div class="form-group">
                        <label>Value (N$) *</label>
                        <input type="number" name="value" step="0.01" min="0" required placeholder="0.00"
                               value="<%= editValuation != null ? editValuation.getValue().toString() : "" %>">
                    </div>
                </div>
                <div class="form-group">
                    <label>Method</label>
                    <input type="text" name="method" placeholder="e.g. Market Survey"
                           value="<%= editValuation != null && editValuation.getMethod() != null ? editValuation.getMethod() : "" %>">
                </div>
                <div class="form-group">
                    <label>Notes</label>
                    <textarea name="notes" rows="3"><%= editValuation != null && editValuation.getNotes() != null ? editValuation.getNotes() : "" %></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeModal('addModal')">Cancel</button>
                <button type="submit" class="btn btn-earth"><%= editValuation != null ? "Update Valuation" : "Save Valuation" %></button>
            </div>
        </form>
    </div>
</div>
<script>
    function openModal(id){document.getElementById(id).classList.add('open');}
    function closeModal(id){document.getElementById(id).classList.remove('open');}
    function handleOverlayClick(e,id){if(e.target===document.getElementById(id))closeModal(id);}
    document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.modal-overlay.open').forEach(m=>m.classList.remove('open'));});
    <% if (editValuation != null) { %> openModal('addModal'); <% } %>
</script>
</body>
</html>