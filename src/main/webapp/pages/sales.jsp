<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Sale>      sales    = (List<Sale>)      request.getAttribute("sales");
    List<Livestock> active   = (List<Livestock>) request.getAttribute("activeLivestock");
    Sale editSale            = (Sale) request.getAttribute("editSale");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Sales & Income — Eiseb LFS</title>
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
    <div class="topbar"><span class="page-title">Sales & Income</span></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Sales Records</div>
                <div class="section-sub"><%= sales != null ? sales.size() : 0 %> transactions</div>
            </div>
            <button class="btn btn-earth" onclick="openModal('addModal')">+ Record Sale</button>
        </div>

        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Tag</th><th>Buyer</th><th>Type</th><th>Price (N$)</th><th>Payment</th><th>Notes</th><th>Actions</th></tr></thead>
                <tbody>
                <% if (sales == null || sales.isEmpty()) { %>
                    <tr><td colspan="8" style="text-align:center;color:var(--muted);padding:32px">No sales recorded yet.</td></tr>
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
                        <td style="display:flex;gap:6px;flex-wrap:wrap">
                            <form method="get" action="<%= cp %>/sales" style="display:inline">
                                <input type="hidden" name="action" value="editForm">
                                <input type="hidden" name="id" value="<%= s.getId() %>">
                                <button class="btn btn-sm btn-outline" type="submit">Edit</button>
                            </form>
                            <form method="post" action="<%= cp %>/sales" style="display:inline"
                                  onsubmit="return confirm('Delete this sale?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= s.getId() %>">
                                <button class="btn btn-sm btn-danger" type="submit">🗑</button>
                            </form>
                        </td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
            <div class="pagination"><%= sales != null ? sales.size() : 0 %> record(s)</div>
        </div>
    </div>
</div>

<%-- Add / Edit Modal --%>
<div class="modal-overlay" id="addModal" onclick="handleOverlayClick(event,'addModal')">
    <div class="modal">
        <div class="modal-header">
            <span class="modal-title"><%= editSale != null ? "Edit Sale" : "Record Sale" %></span>
            <button class="modal-close" onclick="closeModal('addModal')" type="button">&times;</button>
        </div>
        <form method="post" action="<%= cp %>/sales">
            <input type="hidden" name="action" value="<%= editSale != null ? "edit" : "add" %>">
            <% if (editSale != null) { %>
                <input type="hidden" name="id" value="<%= editSale.getId() %>">
            <% } %>
            <div class="modal-body">
                <div class="form-group">
                    <label>Animal *</label>
                    <select name="livestockId" required>
                        <option value="">Select animal...</option>
                        <% if (active != null) { for (Livestock l : active) {
                            String sel = (editSale != null && editSale.getLivestockId() == l.getId()) ? "selected" : "";
                        %>
                            <option value="<%= l.getId() %>" <%= sel %>><%= l.getTag() %> — <%= l.getSpecies() %> (<%= l.getBreed() != null ? l.getBreed() : "Unknown" %>)</option>
                        <% }} %>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Buyer *</label>
                        <input type="text" name="buyer" placeholder="Buyer name" required
                               value="<%= editSale != null ? editSale.getBuyer() : "" %>">
                    </div>
                    <div class="form-group">
                        <label>Sale Type *</label>
                        <select name="saleType" required>
                            <option value="Direct" <%= editSale != null && "Direct".equals(editSale.getSaleType()) ? "selected" : "" %>>Direct</option>
                            <option value="Auction" <%= editSale != null && "Auction".equals(editSale.getSaleType()) ? "selected" : "" %>>Auction</option>
                            <option value="Export" <%= editSale != null && "Export".equals(editSale.getSaleType()) ? "selected" : "" %>>Export</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Sale Date *</label>
                        <input type="date" name="saleDate" required
                               value="<%= editSale != null ? editSale.getSaleDate().toLocalDate().toString() : "" %>">
                    </div>
                    <div class="form-group">
                        <label>Price (N$) *</label>
                        <input type="number" name="price" step="0.01" min="0" required placeholder="0.00"
                               value="<%= editSale != null ? editSale.getPrice().toString() : "" %>">
                    </div>
                </div>
                <div class="form-group">
                    <label>Payment Status *</label>
                    <select name="paymentStatus" required>
                        <option value="Pending" <%= editSale != null && "Pending".equals(editSale.getPaymentStatus()) ? "selected" : "" %>>Pending</option>
                        <option value="Paid" <%= editSale != null && "Paid".equals(editSale.getPaymentStatus()) ? "selected" : "" %>>Paid (marks animal as Sold)</option>
                        <option value="Partial" <%= editSale != null && "Partial".equals(editSale.getPaymentStatus()) ? "selected" : "" %>>Partial</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Notes</label>
                    <textarea name="notes" rows="2"><%= editSale != null && editSale.getNotes() != null ? editSale.getNotes() : "" %></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeModal('addModal')">Cancel</button>
                <button type="submit" class="btn btn-earth"><%= editSale != null ? "Update Sale" : "Save Sale" %></button>
            </div>
        </form>
    </div>
</div>
<script>
    function openModal(id){document.getElementById(id).classList.add('open');}
    function closeModal(id){document.getElementById(id).classList.remove('open');}
    function handleOverlayClick(e,id){if(e.target===document.getElementById(id))closeModal(id);}
    document.addEventListener('keydown',function(e){if(e.key==='Escape')document.querySelectorAll('.modal-overlay.open').forEach(m=>m.classList.remove('open'));});
    <% if (editSale != null) { %> openModal('addModal'); <% } %>
</script>
</body>
</html>