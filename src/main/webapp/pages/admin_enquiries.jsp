<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    if (session.getAttribute("currentUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Enquiry> enquiries = (List<Enquiry>) request.getAttribute("enquiries");
    String cp = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Enquiries — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <style>body{display:flex;}.main{flex:1;}</style>
</head>
<body>
<%@ include file="/WEB-INF/nav.jsp" %>
<div class="main">
    <div class="topbar"><span class="page-title">Enquiries</span></div>
    <div class="content">
        <div class="full-card">
            <table>
                <thead><tr><th>Date</th><th>Name</th><th>Email</th><th>Subject</th><th>Message</th></tr></thead>
                <tbody>
                <% if (enquiries == null || enquiries.isEmpty()) { %>
                    <tr><td colspan="5" style="text-align:center;color:var(--muted);padding:40px">No enquiries yet.</td></tr>
                <% } else { for (Enquiry e : enquiries) { %>
                    <tr>
                        <td style="font-family:'DM Mono',monospace;font-size:12px"><%= e.getSubmittedAt() %></td>
                        <td><%= e.getFullName() %></td>
                        <td><%= e.getEmail() %></td>
                        <td><%= e.getSubject() != null ? e.getSubject() : "—" %></td>
                        <td><%= e.getMessage() %></td>
                    </tr>
                <% }} %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
