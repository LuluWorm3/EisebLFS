package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.SaleDAO;
import com.eiseb.dao.AuditDAO;
import com.eiseb.model.Sale;
import com.eiseb.model.User;
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
        User currentUser = SecurityUtil.getLoggedUser(req);
        try {
            SaleDAO sDao = new SaleDAO(getServletContext());
            AuditDAO audit = new AuditDAO(getServletContext());

            if ("add".equals(action)) {
                Sale s = new Sale();
                s.setLivestockId(Integer.parseInt(req.getParameter("livestockId")));
                s.setBuyer(req.getParameter("buyer").trim());
                s.setSaleType(req.getParameter("saleType"));
                s.setSaleDate(Date.valueOf(req.getParameter("saleDate")));
                s.setPrice(new BigDecimal(req.getParameter("price")));
                s.setPaymentStatus(req.getParameter("paymentStatus"));
                s.setNotes(req.getParameter("notes"));
                int newId = sDao.insert(s);
                if ("Paid".equals(s.getPaymentStatus())) {
                    new LivestockDAO(getServletContext()).updateStatus(s.getLivestockId(), "Sold");
                }
                req.getSession().setAttribute("toastMsg", "Sale recorded.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "INSERT", "sale", newId, "Buyer: " + s.getBuyer());
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
                req.getSession().setAttribute("toastMsg", "Sale updated.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "UPDATE", "sale", id, "Buyer: " + s.getBuyer());
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                sDao.delete(id);
                req.getSession().setAttribute("toastMsg", "Sale deleted.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "sale", id, "Deleted");
            } else if ("bulkDelete".equals(action)) {
                String[] ids = req.getParameterValues("ids");
                if (ids != null) {
                    for (String idStr : ids) {
                        int id = Integer.parseInt(idStr);
                        sDao.delete(id);
                        if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "sale", id, "Bulk deleted");
                    }
                    req.getSession().setAttribute("toastMsg", ids.length + " sale(s) deleted.");
                    req.getSession().setAttribute("toastType", "success");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/sales");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
