package com.eiseb.servlet;

import com.eiseb.dao.AuditDAO;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AdminAuditServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            AuditDAO dao = new AuditDAO(getServletContext());
            List<String[]> logs = dao.getRecentLogs(200);
            req.setAttribute("logs", logs);
            req.getRequestDispatcher("/pages/audit_log.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }
}