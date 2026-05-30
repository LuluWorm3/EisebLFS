<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*,java.math.BigDecimal" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    BigDecimal income    = (BigDecimal)  request.getAttribute("totalIncome");
    BigDecimal expenses  = (BigDecimal)  request.getAttribute("totalExpenses");
    BigDecimal net       = (BigDecimal)  request.getAttribute("netPosition");
    int saleCount        = (Integer)     request.getAttribute("paidSaleCount");
    List<Object[]> cats  = (List<Object[]>) request.getAttribute("expByCategory");
    List<Sale>     sales = (List<Sale>)     request.getAttribute("allSales");
    List<Expense>  exps  = (List<Expense>)  request.getAttribute("allExpenses");

    BigDecimal maxCat = BigDecimal.ONE;
    if (cats != null) for (Object[] r : cats) { BigDecimal v=(BigDecimal)r[1]; if(v.compareTo(maxCat)>0) maxCat=v; }
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Financial Reports — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;} .main{flex:1;}</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">Financial Reports</span> <a href="<%= cp %>/export?type=sales" class="btn btn-sm btn-outline">📥 Export Sales CSV</a> <a href="<%= cp %>/export?type=expenses" class="btn btn-sm btn-outline">📥 Export Expenses CSV</a> <a href="<%= cp %>/export?type=livestock" class="btn btn-sm btn-outline">📥 Export Livestock CSV</a></div>
    <div class="content">
        <div class="section-header">
            <div>
                <div class="section-title">Financial Summary</div>
                <div class="section-sub">All-time overview</div>
            </div>
        </div>

        <%-- Summary boxes --%>
        <div class="report-summary">
            <div class="report-box">
                <div class="rb-label">Total Income</div>
                <div class="rb-value income">N$&nbsp;<%= String.format("%,.0f", income) %></div>
                <div style="font-size:12px;color:var(--muted)"><%= saleCount %> paid sale(s)</div>
            </div>
            <div class="report-box">
                <div class="rb-label">Total Expenses</div>
                <div class="rb-value expense">N$&nbsp;<%= String.format("%,.0f", expenses) %></div>
                <div style="font-size:12px;color:var(--muted)"><%= exps != null ? exps.size() : 0 %> entries</div>
            </div>
            <div class="report-box">
                <div class="rb-label">Net Position</div>
                <div class="rb-value net" style="color:<%= net.compareTo(BigDecimal.ZERO)>=0 ? "var(--leaf)" : "var(--danger)" %>">
                    N$&nbsp;<%= String.format("%,.0f", net) %>
                </div>
                <div style="font-size:12px;color:var(--muted)"><%= net.compareTo(BigDecimal.ZERO)>=0 ? "Profit" : "Loss" %></div>
            </div>
        </div>

        <div class="dash-grid" style="margin-bottom:28px">
            <%-- Expense breakdown --%>
            <div class="card">
                <div class="card-header"><span class="card-title">Expenses by Category</span></div>
                <div class="chart-bar-wrap">
                <% if (cats == null || cats.isEmpty()) { %>
                    <p style="color:var(--muted);text-align:center;padding:16px">No data</p>
                <% } else { String[] colors={"","green","red","blue","","green"}; int ci=0;
                   for (Object[] row : cats) {
                     String cat=(String)row[0]; BigDecimal val=(BigDecimal)row[1];
                     int pct=val.multiply(new BigDecimal(100)).divide(maxCat,0,java.math.RoundingMode.HALF_UP).intValue();
                     String col=colors[ci%colors.length]; ci++; %>
                <div class="chart-row">
                    <div class="chart-label"><%= cat %></div>
                    <div class="chart-bar-bg">
                        <div class="chart-bar-fill <%= col %>" style="width:<%= pct %>%">N$<%= String.format("%,.0f",val) %></div>
                    </div>
                </div>
                <% } } %>
                </div>
            </div>

            <%-- Income vs Expenses bar --%>
            <div class="card">
                <div class="card-header"><span class="card-title">Income vs Expenses</span></div>
                <div class="chart-bar-wrap" style="padding-top:28px">
                    <%
                        BigDecimal maxIE = income.max(expenses).max(BigDecimal.ONE);
                        int iPct = income.multiply(new BigDecimal(100)).divide(maxIE,0,java.math.RoundingMode.HALF_UP).intValue();
                        int ePct = expenses.multiply(new BigDecimal(100)).divide(maxIE,0,java.math.RoundingMode.HALF_UP).intValue();
                    %>
                    <div class="chart-row">
                        <div class="chart-label">Income</div>
                        <div class="chart-bar-bg"><div class="chart-bar-fill green" style="width:<%= iPct %>%">N$<%= String.format("%,.0f",income) %></div></div>
                    </div>
                    <div class="chart-row">
                        <div class="chart-label">Expenses</div>
                        <div class="chart-bar-bg"><div class="chart-bar-fill red" style="width:<%= ePct %>%">N$<%= String.format("%,.0f",expenses) %></div></div>
                    </div>
                    <div class="chart-row">
                        <div class="chart-label">Net</div>
                        <div class="chart-bar-bg">
                            <div class="chart-bar-fill <%= net.compareTo(BigDecimal.ZERO)>=0 ? "green" : "red" %>"
                                 style="width:<%= net.abs().multiply(new BigDecimal(100)).divide(maxIE,0,java.math.RoundingMode.HALF_UP).intValue() %>%">
                                N$<%= String.format("%,.0f",net) %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Full transaction log --%>
        <div class="full-card">
            <div class="card-header"><span class="card-title">All Sales</span></div>
            <table>
                <thead><tr><th>Date</th><th>Tag</th><th>Buyer</th><th>Type</th><th>Price</th><th>Status</th></tr></thead>
                <tbody>
                <% if (sales == null || sales.isEmpty()) { %>
                    <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:20px">No sales data</td></tr>
                <% } else { for (Sale s : sales) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= s.getSaleDate() %></td>
                        <td><strong style="font-family:'DM Mono',monospace"><%= s.getLivestockTag() %></strong></td>
                        <td><%= s.getBuyer() %></td>
                        <td><%= s.getSaleType() %></td>
                        <td>N$&nbsp;<%= String.format("%,.2f", s.getPrice()) %></td>
                        <td><span class="badge <%= "Paid".equals(s.getPaymentStatus()) ? "badge-green" : "Pending".equals(s.getPaymentStatus()) ? "badge-yellow" : "badge-blue" %>"><%= s.getPaymentStatus() %></span></td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
