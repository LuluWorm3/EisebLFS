package com.eiseb.servlet;

import com.eiseb.dao.UserDAO;
import com.eiseb.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // FORCE output to both log and browser (temporary debugging)
        System.err.println("=========================================");
        System.err.println("REGISTER SERVLET WAS CALLED!");
        System.err.println("=========================================");
        
        String fullName = req.getParameter("fullName");
        String username = req.getParameter("username");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String role     = req.getParameter("role");

        System.err.println("fullName = [" + fullName + "]");
        System.err.println("username = [" + username + "]");
        System.err.println("email    = [" + email + "]");
        System.err.println("password = [" + password + "]");
        System.err.println("role     = [" + role + "]");

        // Basic validation
        if (fullName == null || username == null || email == null ||
            password == null || fullName.isBlank() || username.isBlank() ||
            email.isBlank() || password.isBlank()) {
            System.err.println("VALIDATION FAILED: missing required fields");
            req.setAttribute("registerError", "All fields are required.");
            req.setAttribute("showRegister", true);
            req.getRequestDispatcher("/index.jsp").forward(req, resp);
            return;
        }
        if (role == null || role.isBlank()) role = "staff";

        try {
            // Test database connection first
            System.err.println("Testing database connection...");
            try {
                Connection testConn = DBConnection.getConnection(getServletContext());
                System.err.println("Database connection SUCCESSFUL!");
                testConn.close();
            } catch (Exception dbErr) {
                System.err.println("DATABASE CONNECTION FAILED: " + dbErr.getMessage());
                dbErr.printStackTrace(System.err);
                throw dbErr;
            }
            
            System.err.println("Creating UserDAO with servlet context...");
            UserDAO dao = new UserDAO(getServletContext());
            
            System.err.println("Calling dao.register()...");
            boolean ok = dao.register(fullName, username, email, password, role);
            System.err.println("dao.register() returned: " + ok);
            
            if (ok) {
                System.err.println("REGISTRATION SUCCESS!");
                req.setAttribute("registerSuccess", "Account created! Please sign in.");
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
            } else {
                System.err.println("REGISTRATION FAILED: username or email already exists");
                req.setAttribute("registerError", "Username or email already exists.");
                req.setAttribute("showRegister", true);
                req.getRequestDispatcher("/index.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            System.err.println("EXCEPTION IN REGISTER SERVLET:");
            e.printStackTrace(System.err);
            
            // Also write to response so you can see in browser
            resp.setContentType("text/html");
            PrintWriter out = resp.getWriter();
            out.println("<html><body>");
            out.println("<h2>Registration Error:</h2>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
            out.println("<a href='index.jsp'>Go back</a>");
            out.println("</body></html>");
            return;
        }
    }
}