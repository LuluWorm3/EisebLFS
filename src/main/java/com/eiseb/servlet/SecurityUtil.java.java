package com.eiseb.servlet;

import com.eiseb.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;

public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        try {
            SaleDAO    saleDAO    = new SaleDAO(getServletContext());
            ExpenseDAO expDAO     = new ExpenseDAO(getServletContext());
            LivestockDAO lsDAO   = new LivestockDAO(getServletContext());

            BigDecimal income    = saleDAO.totalPaidIncome();
            BigDecimal expenses  = expDAO.totalExpenses();
            BigDecimal net       = income.subtract(expenses);
            int activeLivestock  = lsDAO.countByStatus("Active");

            req.setAttribute("totalIncome",    income);
            req.setAttribute("totalExpenses",  expenses);
            req.setAttribute("netPosition",    net);
            req.setAttribute("activeLivestock",activeLivestock);
            req.setAttribute("recentSales",    saleDAO.findAll().stream().limit(5).toList());
            req.setAttribute("recentExpenses", expDAO.findAll().stream().limit(5).toList());
            req.setAttribute("expByCategory",  expDAO.sumByCategory());

            req.getRequestDispatcher("/pages/dashboard.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
