package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.model.Livestock;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class LivestockServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            LivestockDAO dao = new LivestockDAO(getServletContext());
            String filter = req.getParameter("filter");
            if (filter != null && !filter.equals("All")) {
                req.setAttribute("livestock", dao.findByStatus(filter));
            } else {
                req.setAttribute("livestock", dao.findAll());
            }
            req.setAttribute("filter", filter != null ? filter : "All");
            req.getRequestDispatcher("/pages/livestock.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");
        try {
            LivestockDAO dao = new LivestockDAO(getServletContext());

            if ("add".equals(action)) {
                Livestock l = new Livestock();
                l.setTag(req.getParameter("tag").trim().toUpperCase());
                l.setSpecies(req.getParameter("species"));
                l.setBreed(req.getParameter("breed"));
                l.setGender(req.getParameter("gender"));
                String dob = req.getParameter("dob");
                if (dob != null && !dob.isBlank()) l.setDob(Date.valueOf(dob));
                String val = req.getParameter("currentValue");
                l.setCurrentValue(val != null && !val.isBlank() ? new BigDecimal(val) : BigDecimal.ZERO);
                l.setStatus("Active");
                dao.insert(l);
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                dao.delete(id);
            } else if ("status".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                dao.updateStatus(id, req.getParameter("status"));
            }
            resp.sendRedirect(req.getContextPath() + "/livestock");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
