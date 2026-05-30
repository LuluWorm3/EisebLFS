package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.model.Livestock;
import com.eiseb.util.SecurityUtil;                     // NEW
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class LivestockServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Any logged‑in user can view
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            LivestockDAO dao = new LivestockDAO(getServletContext());

            String action = req.getParameter("action");
            if ("editForm".equals(action)) {
                // Only managers / admins may edit
                if (!SecurityUtil.isManagerOrAdmin(req)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                int id = Integer.parseInt(req.getParameter("id"));
                Livestock editLivestock = dao.findById(id);
                req.setAttribute("editLivestock", editLivestock);
            }

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
        // All write operations require manager or admin
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!SecurityUtil.isManagerOrAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

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

            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Livestock l = dao.findById(id);
                l.setTag(req.getParameter("tag").trim().toUpperCase());
                l.setSpecies(req.getParameter("species"));
                l.setBreed(req.getParameter("breed"));
                l.setGender(req.getParameter("gender"));
                String dob = req.getParameter("dob");
                if (dob != null && !dob.isBlank()) l.setDob(Date.valueOf(dob));
                String val = req.getParameter("currentValue");
                l.setCurrentValue(val != null && !val.isBlank() ? new BigDecimal(val) : BigDecimal.ZERO);
                l.setStatus(req.getParameter("status"));
                dao.update(l);

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
    // The old private isLoggedIn() is removed – we now use SecurityUtil everywhere.
}