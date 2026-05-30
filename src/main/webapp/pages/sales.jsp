<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Sale>      sales  = (List<Sale>)      request.getAttribute("sales");
    List<Livestock> active = (List<Livestock>) request.getAttribute("activeLivestock");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Sales & Income — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;} .main{flex:1;}</style>
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
            <button class="btn btn-earth" onclick="document.getElementById('addModal').classList.add('open')">+ Record Sale</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Tag</th><th>Buyer</th><th>Type</th><th>Price (N$)</th><th>Payment</th><th>Notes</th></tr></thead>
                <tbody>
                <% if (sales == null || sales.isEmpty()) { %>
                    <tr><td colspan="7" style="text-align:center;color:var(--muted);padding:32px">No sales recorded yet.</td></tr>
                <% } else { for (Sale s : sales) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= s.getSaleDate() %></td>
                        <td><strong style="font-family:'DM Mono',monospace"><%= s.getLivestockTag() %></strong></td>
                        <td><%= s.getBuyer() %></td>
                        <td><span class="badge badge-gray"><%= s.getSaleType() %></span></td>
                        <td><strong>N$&nbsp;<%= String.format("%,.2f", s.getPrice()) %></strong></td>
                        <td>
                            <span class="badge <%= "Paid".equals(s.getPaymentStatus()) ? "badge-green" : "Pending".equals(s.getPaymentStatus()) ? "badge-yellow" : "badge-blue" %>">
                                <%= s.getPaymentStatus() %>
                            </span>
                        </td>
                        <td><%= s.getNotes() != null ? s.getNotes() : "—" %></td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= sales != null ? sales.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title">Record Sale</span>
            <button class="modal-close" onclick="document.getElementById('addModal').classList.remove('open')">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/sales">
            <div class="modal-body">
                <div class="form-group">
                    <label>Animal *</label>
                    <select name="livestockId" required>
                        <option value="">Select animal...</option>
                        <% if (active != null) { for (Livestock l : active) { %>
                            <option value="<%= l.getId() %>"><%= l.getTag() %> — <%= l.getSpecies() %> (<%= l.getBreed() != null ? l.getBreed() : "Unknown" %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Buyer *</label>
                        <input type="text" name="buyer" placeholder="Buyer name" required>
                    </div>
                    <div class="form-group">
                        <label>Sale Type *</label>
                        <select name="saleType" required>
                            <option value="Direct">Direct</option>
                            <option value="Auction">Auction</option>
                            <option value="Export">Export</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Sale Date *</label>
                        <input type="date" name="saleDate" required>
                    </div>
                    <div class="form-group">
                        <label>Price (N$) *</label>
                        <input type="number" name="price" step="0.01" min="0" required placeholder="0.00">
                    </div>
                </div>
                <div class="form-group">
                    <label>Payment Status *</label>
                    <select name="paymentStatus" required>
                        <option value="Pending">Pending</option>
                        <option value="Paid">Paid (marks animal as Sold)</option>
                        <option value="Partial">Partial</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Notes</label>
                    <textarea name="notes" rows="2" placeholder="Optional notes..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="document.getElementById('addModal').classList.remove('open')">Cancel</button>
                <button type="submit" class="btn btn-earth">Save Sale</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>
