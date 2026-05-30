package com.eiseb.servlet;

import com.eiseb.dao.ExpenseDAO;
import com.eiseb.dao.SaleDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;

public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            SaleDAO    saleDAO = new SaleDAO(getServletContext());
            ExpenseDAO expDAO  = new ExpenseDAO(getServletContext());

            BigDecimal income   = saleDAO.totalPaidIncome();
            BigDecimal expenses = expDAO.totalExpenses();
            BigDecimal net      = income.subtract(expenses);

            req.setAttribute("totalIncome",   income);
            req.setAttribute("totalExpenses", expenses);
            req.setAttribute("netPosition",   net);
            req.setAttribute("paidSaleCount", saleDAO.countPaidSales());
            req.setAttribute("expByCategory", expDAO.sumByCategory());
            req.setAttribute("allSales",      saleDAO.findAll());
            req.setAttribute("allExpenses",   expDAO.findAll());

            req.getRequestDispatcher("/pages/reports.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
