package com.eiseb.servlet;

import com.eiseb.dao.EnquiryDAO;
import com.eiseb.model.Enquiry;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class EnquiryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            req.setAttribute("enquiries", new EnquiryDAO(getServletContext()).findAll());
            req.getRequestDispatcher("/pages/contact.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        EnquiryDAO dao = new EnquiryDAO(getServletContext());
        try {
            if ("reply".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String replyText = req.getParameter("reply");
                dao.reply(id, replyText);
                req.getSession().setAttribute("toastMsg", "Reply sent.");
                req.getSession().setAttribute("toastType", "success");
                resp.sendRedirect(req.getContextPath() + "/contact");
            } else {
                // Original contact form submission (does not require login)
                Enquiry e = new Enquiry();
                e.setFullName(req.getParameter("fullName").trim());
                e.setEmail(req.getParameter("email").trim());
                e.setSubject(req.getParameter("subject") != null ? req.getParameter("subject").trim() : "");
                e.setMessage(req.getParameter("message").trim());
                dao.insert(e);
                req.setAttribute("enquirySuccess", "Your message has been sent. Thank you!");
                req.setAttribute("enquiries", dao.findAll());
                req.getRequestDispatcher("/pages/contact.jsp").forward(req, resp);
            }
        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
