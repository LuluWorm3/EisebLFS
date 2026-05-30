package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.SaleDAO;
import com.eiseb.model.Sale;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;

public class SalesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        try {
            SaleDAO sDao = new SaleDAO(getServletContext());
            String action = req.getParameter("action");
            if ("editForm".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editSale", sDao.findById(id));
            }
            req.setAttribute("sales", sDao.findAll());
            req.setAttribute("activeLivestock", new LivestockDAO(getServletContext()).findActive());
            req.getRequestDispatcher("/pages/sales.jsp").forward(req, resp);
        } catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        String action = req.getParameter("action");
        SaleDAO sDao = new SaleDAO(getServletContext());
        try {
            if ("add".equals(action)) {
                Sale s = new Sale();
                s.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
                s.setBuyer(req.getParameter("buyer").trim());
                s.setSaleType(req.getParameter("saleType"));
                s.setSaleDate(Date.valueOf(req.getParameter("saleDate")));
                s.setPrice(new BigDecimal(req.getParameter("price")));
                s.setPaymentStatus(req.getParameter("paymentStatus"));
                s.setNotes(req.getParameter("notes"));
                sDao.insert(s);
                if ("Paid".equals(s.getPaymentStatus())) {
                    new LivestockDAO(getServletContext()).updateStatus(s.getLivestockId(), "Sold");
                }
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Sale s = sDao.findById(id);
                s.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
                s.setBuyer(req.getParameter("buyer").trim());
                s.setSaleType(req.getParameter("saleType"));
                s.setSaleDate(Date.valueOf(req.getParameter("saleDate")));
                s.setPrice(new BigDecimal(req.getParameter("price")));
                s.setPaymentStatus(req.getParameter("paymentStatus"));
                s.setNotes(req.getParameter("notes"));
                sDao.update(s);
                if ("Paid".equals(s.getPaymentStatus())) {
                    new LivestockDAO(getServletContext()).updateStatus(s.getLivestockId(), "Sold");
                }
            } else if ("delete".equals(action)) {
                sDao.delete(Integer.parseInt(req.getParameter("id")));
            }
            resp.sendRedirect(req.getContextPath() + "/sales");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
