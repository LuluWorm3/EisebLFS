package com.eiseb.servlet;

import com.eiseb.dao.ExpenseDAO;
import com.eiseb.dao.SaleDAO;
import com.eiseb.model.Sale;
import com.eiseb.model.Expense;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.List;

public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            String startDate = req.getParameter("startDate");
            String endDate   = req.getParameter("endDate");

            SaleDAO    saleDAO = new SaleDAO(getServletContext());
            ExpenseDAO expDAO  = new ExpenseDAO(getServletContext());

            List<Sale>    allSales    = (startDate != null && !startDate.isEmpty())
                ? saleDAO.findByDateRange(Date.valueOf(startDate), Date.valueOf(endDate))
                : saleDAO.findAll();

            List<Expense> allExpenses = (startDate != null && !startDate.isEmpty())
                ? expDAO.findByDateRange(Date.valueOf(startDate), Date.valueOf(endDate))
                : expDAO.findAll();

            BigDecimal income   = saleDAO.totalPaidIncome();
            BigDecimal expenses = expDAO.totalExpenses();
            BigDecimal net      = income.subtract(expenses);

            req.setAttribute("totalIncome",   income);
            req.setAttribute("totalExpenses", expenses);
            req.setAttribute("netPosition",   net);
            req.setAttribute("paidSaleCount", saleDAO.countPaidSales());
            req.setAttribute("expByCategory", expDAO.sumByCategory());
            req.setAttribute("allSales",      allSales);
            req.setAttribute("allExpenses",   allExpenses);
            req.setAttribute("startDate",     startDate);
            req.setAttribute("endDate",       endDate);

            req.getRequestDispatcher("/pages/reports.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
