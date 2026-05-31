package com.eiseb.servlet;

import com.eiseb.dao.EnquiryDAO;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AdminEnquiriesServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }
        try {
            EnquiryDAO dao = new EnquiryDAO(getServletContext());
            req.setAttribute("enquiries", dao.findAll());
            req.getRequestDispatcher("/pages/admin_enquiries.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
