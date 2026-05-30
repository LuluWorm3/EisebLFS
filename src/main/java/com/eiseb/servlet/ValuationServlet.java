package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.ValuationDAO;
import com.eiseb.model.Valuation;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class ValuationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            req.setAttribute("valuations", new ValuationDAO(getServletContext()).findAll());
            req.setAttribute("activeLivestock", new LivestockDAO(getServletContext()).findActive());
            req.getRequestDispatcher("/pages/valuations.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            Valuation v = new Valuation();
            v.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
            v.setValDate(Date.valueOf(req.getParameter("valDate")));
            v.setValue(new BigDecimal(req.getParameter("value")));
            v.setMethod(req.getParameter("method"));
            v.setNotes(req.getParameter("notes"));
            new ValuationDAO(getServletContext()).insert(v);
            // Update animal's current value
            new LivestockDAO(getServletContext()).updateValue(v.getLivestockId(), v.getValue());
            resp.sendRedirect(req.getContextPath() + "/valuations");
        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
