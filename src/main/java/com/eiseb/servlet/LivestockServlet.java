package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.AuditDAO;
import com.eiseb.model.Livestock;
import com.eiseb.model.User;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class LivestockServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            LivestockDAO dao = new LivestockDAO(getServletContext());

            String action = req.getParameter("action");
            if ("editForm".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editLivestock", dao.findById(id));
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
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String action = req.getParameter("action");
        User currentUser = SecurityUtil.getLoggedUser(req);
        try {
            LivestockDAO dao = new LivestockDAO(getServletContext());
            AuditDAO audit = new AuditDAO(getServletContext());

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
                int newId = dao.insert(l);
                req.getSession().setAttribute("toastMsg", "Animal " + l.getTag() + " added successfully.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) {
                    audit.log(currentUser.getId(), currentUser.getUsername(), "INSERT", "livestock", newId, "Tag: " + l.getTag());
                }
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
                req.getSession().setAttribute("toastMsg", "Animal " + l.getTag() + " updated.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) {
                    audit.log(currentUser.getId(), currentUser.getUsername(), "UPDATE", "livestock", id, "Tag: " + l.getTag());
                }
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                dao.delete(id);
                req.getSession().setAttribute("toastMsg", "Animal deleted.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) {
                    audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "livestock", id, "Deleted livestock");
                }
            } else if ("status".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String status = req.getParameter("status");
                dao.updateStatus(id, status);
                req.getSession().setAttribute("toastMsg", "Status changed to " + status + ".");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) {
                    audit.log(currentUser.getId(), currentUser.getUsername(), "STATUS", "livestock", id, "Changed to " + status);
                }
            } else if ("bulkDelete".equals(action)) {
                String[] ids = req.getParameterValues("ids");
                if (ids != null) {
                    for (String idStr : ids) {
                        int id = Integer.parseInt(idStr);
                        dao.delete(id);
                        if (currentUser != null) {
                            audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "livestock", id, "Bulk deleted");
                        }
                    }
                    req.getSession().setAttribute("toastMsg", ids.length + " animal(s) deleted.");
                    req.getSession().setAttribute("toastType", "success");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/livestock");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
