package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.SaleDAO;
import com.eiseb.model.Sale;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class SalesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            req.setAttribute("sales", new SaleDAO(getServletContext()).findAll());
            req.setAttribute("activeLivestock", new LivestockDAO(getServletContext()).findActive());
            req.getRequestDispatcher("/pages/sales.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            Sale s = new Sale();
            s.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
            s.setBuyer(req.getParameter("buyer").trim());
            s.setSaleType(req.getParameter("saleType"));
            s.setSaleDate(Date.valueOf(req.getParameter("saleDate")));
            s.setPrice(new BigDecimal(req.getParameter("price")));
            s.setPaymentStatus(req.getParameter("paymentStatus"));
            s.setNotes(req.getParameter("notes"));
            new SaleDAO(getServletContext()).insert(s);
            // If paid, mark animal as Sold
            if ("Paid".equals(s.getPaymentStatus())) {
                new LivestockDAO(getServletContext()).updateStatus(s.getLivestockId(), "Sold");
            }
            resp.sendRedirect(req.getContextPath() + "/sales");
        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
