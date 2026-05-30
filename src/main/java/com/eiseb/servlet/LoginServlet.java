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
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Username: " + username);
        System.out.println("Password: " + (password != null ? "***" : "null"));

        try {
            UserDAO dao = new UserDAO(getServletContext());
            System.out.println("UserDAO created, attempting authentication...");
            
            User user = dao.authenticate(username, password);
            System.out.println("Authentication result: " + (user != null ? "SUCCESS - " + user.getUsername() : "FAILED"));
            
            if (user != null) {
                HttpSession session = req.getSession(true);
                session.setAttribute("currentUser", user);
                session.setMaxInactiveInterval(60 * 60);
                System.out.println("Redirecting to dashboard");
                resp.sendRedirect(req.getContextPath() + "/dashboard");
            } else {
                System.out.println("Login failed - invalid credentials");
                req.setAttribute("loginError", "Invalid username or password.");
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            System.out.println("DATABASE ERROR: " + e.getMessage());
            e.printStackTrace();
            req.setAttribute("loginError", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }
}
