<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*,java.math.BigDecimal" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    BigDecimal income    = (BigDecimal) request.getAttribute("totalIncome");
    BigDecimal expenses  = (BigDecimal) request.getAttribute("totalExpenses");
    BigDecimal net       = (BigDecimal) request.getAttribute("netPosition");
    int active           = (Integer)    request.getAttribute("activeLivestock");
    List<Sale> sales     = (List<Sale>) request.getAttribute("recentSales");
    List<Expense> exps   = (List<Expense>) request.getAttribute("recentExpenses");
    List<Object[]> cats  = (List<Object[]>) request.getAttribute("expByCategory");

    BigDecimal maxCat = BigDecimal.ONE;
    if (cats != null) for (Object[] r : cats) { BigDecimal v = (BigDecimal)r[1]; if (v.compareTo(maxCat) > 0) maxCat = v; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
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

        <%-- Stat cards --%>
        <div class="stat-grid">
            <div class="stat-card green">
                <div class="stat-icon">💰</div>
                <div class="stat-label">Total Income</div>
                <div class="stat-value">N$&nbsp;<%= String.format("%,.0f", income) %></div>
                <div class="stat-sub">Paid sales</div>
            </div>
            <div class="stat-card red">
                <div class="stat-icon">🧾</div>
                <div class="stat-label">Total Expenses</div>
                <div class="stat-value">N$&nbsp;<%= String.format("%,.0f", expenses) %></div>
                <div class="stat-sub">All categories</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon">📊</div>
                <div class="stat-label">Net Position</div>
                <div class="stat-value" style="color:<%= net.compareTo(BigDecimal.ZERO) >= 0 ? "var(--leaf)" : "var(--danger)" %>">
                    N$&nbsp;<%= String.format("%,.0f", net) %>
                </div>
                <div class="stat-sub">Income − Expenses</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-icon">🐄</div>
                <div class="stat-label">Active Livestock</div>
                <div class="stat-value"><%= active %></div>
                <div class="stat-sub">Animals on farm</div>
            </div>
        </div>

        <%-- Main grid --%>
        <div class="dash-grid">

            <%-- Recent Sales --%>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Recent Sales</span>
                    <a href="<%= request.getContextPath() %>/sales" class="btn btn-sm btn-outline">View All</a>
                </div>
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

            <%-- Expenses by category --%>
            <div class="card">
                <div class="card-header">
                    <span class="card-title">Expenses by Category</span>
                    <a href="<%= request.getContextPath() %>/expenses" class="btn btn-sm btn-outline">View All</a>
                </div>
                <div class="chart-bar-wrap">
                <% if (cats == null || cats.isEmpty()) { %>
                    <p style="color:var(--muted);text-align:center;padding:16px">No expense data</p>
                <% } else {
                    String[] barColors = {"","green","red","blue","","green","red"};
                    int ci = 0;
                    for (Object[] row : cats) {
                        String cat = (String) row[0];
                        BigDecimal val = (BigDecimal) row[1];
                        int pct = val.multiply(new BigDecimal(100)).divide(maxCat, 0, java.math.RoundingMode.HALF_UP).intValue();
                        String color = barColors[ci % barColors.length]; ci++;
                %>
                <div class="chart-row">
                    <div class="chart-label"><%= cat %></div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill <%= color %>" style="width:<%= pct %>%">
                            N$<%= String.format("%,.0f", val) %>
                        </div>
                    </div>
                </div>
                <% } } %>
                </div>
            </div>

            <%-- Recent Expenses --%>
            <div class="card" style="grid-column: 1 / -1;">
                <div class="card-header">
                    <span class="card-title">Recent Expenses</span>
                    <a href="<%= request.getContextPath() %>/expenses" class="btn btn-sm btn-outline">View All</a>
                </div>
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

        </div><%-- /dash-grid --%>
    </div>
</div>
<script>
    document.getElementById('today-date').textContent = new Date().toLocaleDateString('en-NA', {weekday:'long',year:'numeric',month:'long',day:'numeric'});
</script>
</body>
</html>
