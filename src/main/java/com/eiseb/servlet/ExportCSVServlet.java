package com.eiseb.servlet;

import com.eiseb.dao.*;
import com.eiseb.model.*;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class ExportCSVServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String type = req.getParameter("type");
        resp.setContentType("text/csv");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + type + "_export.csv\"");

        PrintWriter out = resp.getWriter();
        try {
            switch (type) {
                case "sales":
                    SaleDAO sDao = new SaleDAO(getServletContext());
                    List<Sale> sales = sDao.findAll();
                    out.println("\"Date\",\"Tag\",\"Buyer\",\"Type\",\"Price\",\"Status\"");
                    for (Sale s : sales) {
                        out.printf("\"%s\",\"%s\",\"%s\",\"%s\",%.2f,\"%s\"\n",
                            s.getSaleDate(), quote(s.getLivestockTag()), quote(s.getBuyer()),
                            quote(s.getSaleType()), s.getPrice(), quote(s.getPaymentStatus()));
                    }
                    break;
                case "expenses":
                    ExpenseDAO eDao = new ExpenseDAO(getServletContext());
                    List<Expense> expenses = eDao.findAll();
                    out.println("\"Date\",\"Category\",\"Description\",\"Animal\",\"Amount\"");
                    for (Expense e : expenses) {
                        out.printf("\"%s\",\"%s\",\"%s\",\"%s\",%.2f\n",
                            e.getExpenseDate(), quote(e.getCategory()), quote(e.getDescription()),
                            quote(e.getLivestockTag() != null ? e.getLivestockTag() : ""), e.getAmount());
                    }
                    break;
                case "livestock":
                    LivestockDAO lDao = new LivestockDAO(getServletContext());
                    List<Livestock> livestock = lDao.findAll();
                    out.println("\"Tag\",\"Species\",\"Breed\",\"Gender\",\"DOB\",\"Value\",\"Status\"");
                    for (Livestock l : livestock) {
                        out.printf("\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%.2f,\"%s\"\n",
                            quote(l.getTag()), quote(l.getSpecies()), quote(l.getBreed()),
                            quote(l.getGender()), l.getDob() != null ? l.getDob() : "",
                            l.getCurrentValue(), quote(l.getStatus()));
                    }
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        out.flush();
    }

    private String quote(String value) {
        if (value == null) return "";
        return value.replace("\"", "\"\"");
    }
}
