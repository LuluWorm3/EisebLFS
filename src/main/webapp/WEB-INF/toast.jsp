<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String toastMsg = (String) session.getAttribute("toastMsg");
    String toastType = (String) session.getAttribute("toastType");
    if (toastMsg != null) {
        session.removeAttribute("toastMsg");
        session.removeAttribute("toastType");
%>
<div id="toast" role="alert" class="toast toast-<%= toastType %>" style="
    position:fixed; top:20px; right:20px; z-index:9999;
    background:<%= "success".equals(toastType) ? "#2E7D32" : "#C62828" %>; color:white;
    padding:16px 24px; border-radius:4px; font-family:'DM Sans',sans-serif; font-size:14px;
    box-shadow:0 8px 24px rgba(0,0,0,0.25); display:flex; align-items:center; gap:12px;
    transition:opacity 0.3s ease;
">
    <span><%= toastMsg %></span>
    <button onclick="this.parentElement.remove()" style="background:none;border:none;color:white;cursor:pointer;font-size:18px">&times;</button>
</div>
<script>
    setTimeout(function() {
        var t = document.getElementById('toast');
        if (t) { t.style.opacity = '0'; setTimeout(function(){ t.remove(); }, 300); }
    }, 3000);
</script>
<% } %>
