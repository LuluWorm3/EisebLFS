package com.eiseb.servlet;

import com.eiseb.dao.UserDAO;
import com.eiseb.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Check lockout
        Long lockoutEnd = (Long) session.getAttribute("lockoutEnd");
        if (lockoutEnd != null && System.currentTimeMillis() < lockoutEnd) {
            long minsLeft = (lockoutEnd - System.currentTimeMillis()) / 60000 + 1;
            req.setAttribute("loginError", "Too many attempts. Try again in " + minsLeft + " minute(s).");
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }

        try {
            UserDAO dao = new UserDAO(getServletContext());
            User user = dao.authenticate(username, password);

            if (user != null) {
                session.removeAttribute("loginAttempts");
                session.removeAttribute("lockoutEnd");
                session.setAttribute("currentUser", user);
                session.setMaxInactiveInterval(60 * 60);
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                Integer attempts = (Integer) session.getAttribute("loginAttempts");
                if (attempts == null) attempts = 0;
                attempts++;
                session.setAttribute("loginAttempts", attempts);

                if (attempts >= 3) {
                    session.setAttribute("lockoutEnd", System.currentTimeMillis() + 10 * 60 * 1000);
                    req.setAttribute("loginError", "Too many failed attempts. Account locked for 10 minutes.");
                } else {
                    req.setAttribute("loginError", "Invalid username or password. Attempts: " + attempts);
                }
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("loginError", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }
}
