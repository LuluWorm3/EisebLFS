<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><title>Page Not Found — Eiseb LFS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
</head>
<body style="display:flex;align-items:center;justify-content:center;min-height:100vh;background:var(--surface)">
    <div style="text-align:center;padding:48px">
        <div style="font-size:64px;margin-bottom:16px">🐄</div>
        <h1 style="font-family:'Playfair Display',serif;font-size:48px;color:var(--earth);margin-bottom:8px">404</h1>
        <p style="color:var(--muted);font-size:16px;margin-bottom:24px">This page wandered off. We can't find it.</p>
        <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-earth">← Back to Dashboard</a>
    </div>
</body>
</html>
