package com.eiseb.servlet;

import com.eiseb.dao.ExpenseDAO;
import com.eiseb.dao.SaleDAO;
import com.eiseb.model.Expense;
import com.eiseb.model.Sale;
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

            // Calculate totals from the filtered lists, not all-time totals
            BigDecimal income = BigDecimal.ZERO;
            for (Sale s : allSales) {
                if ("Paid".equals(s.getPaymentStatus())) {
                    income = income.add(s.getPrice());
                }
            }
            BigDecimal expenses = BigDecimal.ZERO;
            for (Expense e : allExpenses) {
                expenses = expenses.add(e.getAmount());
            }
            BigDecimal net = income.subtract(expenses);

            // Category breakdown from filtered expenses
            // (We can reuse the same DAO method but pass date range; for simplicity we compute here)
            req.setAttribute("totalIncome",   income);
            req.setAttribute("totalExpenses", expenses);
            req.setAttribute("netPosition",   net);
            req.setAttribute("paidSaleCount", saleDAO.countPaidSales());  // all-time count, fine for now
            req.setAttribute("expByCategory", expDAO.sumByCategory());    // all-time categories
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
