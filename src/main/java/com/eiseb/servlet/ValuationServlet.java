package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.ValuationDAO;
import com.eiseb.dao.AuditDAO;
import com.eiseb.model.Valuation;
import com.eiseb.model.User;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class ValuationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            ValuationDAO vDao = new ValuationDAO(getServletContext());
            String action = req.getParameter("action");
            if ("editForm".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editValuation", vDao.findById(id));
            }
            req.setAttribute("valuations", vDao.findAll());
            req.setAttribute("activeLivestock", new LivestockDAO(getServletContext()).findActive());
            req.getRequestDispatcher("/pages/valuations.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
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
            ValuationDAO vDao = new ValuationDAO(getServletContext());
            AuditDAO audit = new AuditDAO(getServletContext());

            if ("add".equals(action)) {
                Valuation v = new Valuation();
                v.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
                v.setValDate(Date.valueOf(req.getParameter("valDate")));
                v.setValue(new BigDecimal(req.getParameter("value")));
                v.setMethod(req.getParameter("method"));
                v.setNotes(req.getParameter("notes"));
                int newId = vDao.insert(v);
                new LivestockDAO(getServletContext()).updateValue(v.getLivestockId(), v.getValue());
                req.getSession().setAttribute("toastMsg", "Valuation recorded.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "INSERT", "valuation", newId, "Value: " + v.getValue());
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Valuation v = vDao.findById(id);
                v.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
                v.setValDate(Date.valueOf(req.getParameter("valDate")));
                v.setValue(new BigDecimal(req.getParameter("value")));
                v.setMethod(req.getParameter("method"));
                v.setNotes(req.getParameter("notes"));
                vDao.update(v);
                new LivestockDAO(getServletContext()).updateValue(v.getLivestockId(), v.getValue());
                req.getSession().setAttribute("toastMsg", "Valuation updated.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "UPDATE", "valuation", id, "Value: " + v.getValue());
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                vDao.delete(id);
                req.getSession().setAttribute("toastMsg", "Valuation deleted.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "valuation", id, "Deleted");
            } else if ("bulkDelete".equals(action)) {
                String[] ids = req.getParameterValues("ids");
                if (ids != null) {
                    for (String idStr : ids) {
                        int id = Integer.parseInt(idStr);
                        vDao.delete(id);
                        if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "valuation", id, "Bulk deleted");
                    }
                    req.getSession().setAttribute("toastMsg", ids.length + " valuation(s) deleted.");
                    req.getSession().setAttribute("toastType", "success");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/valuations");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
