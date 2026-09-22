package com.tms.servlet;

import com.tms.dao.BidDao;
import com.tms.dao.TenderDao;
import com.tms.dao.VendorDao;
import com.tms.model.Bid;
import com.tms.model.Tender;
import com.tms.model.Vendor;
import com.tms.util.FileUploadUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.sql.SQLException;

@WebServlet("/download")
public class FileDownloadServlet extends HttpServlet {

    private final TenderDao tenderDao = new TenderDao();
    private final BidDao bidDao = new BidDao();
    private final VendorDao vendorDao = new VendorDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String type = req.getParameter("type");
        String idStr = req.getParameter("id");
        if (type == null || idStr == null || (!"tender".equals(type) && !"bid".equals(type))) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid download parameters.");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idStr);
            if (id <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid resource identifier.");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        int currentUserId = (Integer) session.getAttribute("userId");

        try {
            File targetFile = null;
            String downloadName = null;

            if ("tender".equals(type)) {
                Tender t = tenderDao.findById(id);
                if (t == null || t.getAttachmentFilename() == null || t.getAttachmentFilename().trim().isEmpty()) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Tender specification attachment not found.");
                    return;
                }
                if ("DRAFT".equalsIgnoreCase(t.getStatus()) && !"ADMIN".equalsIgnoreCase(role)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Draft tender specifications are restricted.");
                    return;
                }
                targetFile = FileUploadUtil.getFile("tenders", t.getAttachmentFilename());
                downloadName = t.getAttachmentFilename();
            } else {
                // type == "bid"
                Bid b = bidDao.findById(id);
                if (b == null || b.getAttachmentFilename() == null || b.getAttachmentFilename().trim().isEmpty()) {
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Bid proposal attachment not found.");
                    return;
                }

                // Authorization check: Admin OR Vendor who owns this bid
                boolean isAuthorized = "ADMIN".equalsIgnoreCase(role);
                if (!isAuthorized && "VENDOR".equalsIgnoreCase(role)) {
                    Vendor v = vendorDao.findByUserId(currentUserId);
                    if (v != null && v.getId() == b.getVendorId()) {
                        isAuthorized = true;
                    }
                }

                if (!isAuthorized) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not have permission to download this proposal attachment.");
                    return;
                }

                targetFile = FileUploadUtil.getFile("bids", b.getAttachmentFilename());
                downloadName = b.getAttachmentFilename();
            }

            if (targetFile == null || !targetFile.exists()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found on storage.");
                return;
            }

            // Strip the 9-char UUID prefix for user friendly download name
            String userFriendlyName = downloadName;
            if (userFriendlyName.length() > 9 && userFriendlyName.charAt(8) == '_') {
                userFriendlyName = userFriendlyName.substring(9);
            }

            String mimeType = Files.probeContentType(targetFile.toPath());
            if (mimeType == null) {
                mimeType = "application/octet-stream";
            }

            resp.setContentType(mimeType);
            resp.setContentLengthLong(targetFile.length());
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + userFriendlyName.replace("\"", "") + "\"");

            try (FileInputStream in = new FileInputStream(targetFile);
                 OutputStream out = resp.getOutputStream()) {
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Database error verifying file authorization", e);
        }
    }
}
