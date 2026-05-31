package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.SaleDAO;
import com.eiseb.model.Livestock;
import com.eiseb.model.Sale;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

public class InvoiceServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing sale id");
            return;
        }
        int saleId = Integer.parseInt(idParam);
        try {
            SaleDAO sDao = new SaleDAO(getServletContext());
            Sale sale = sDao.findById(saleId);
            if (sale == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            Livestock animal = new LivestockDAO(getServletContext()).findById(sale.getLivestockId());

            resp.setContentType("text/html;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.println("<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Invoice #" + saleId + "</title>");
            out.println("<style>body{font-family:Arial,sans-serif;max-width:700px;margin:40px auto;padding:20px;border:1px solid #ccc;} h1{color:#2C1A0E;} table{width:100%;border-collapse:collapse;margin:20px 0;} th,td{padding:8px;text-align:left;border-bottom:1px solid #ddd;} .print-btn{background:#C9952A;color:white;padding:10px 20px;border:none;cursor:pointer;font-weight:bold;} @media print{.print-btn{display:none;}}</style></head><body>");
            out.println("<button class='print-btn' onclick='window.print()'>Print Invoice</button>");
            out.println("<h1>Eiseb Country Traders</h1><p>Omaheke Region, Namibia</p><hr>");
            out.println("<h2>Sale Invoice #" + sale.getId() + "</h2>");
            out.println("<table>");
            out.println("<tr><th>Date</th><td>" + sale.getSaleDate() + "</td></tr>");
            out.println("<tr><th>Animal Tag</th><td>" + (animal != null ? animal.getTag() : "N/A") + "</td></tr>");
            out.println("<tr><th>Species</th><td>" + (animal != null ? animal.getSpecies() : "N/A") + "</td></tr>");
            out.println("<tr><th>Buyer</th><td>" + sale.getBuyer() + "</td></tr>");
            out.println("<tr><th>Sale Type</th><td>" + sale.getSaleType() + "</td></tr>");
            out.println("<tr><th>Price</th><td>N$ " + String.format("%,.2f", sale.getPrice()) + "</td></tr>");
            out.println("<tr><th>Payment Status</th><td>" + sale.getPaymentStatus() + "</td></tr>");
            out.println("<tr><th>Notes</th><td>" + (sale.getNotes() != null ? sale.getNotes() : "—") + "</td></tr>");
            out.println("</table>");
            out.println("<p>Thank you for your business.</p>");
            out.println("</body></html>");
        } catch (Exception e) { throw new ServletException(e); }
    }
}
