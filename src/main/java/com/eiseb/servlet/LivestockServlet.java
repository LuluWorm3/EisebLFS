package com.eiseb.servlet;

import com.eiseb.dao.LivestockDAO;
import com.eiseb.dao.AuditDAO;
import com.eiseb.model.Livestock;
import com.eiseb.model.User;
import com.eiseb.util.SecurityUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Date;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
public class LivestockServlet extends HttpServlet {

    private static final String UPLOAD_DIR =
        System.getProperty("user.home") + File.separator + "eiseb_uploads" + File.separator + "livestock";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SecurityUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            LivestockDAO dao = new LivestockDAO(getServletContext());
            String action = req.getParameter("action");
            if ("editForm".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("editLivestock", dao.findById(id));
            }
            String filter = req.getParameter("filter");
            if (filter != null && !filter.equals("All")) {
                req.setAttribute("livestock", dao.findByStatus(filter));
            } else {
                req.setAttribute("livestock", dao.findAll());
            }
            req.setAttribute("filter", filter != null ? filter : "All");
            req.getRequestDispatcher("/pages/livestock.jsp").forward(req, resp);
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
            LivestockDAO dao = new LivestockDAO(getServletContext());
            AuditDAO audit = new AuditDAO(getServletContext());

            if ("add".equals(action)) {
                Livestock l = new Livestock();
                l.setTag(req.getParameter("tag").trim().toUpperCase());
                l.setSpecies(req.getParameter("species"));
                l.setBreed(req.getParameter("breed"));
                l.setCategory(req.getParameter("category"));
                l.setGender(req.getParameter("gender"));
                String dob = req.getParameter("dob");
                if (dob != null && !dob.isBlank()) l.setDob(Date.valueOf(dob));
                String val = req.getParameter("currentValue");
                l.setCurrentValue(val != null && !val.isBlank() ? new BigDecimal(val) : BigDecimal.ZERO);
                l.setStatus("Active");

                // --- IMAGE UPLOAD (manual stream copy) ---
                try {
                    Part filePart = req.getPart("image");
                    if (filePart != null && filePart.getSize() > 0) {
                        String fileName = extractFileName(filePart);
                        if (fileName != null && !fileName.isEmpty()) {
                            File dir = new File(UPLOAD_DIR);
                            if (!dir.exists()) dir.mkdirs();
                            File outFile = new File(UPLOAD_DIR, fileName);
                            try (InputStream in = filePart.getInputStream();
                                 FileOutputStream out = new FileOutputStream(outFile)) {
                                byte[] buffer = new byte[8192];
                                int bytesRead;
                                while ((bytesRead = in.read(buffer)) != -1) {
                                    out.write(buffer, 0, bytesRead);
                                }
                            }
                            System.out.println("Image saved to: " + outFile.getAbsolutePath());
                            l.setImagePath(fileName);
                        }
                    }
                } catch (Exception ex) {
                    System.out.println("UPLOAD FAILED:");
                    ex.printStackTrace();
                }

                int newId = dao.insert(l);
                req.getSession().setAttribute("toastMsg", "Animal " + l.getTag() + " added successfully.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "INSERT", "livestock", newId, "Tag: " + l.getTag());
            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Livestock l = dao.findById(id);
                l.setTag(req.getParameter("tag").trim().toUpperCase());
                l.setSpecies(req.getParameter("species"));
                l.setBreed(req.getParameter("breed"));
                l.setCategory(req.getParameter("category"));
                l.setGender(req.getParameter("gender"));
                String dob = req.getParameter("dob");
                if (dob != null && !dob.isBlank()) l.setDob(Date.valueOf(dob));
                String val = req.getParameter("currentValue");
                l.setCurrentValue(val != null && !val.isBlank() ? new BigDecimal(val) : BigDecimal.ZERO);
                l.setStatus(req.getParameter("status"));

                try {
                    Part filePart = req.getPart("image");
                    if (filePart != null && filePart.getSize() > 0) {
                        String fileName = extractFileName(filePart);
                        if (fileName != null && !fileName.isEmpty()) {
                            File dir = new File(UPLOAD_DIR);
                            if (!dir.exists()) dir.mkdirs();
                            File outFile = new File(UPLOAD_DIR, fileName);
                            try (InputStream in = filePart.getInputStream();
                                 FileOutputStream out = new FileOutputStream(outFile)) {
                                byte[] buffer = new byte[8192];
                                int bytesRead;
                                while ((bytesRead = in.read(buffer)) != -1) {
                                    out.write(buffer, 0, bytesRead);
                                }
                            }
                            l.setImagePath(fileName);
                        }
                    }
                } catch (Exception ex) { ex.printStackTrace(); }

                dao.update(l);
                req.getSession().setAttribute("toastMsg", "Animal " + l.getTag() + " updated.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "UPDATE", "livestock", id, "Tag: " + l.getTag());
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                dao.delete(id);
                req.getSession().setAttribute("toastMsg", "Animal deleted.");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "livestock", id, "Deleted livestock");
            } else if ("status".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String status = req.getParameter("status");
                dao.updateStatus(id, status);
                req.getSession().setAttribute("toastMsg", "Status changed to " + status + ".");
                req.getSession().setAttribute("toastType", "success");
                if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "STATUS", "livestock", id, "Changed to " + status);
            } else if ("bulkDelete".equals(action)) {
                String[] ids = req.getParameterValues("ids");
                if (ids != null) {
                    for (String idStr : ids) {
                        int id = Integer.parseInt(idStr);
                        dao.delete(id);
                        if (currentUser != null) audit.log(currentUser.getId(), currentUser.getUsername(), "DELETE", "livestock", id, "Bulk deleted");
                    }
                    req.getSession().setAttribute("toastMsg", ids.length + " animal(s) deleted.");
                    req.getSession().setAttribute("toastType", "success");
                }
            }
            resp.sendRedirect(req.getContextPath() + "/livestock");
        } catch (Exception e) { throw new ServletException(e); }
    }

    private String extractFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) return null;
        for (String cd : contentDisposition.split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf("=") + 1).trim().replace("\"", "");
                if (fileName.isEmpty()) continue;
                return fileName.substring(fileName.lastIndexOf(File.separatorChar) + 1);
            }
        }
        return null;
    }
}
