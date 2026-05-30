<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Valuation> valuations = (List<Valuation>) request.getAttribute("valuations");
    List<Livestock> active     = (List<Livestock>) request.getAttribute("activeLivestock");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Valuations — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;} .main{flex:1;}</style>
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
            <button class="btn btn-earth" onclick="document.getElementById('addModal').classList.add('open')">+ Record Valuation</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Tag</th><th>Species</th><th>Value (N$)</th><th>Method</th><th>Notes</th></tr></thead>
                <tbody>
                <% if (valuations == null || valuations.isEmpty()) { %>
                    <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:32px">No valuations recorded yet.</td></tr>
                <% } else { for (Valuation v : valuations) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= v.getValDate() %></td>
                        <td><strong style="font-family:'DM Mono',monospace"><%= v.getLivestockTag() %></strong></td>
                        <td><%= v.getLivestockSpecies() %></td>
                        <td><strong>N$&nbsp;<%= String.format("%,.2f", v.getValue()) %></strong></td>
                        <td><%= v.getMethod() != null ? v.getMethod() : "—" %></td>
                        <td><%= v.getNotes() != null ? v.getNotes() : "—" %></td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= valuations != null ? valuations.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Record Valuation</span>
            <button class="modal-close" onclick="document.getElementById('addModal').classList.remove('open')">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/valuations">
            <div class="modal-body">
                <div class="form-group">
                    <label>Animal *</label>
                    <select name="livestockId" required>
                        <option value="">Select animal...</option>
                        <% if (active != null) { for (Livestock l : active) { %>
                            <option value="<%= l.getId() %>"><%= l.getTag() %> — <%= l.getSpecies() %> (<%= l.getBreed() != null ? l.getBreed() : "Unknown breed" %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Valuation Date *</label>
                        <input type="date" name="valDate" required>
                    </div>
                    <div class="form-group">
                        <label>Value (N$) *</label>
                        <input type="number" name="value" step="0.01" min="0" required placeholder="0.00">
                    </div>
                </div>
                <div class="form-group">
                    <label>Method</label>
                    <input type="text" name="method" placeholder="e.g. Market Survey, Veterinary Assessment">
                </div>
                <div class="form-group">
                    <label>Notes</label>
                    <textarea name="notes" rows="3" placeholder="Additional notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="document.getElementById('addModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-earth">Save Valuation</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
