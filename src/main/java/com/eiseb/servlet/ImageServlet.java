package com.eiseb.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

public class ImageServlet extends HttpServlet {
    // Portable upload root: user's home directory + /eiseb_uploads
    private static final String UPLOAD_ROOT = System.getProperty("user.home") + File.separator + "eiseb_uploads";

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String file = req.getParameter("file");   // e.g. "livestock/cow.png"
        if (file == null || file.contains("..") || file.contains("/../")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File imgFile = new File(UPLOAD_ROOT, file);
        if (!imgFile.exists() || !imgFile.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(imgFile.getName());
        if (contentType == null) contentType = "application/octet-stream";
        resp.setContentType(contentType);
        resp.setContentLengthLong(imgFile.length());

        try (FileInputStream in = new FileInputStream(imgFile);
             OutputStream out = resp.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
