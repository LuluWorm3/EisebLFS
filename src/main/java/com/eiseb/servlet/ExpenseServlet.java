package com.eiseb.servlet;

import com.eiseb.dao.ExpenseDAO;
import com.eiseb.dao.LivestockDAO;
import com.eiseb.model.Expense;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class ExpenseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        try {
            ExpenseDAO eDao = new ExpenseDAO(getServletContext());
            String action = req.getParameter("action");
            if ("editForm".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editExpense", eDao.findById(id));
            }
            req.setAttribute("expenses", eDao.findAll());
            req.setAttribute("allLivestock", new LivestockDAO(getServletContext()).findAll());
            req.getRequestDispatcher("/pages/expenses.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        String action = req.getParameter("action");
        ExpenseDAO eDao = new ExpenseDAO(getServletContext());
        try {
            if ("add".equals(action)) {
                Expense e = new Expense();
                e.setCategory(req.getParameter("category"));
                e.setAmount(new BigDecimal(req.getParameter("amount")));
                e.setExpenseDate(Date.valueOf(req.getParameter("expenseDate")));
                e.setDescription(req.getParameter("description"));
                String lid = req.getParameter("livestockId");
                e.setLivestockId((lid != null && !lid.isBlank()) ? Integer.parseInt(lid) : null);
                eDao.insert(e);

            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Expense e = eDao.findById(id);
                e.setCategory(req.getParameter("category"));
                e.setAmount(new BigDecimal(req.getParameter("amount")));
                e.setExpenseDate(Date.valueOf(req.getParameter("expenseDate")));
                e.setDescription(req.getParameter("description"));
                String lid = req.getParameter("livestockId");
                e.setLivestockId((lid != null && !lid.isBlank()) ? Integer.parseInt(lid) : null);
                eDao.update(e);

            } else if ("delete".equals(action)) {
                eDao.delete(Integer.parseInt(req.getParameter("id")));
            }
            resp.sendRedirect(req.getContextPath() + "/expenses");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
