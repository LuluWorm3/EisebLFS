<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*,java.math.BigDecimal" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    BigDecimal income    = (BigDecimal) request.getAttribute("totalIncome");
    BigDecimal expenses  = (BigDecimal) request.getAttribute("totalExpenses");
    BigDecimal net       = (BigDecimal) request.getAttribute("netPosition");
    BigDecimal margin    = (BigDecimal) request.getAttribute("profitMargin");
    int active           = (Integer)    request.getAttribute("activeLivestock");
    List<Sale> sales     = (List<Sale>) request.getAttribute("recentSales");
    List<Expense> exps   = (List<Expense>) request.getAttribute("recentExpenses");
    List<Object[]> cats  = (List<Object[]>) request.getAttribute("expByCategory");
    List<String[]> logs  = (List<String[]>) request.getAttribute("recentLogs");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        body { display:flex; }
        .main { flex:1; }
    </style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar">
        <span class="page-title">Dashboard</span>
        <span class="date-badge" id="today-date"></span>
    </div>
    <div class="content">
        <div class="stat-grid">
            <div class="stat-card green">
                <div class="stat-label">Total Income</div>
                <div class="stat-value">N$&nbsp;<%= String.format("%,.0f", income) %></div>
                <div class="stat-sub">Paid sales</div>
            </div>
            <div class="stat-card red">
                <div class="stat-label">Total Expenses</div>
                <div class="stat-value">N$&nbsp;<%= String.format("%,.0f", expenses) %></div>
                <div class="stat-sub">All categories</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Net Position</div>
                <div class="stat-value" style="color:<%= net.compareTo(BigDecimal.ZERO) >= 0 ? "var(--leaf)" : "var(--danger)" %>">
                    N$&nbsp;<%= String.format("%,.0f", net) %>
                </div>
                <div class="stat-sub">Income - Expenses</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-label">Active Livestock</div>
                <div class="stat-value"><%= active %></div>
                <div class="stat-sub">Animals on farm</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Profit Margin</div>
                <div class="stat-value" style="color:<%= margin != null && margin.compareTo(BigDecimal.ZERO) >= 0 ? "var(--leaf)" : "var(--danger)" %>">
                    <%= margin != null ? String.format("%.1f", margin) : "0.0" %>%
                </div>
                <div class="stat-sub">Net / Income</div>
            </div>
        </div>

        <div class="dash-grid">
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Recent Sales</span>
                    <a href="<%= request.getContextPath() %>/sales" class="btn btn-sm btn-outline">View All</a>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Tag</th><th>Buyer</th><th>Amount</th><th>Status</th></tr></thead>
                        <tbody>
                        <% if (sales == null || sales.isEmpty()) { %>
                            <tr><td colspan="4" style="text-align:center;color:var(--muted);padding:24px">No sales recorded yet</td></tr>
                        <% } else { for (Sale s : sales) { %>
                            <tr>
                                <td><strong><%= s.getLivestockTag() %></strong></td>
                                <td><%= s.getBuyer() %></td>
                                <td>N$&nbsp;<%= String.format("%,.0f", s.getPrice()) %></td>
                                <td>
                                    <span class="badge <%= "Paid".equals(s.getPaymentStatus()) ? "badge-green" : "Pending".equals(s.getPaymentStatus()) ? "badge-yellow" : "badge-blue" %>">
                                        <%= s.getPaymentStatus() %>
                                    </span>
                                </td>
                            </tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span class="card-title">Expenses by Category</span>
                    <a href="<%= request.getContextPath() %>/expenses" class="btn btn-sm btn-outline">View All</a>
                </div>
                <% if (cats != null && !cats.isEmpty()) { %>
                    <canvas id="expenseChart" height="200" style="max-height:200px;"></canvas>
                <% } else { %>
                    <p style="color:var(--muted);text-align:center;padding:24px">No expense data yet.</p>
                <% } %>
            </div>

            <div class="card" style="grid-column: 1 / -1;">
                <div class="card-header">
                    <span class="card-title">Recent Expenses</span>
                    <a href="<%= request.getContextPath() %>/expenses" class="btn btn-sm btn-outline">View All</a>
                </div>
                <div class="table-wrap">
                    <table>
                        <thead><tr><th>Date</th><th>Category</th><th>Description</th><th>Animal</th><th>Amount</th></tr></thead>
                        <tbody>
                        <% if (exps == null || exps.isEmpty()) { %>
                            <tr><td colspan="5" style="text-align:center;color:var(--muted);padding:24px">No expenses recorded yet</td></tr>
                        <% } else { for (Expense e : exps) { %>
                            <tr>
                                <td style="font-family:'DM Mono',monospace;font-size:12px"><%= e.getExpenseDate() %></td>
                                <td><span class="badge badge-gray"><%= e.getCategory() %></span></td>
                                <td><%= e.getDescription() != null ? e.getDescription() : "—" %></td>
                                <td><%= e.getLivestockTag() != null ? e.getLivestockTag() : "—" %></td>
                                <td><strong>N$&nbsp;<%= String.format("%,.0f", e.getAmount()) %></strong></td>
                            </tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <%-- Recent Activity (Audit Log) --%>
        <div class="full-card" style="margin-top:28px;">
            <div class="card-header">
                <span class="card-title">Recent Activity</span>
                <a href="<%= request.getContextPath() %>/admin/audit" class="btn btn-sm btn-outline">View All</a>
            </div>
            <div class="table-wrap">
                <table>
                    <thead><tr><th>User</th><th>Action</th><th>Entity</th><th>Details</th><th>Time</th></tr></thead>
                    <tbody>
                    <% if (logs == null || logs.isEmpty()) { %>
                        <tr><td colspan="5" style="text-align:center;color:var(--muted);padding:24px">No activity yet</td></tr>
                    <% } else { for (String[] log : logs) { %>
                        <tr>
                            <td><strong><%= log[0] %></strong></td>
                            <td><span style="font-size:11px;text-transform:uppercase;font-weight:700;color:<%= "INSERT".equals(log[1]) ? "#2E7D32" : "UPDATE".equals(log[1]) ? "#E65100" : "#C62828" %>"><%= log[1] %></span></td>
                            <td><%= log[2] %></td>
                            <td><%= log[4] %></td>
                            <td style="font-family:'DM Mono',monospace;font-size:11px"><%= log[5] %></td>
                        </tr>
                    <% }} %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>
<script>
    document.getElementById('today-date').textContent = new Date().toLocaleDateString('en-NA', {weekday:'long',year:'numeric',month:'long',day:'numeric'});
    <% if (cats != null && !cats.isEmpty()) { %>
    var ctx = document.getElementById('expenseChart').getContext('2d');
    new Chart(ctx, {
        type: 'pie',
        data: {
            labels: [<% for (Object[] row : cats) { out.print("\"" + row[0] + "\","); } %>],
            datasets: [{
                data: [<% for (Object[] row : cats) { out.print(row[1] + ","); } %>],
                backgroundColor: ['#4CAF50','#FF6384','#36A2EB','#FFCE56','#9966FF','#8B5E3C']
            }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });
    <% } %>
</script>
</body>
</html>
