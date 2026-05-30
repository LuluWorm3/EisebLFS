package com.eiseb.servlet;

import com.eiseb.dao.ExpenseDAO;
import com.eiseb.dao.LivestockDAO;
import com.eiseb.model.Expense;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class ExpenseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            req.setAttribute("expenses", new ExpenseDAO(getServletContext()).findAll());
            req.setAttribute("allLivestock", new LivestockDAO(getServletContext()).findAll());
            req.getRequestDispatcher("/pages/expenses.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
        try {
            Expense e = new Expense();
            e.setCategory(req.getParameter("category"));
            e.setAmount(new BigDecimal(req.getParameter("amount")));
            e.setExpenseDate(Date.valueOf(req.getParameter("expenseDate")));
            e.setDescription(req.getParameter("description"));
            String lid = req.getParameter("livestockId");
            e.setLivestockId((lid != null && !lid.isBlank()) ? Integer.parseInt(lid) : null);
            new ExpenseDAO(getServletContext()).insert(e);
            resp.sendRedirect(req.getContextPath() + "/expenses");
        } catch (Exception e) { throw new ServletException(e); }
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("currentUser") != null;
    }
}
