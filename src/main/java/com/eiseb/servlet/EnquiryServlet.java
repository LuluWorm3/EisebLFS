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
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            try {
                req.setAttribute("enquiries", new EnquiryDAO(getServletContext()).findAll());
            } catch (Exception e) {}
        }
        req.getRequestDispatcher("/pages/contact.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Enquiry e = new Enquiry();
            e.setFullName(req.getParameter("fullName").trim());
            e.setEmail(req.getParameter("email").trim());
            String subj = req.getParameter("subject");
            e.setSubject(subj != null ? subj.trim() : "General Enquiry");
            String msg = req.getParameter("message") != null ? req.getParameter("message").trim() : "";
            e.setMessage(msg);
            new EnquiryDAO(getServletContext()).insert(e);

            String redirectTo = req.getParameter("redirectTo");
            if ("landing".equals(redirectTo)) {
                resp.sendRedirect(req.getContextPath() + "/landing.jsp?sent=true");
            } else {
                req.setAttribute("enquirySuccess", "Your message has been sent. Thank you!");
                if (req.getSession().getAttribute("currentUser") != null) {
                    try {
                        req.setAttribute("enquiries", new EnquiryDAO(getServletContext()).findAll());
                    } catch (Exception ex) {}
                }
                req.getRequestDispatcher("/pages/contact.jsp").forward(req, resp);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
}
