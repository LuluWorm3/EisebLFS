<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Server Error — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
</head>
<body style="display:flex;align-items:center;justify-content:center;min-height:100vh;background:var(--surface)">
    <div style="text-align:center;padding:48px">
        <div style="font-size:64px;margin-bottom:16px">⚠️</div>
        <h1 style="font-family:'Playfair Display',serif;font-size:48px;color:var(--danger);margin-bottom:8px">500</h1>
        <p style="color:var(--muted);font-size:16px;margin-bottom:8px">Something went wrong on the server.</p>
        <% if (exception != null) { %>
            <p style="font-family:'DM Mono',monospace;font-size:12px;color:var(--danger);background:#fff5f5;padding:12px 20px;border-radius:4px;display:inline-block;margin-bottom:20px;max-width:600px;word-break:break-all">
                <%= exception.getMessage() %>
            </p>
        <% } %>
        <br>
        <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-earth">← Back to Dashboard</a>
    </div>
</body>
</html>
