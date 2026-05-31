<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    List<Enquiry> enquiries = (List<Enquiry>) request.getAttribute("enquiries");
    String cp = request.getContextPath();
    boolean loggedIn = session.getAttribute("currentUser") != null;
    // Only managers and admins can see the message list
    User currentUser = (User) session.getAttribute("currentUser");
    boolean canSeeMessages = currentUser != null && ("admin".equals(currentUser.getRole()) || "manager".equals(currentUser.getRole()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Contact Us — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
    <% if (loggedIn) { %><style>body{display:flex;} .main{flex:1;}</style><% } %>
</head>
<body>
<% if (loggedIn) { %><%@ include file="/WEB-INF/nav.jsp" %><% } %>
<div class="<%= loggedIn ? "main" : "" %>">
    <% if (loggedIn) { %><div class="topbar"><span class="page-title">Contact Us</span></div><% } %>
    <div class="content">
        <% if (request.getAttribute("enquirySuccess") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("enquirySuccess") %></div>
        <% } %>

        <div class="card" style="max-width:600px; margin:0 auto 24px;">
            <div class="card-header"><span class="card-title">Send Us a Message</span></div>
            <div style="padding:24px">
                <form method="post" action="<%= cp %>/contact">
                    <div class="form-group">
                        <label>Full Name *</label>
                        <input type="text" name="fullName" required placeholder="Your name">
                    </div>
                    <div class="form-group">
                        <label>Email *</label>
                        <input type="email" name="email" required placeholder="you@example.com">
                    </div>
                    <div class="form-group">
                        <label>Subject</label>
                        <input type="text" name="subject" placeholder="e.g. General Enquiry">
                    </div>
                    <div class="form-group">
                        <label>Message *</label>
                        <textarea name="message" rows="5" required placeholder="Your message..."></textarea>
                    </div>
                    <button type="submit" class="btn btn-earth" style="width:100%">Send Message</button>
                </form>
            </div>
        </div>

        <%-- Received Messages (managers & admins only) --%>
        <% if (canSeeMessages && enquiries != null && !enquiries.isEmpty()) { %>
        <div class="full-card">
            <div class="card-header"><span class="card-title">Received Messages</span></div>
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr><th>Date</th><th>Name</th><th>Email</th><th>Subject</th><th>Message</th></tr>
                    </thead>
                    <tbody>
                    <% for (Enquiry e : enquiries) { %>
                        <tr>
                            <td style="font-family:'DM Mono',monospace;font-size:12px"><%= e.getSubmittedAt() %></td>
                            <td><%= e.getFullName() %></td>
                            <td><%= e.getEmail() %></td>
                            <td><%= e.getSubject() != null ? e.getSubject() : "—" %></td>
                            <td><%= e.getMessage() %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>

        <div class="card" style="max-width:600px; margin:20px auto;">
            <div class="card-header"><span class="card-title">Contact Details</span></div>
            <div style="padding:24px">
                <p>Eiseb District, Omaheke Region, Namibia</p>
                <p>+264 61 000 0000 | info@eiseblfs.na</p>
                <p>Mon–Fri: 08:00–17:00 | Sat: 08:00–13:00</p>
            </div>
        </div>
    </div>
</div>
</body>
</html>
