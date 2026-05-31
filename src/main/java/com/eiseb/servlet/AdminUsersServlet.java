package com.eiseb.servlet;

import com.eiseb.dao.UserDAO;
import com.eiseb.model.User;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class AdminUsersServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }
        try {
            UserDAO dao = new UserDAO(getServletContext());
            List<User> users = dao.findAll();
            req.setAttribute("users", users);
            req.getRequestDispatcher("/pages/admin_users.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }
        String action = req.getParameter("action");
        UserDAO dao = new UserDAO(getServletContext());
        try {
            if ("add".equals(action)) {
                String fullName = req.getParameter("fullName");
                String username = req.getParameter("username");
                String email    = req.getParameter("email");
                String password = req.getParameter("password");
                String role     = req.getParameter("role");
                dao.register(fullName, username, email, password, role);
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String fullName = req.getParameter("fullName");
                String email    = req.getParameter("email");
                String role     = req.getParameter("role");
                String password = req.getParameter("password");
                dao.updateUser(id, fullName, email, role);
                if (password != null && !password.isBlank()) {
                    dao.updatePassword(id, password);
                }
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                User currentUser = SecurityUtil.getLoggedUser(req);
                if (currentUser != null && currentUser.getId() == id) {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot delete your own account");
                    return;
                }
                dao.deleteUser(id);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
