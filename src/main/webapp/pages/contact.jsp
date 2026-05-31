<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.eiseb.model.*,java.util.*" %>
<%
    List<Enquiry> enquiries = (List<Enquiry>) request.getAttribute("enquiries");
    String cp = request.getContextPath();
    boolean loggedIn = session.getAttribute("currentUser") != null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Contact Us — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= cp %>/css/main.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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

        <div class="contact-grid">
            <%-- Enquiry form --%>
            <div class="card" style="overflow:visible">
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
                        <button type="submit" class="btn btn-earth" style="width:100%">Send Message →</button>
                    </form>
                </div>
            </div>

            <%-- Contact details --%>
            <div>
                <div class="card" style="margin-bottom:20px">
                    <div class="card-header"><span class="card-title">Contact Details</span></div>
                    <div style="padding:24px">
                        <div class="contact-detail">
                            <div class="icon">📍</div>
                            <div>
                                <div class="label">Address</div>
                                <div class="value">Eiseb District, Omaheke Region<br>Namibia</div>
                            </div>
                        </div>
                        <div class="contact-detail">
                            <div class="icon">📞</div>
                            <div>
                                <div class="label">Phone</div>
                                <div class="value">+264 61 000 0000</div>
                            </div>
                        </div>
                        <div class="contact-detail">
                            <div class="icon">✉️</div>
                            <div>
                                <div class="label">Email</div>
                                <div class="value">info@eiseblfs.na</div>
                            </div>
                        </div>
                        <div class="contact-detail">
                            <div class="icon">🕐</div>
                            <div>
                                <div class="label">Office Hours</div>
                                <div class="value">Mon–Fri: 08:00–17:00<br>Sat: 08:00–13:00</div>
                            </div>
                        </div>
                    </div>
                </div>

                <% if (loggedIn && enquiries != null && !enquiries.isEmpty()) { %>
                <div class="card">
                    <div class="card-header"><span class="card-title">Recent Enquiries</span></div>
                    <div class="table-responsive">
<div class="table-responsive">
<table>
                        <thead><tr><th>Name</th><th>Subject</th><th>Date</th></tr></thead>
                        <tbody>
                        <% for (Enquiry e : enquiries) { %>
                            <tr>
                                <td><%= e.getFullName() %><br><small style="color:var(--muted)"><%= e.getEmail() %></small></td>
                                <td><%= e.getSubject() != null ? e.getSubject() : "—" %></td>
                                <td style="font-family:'DM Mono',monospace;font-size:11px"><%= e.getSubmittedAt() %></td>
                                <td>
    <%= e.getReply() != null ? e.getReply() : "" %>
    <% if (loggedIn && "admin".equals(((User)session.getAttribute("currentUser")).getRole())) { %>
        <form method="post" action="<%= cp %>/contact" style="margin-top:4px;">
            <input type="hidden" name="action" value="reply">
            <input type="hidden" name="id" value="<%= e.getId() %>">
            <textarea name="reply" rows="2" style="width:100%;"></textarea>
            <button type="submit" class="btn btn-sm btn-earth">Reply</button>
        </form>
    <% } %>
</td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
</div>
</div>
                </div>
                <% } %>
            </div>
        </div>

    </div>
</div>
</body>
</html>
