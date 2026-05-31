package com.eiseb.servlet;

import com.eiseb.dao.UserDAO;
import com.eiseb.model.User;
import com.eiseb.util.PasswordUtil;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class ProfileServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        req.getRequestDispatcher("/pages/profile.jsp").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        User currentUser = SecurityUtil.getLoggedUser(req);
        String action = req.getParameter("action");
        UserDAO dao = new UserDAO(getServletContext());
        try {
            if ("updateProfile".equals(action)) {
                String fullName = req.getParameter("fullName");
                String email = req.getParameter("email");
                dao.updateUser(currentUser.getId(), fullName, email, currentUser.getRole());
                // Refresh session user
                User updated = dao.findByUsername(currentUser.getUsername());
                if (updated != null) {
                    req.getSession().setAttribute("currentUser", updated);
                }
                req.getSession().setAttribute("toastMsg", "Profile updated.");
                req.getSession().setAttribute("toastType", "success");
            } else if ("changePassword".equals(action)) {
                String oldPassword = req.getParameter("oldPassword");
                String newPassword = req.getParameter("newPassword");
                User dbUser = dao.findByUsername(currentUser.getUsername());
                if (dbUser != null && PasswordUtil.verify(oldPassword, dbUser.getPassword())) {
                    dao.updatePassword(currentUser.getId(), newPassword);
                    req.getSession().setAttribute("toastMsg", "Password changed.");
                    req.getSession().setAttribute("toastType", "success");
                } else {
                    req.getSession().setAttribute("toastMsg", "Current password incorrect.");
                    req.getSession().setAttribute("toastType", "error");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("toastMsg", "Error updating profile.");
            req.getSession().setAttribute("toastType", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
