package com.eiseb.servlet;

import com.eiseb.dao.ExpenseDAO;
import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.AuditDAO;
import com.eiseb.model.Expense;
import com.eiseb.model.User;
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
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
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
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String action = req.getParameter("action");
        User currentUser = SecurityUtil.getLoggedUser(req);
        try {
            ExpenseDAO eDao = new ExpenseDAO(getServletContext());
            AuditDAO audit = new AuditDAO(getServletContext());

            if ("add".equals(action)) {
                Expense e = new Expense();
                e.setCategory(req.getParameter("category"));
                e.setAmount(new BigDecimal(req.getParameter("amount")));
                e.setExpenseDate(Date.valueOf(req.getParameter("expenseDate")));
                e.setDescription(req.getParameter("description"));
                String lid = req.getParameter("livestockId");
                e.setLivestockId((lid != null && !lid.isBlank()) ? Integer.parseInt(lid) : null);
                int newId = eDao.insert(e);
                req.getSession().setAttribute("toastMsg", "Expense recorded.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "INSERT", "expense", newId, "Amount: " + e.getAmount());
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
                req.getSession().setAttribute("toastMsg", "Expense updated.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "UPDATE", "expense", id, "Amount: " + e.getAmount());
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                eDao.delete(id);
                req.getSession().setAttribute("toastMsg", "Expense deleted.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "expense", id, "Deleted");
            } else if ("bulkDelete".equals(action)) {
                String[] ids = req.getParameterValues("ids");
                if (ids != null) {
                    for (String idStr : ids) {
                        int id = Integer.parseInt(idStr);
                        eDao.delete(id);
                        if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "expense", id, "Bulk deleted");
                    }
                    req.getSession().setAttribute("toastMsg", ids.length + " expense(s) deleted.");
                    req.getSession().setAttribute("toastType", "success");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/expenses");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
