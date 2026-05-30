package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.ValuationDAO;
import com.eiseb.model.Valuation;
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
                if (!SecurityUtil.isManagerOrAdmin(req)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
                    return;
                }
                int id = Integer.parseInt(req.getParameter("id"));
                Valuation editValuation = vDao.findById(id);
                req.setAttribute("editValuation", editValuation);
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
        if (!SecurityUtil.isManagerOrAdmin(req)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        String action = req.getParameter("action");
        ValuationDAO vDao = new ValuationDAO(getServletContext());
        try {
            if ("add".equals(action)) {
                Valuation v = new Valuation();
                v.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
                v.setValDate(Date.valueOf(req.getParameter("valDate")));
                v.setValue(new BigDecimal(req.getParameter("value")));
                v.setMethod(req.getParameter("method"));
                v.setNotes(req.getParameter("notes"));
                vDao.insert(v);
                new LivestockDAO(getServletContext()).updateValue(v.getLivestockId(), v.getValue());
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
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                vDao.delete(id);
            }
            resp.sendRedirect(req.getContextPath() + "/valuations");
        } catch (Exception e) { throw new ServletException(e); }
    }
}