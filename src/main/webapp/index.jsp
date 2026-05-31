<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Eiseb LFS — Sign In</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
</head>
<body>
<div class="auth-wrap">
    <div class="auth-card">
        <div class="auth-logo">
            <span class="cattle-icon">🐄</span>
            <div class="brand">Eiseb Country Traders</div>
            <div class="sub">Livestock Financial System</div>
        </div>

        <%-- Tab switcher --%>
        <div class="auth-tabs">
            <div class="auth-tab <%= request.getAttribute("showRegister") != null ? "" : "active" %>" id="tab-login"    onclick="showTab('login')">Sign In</div>
            <div class="auth-tab <%= request.getAttribute("showRegister") != null ? "active" : "" %>" id="tab-register" onclick="showTab('register')">Register</div>
        </div>

        <%-- Alerts --%>
        <% if (request.getAttribute("loginError") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("loginError") %></div>
        <% } %>
        <% if (request.getAttribute("registerError") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("registerError") %></div>
        <% } %>
        <% if (request.getAttribute("registerSuccess") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("registerSuccess") %></div>
        <% } %>

        <%-- LOGIN FORM --%>
        <div id="form-login" style="<%= request.getAttribute("showRegister") != null ? "display:none" : "" %>">
            <form action="<%= request.getContextPath() %>/login" method="post">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="username" placeholder="admin" required autofocus>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="••••••••" required>
                </div>
                <button type="submit" class="btn-primary-wide">Sign In →</button>
            </form>
            <div class="auth-hint">Default login: <strong>admin</strong> / <strong>admin123</strong></div>
        </div>

        <%-- REGISTER FORM --%>
        <div id="form-register" style="<%= request.getAttribute("showRegister") != null ? "" : "display:none" %>">
            <form action="<%= request.getContextPath() %>/register" method="post">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName" placeholder="Your full name" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Username</label>
                        <input type="text" name="username" placeholder="username" required>
                    </div>
                    <div class="form-group">
                        <label>Role</label>
                        <select name="role">
                            <option value="staff">Staff</option>
                            <option value="manager">Manager</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="you@eiseb.na" required>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Choose a password" required minlength="6">
                </div>
                <button type="submit" class="btn-primary-wide">Create Account →</button>
            </form>
        </div>
    </div>
</div>
<script>
function showTab(tab) {
    document.getElementById('form-login').style.display    = tab === 'login'    ? '' : 'none';
    document.getElementById('form-register').style.display = tab === 'register' ? '' : 'none';
    document.getElementById('tab-login').classList.toggle('active',    tab === 'login');
    document.getElementById('tab-register').classList.toggle('active', tab === 'register');
}
</script>
<script>
var pwdInput = document.querySelector("#form-register input[name=password]");
if(pwdInput) {
  var meter = document.createElement("div");
  meter.style.cssText = "height:4px;background:#eee;border-radius:2px;margin-top:4px;transition:all 0.3s";
  pwdInput.parentNode.appendChild(meter);
  pwdInput.addEventListener("input",function(){
    var v=this.value,s=0;
    if(v.length>=6)s++;
    if(v.match(/\d/))s++;
    if(v.match(/[^a-zA-Z\d]/))s++;
    meter.style.width = (s*25)+"%";
    meter.style.background = s<=1 ? "#f44336" : s==2 ? "#ff9800" : s==3 ? "#2196F3" : "#4CAF50";
  });
}
</script>
</body>
</html>
