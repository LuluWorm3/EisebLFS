package com.eiseb.servlet;

import com.eiseb.dao.UserDAO;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String username = req.getParameter("username");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String role     = req.getParameter("role");

        // Basic validation
        if (fullName == null || username == null || email == null ||
            password == null || fullName.isBlank() || username.isBlank() ||
            email.isBlank() || password.isBlank()) {
            req.setAttribute("registerError", "All fields are required.");
            req.setAttribute("showRegister", true);
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }
        if (role == null || role.isBlank()) role = "staff";

        try {
            UserDAO dao = new UserDAO(getServletContext());
            boolean ok = dao.register(fullName, username, email, password, role);
            if (ok) {
                req.setAttribute("registerSuccess", "Account created! Please sign in.");
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
            } else {
                req.setAttribute("registerError", "Username or email already exists.");
                req.setAttribute("showRegister", true);
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            req.setAttribute("registerError", "Registration failed. Please try again.");
            req.setAttribute("showRegister", true);
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
        }
    }
}
