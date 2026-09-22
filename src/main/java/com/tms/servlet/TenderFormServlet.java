package com.tms.servlet;

import com.tms.dao.AuditLogDao;
import com.tms.dao.NotificationDao;
import com.tms.dao.TenderDao;
import com.tms.dao.VendorDao;
import com.tms.model.Notification;
import com.tms.model.Tender;
import com.tms.model.Vendor;
import com.tms.util.FileUploadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/tender-form")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 10 * 1024 * 1024,       // 10 MB
    maxRequestSize = 25 * 1024 * 1024     // 25 MB
)
public class TenderFormServlet extends HttpServlet {

    private final TenderDao tenderDao = new TenderDao();
    private final AuditLogDao auditLogDao = new AuditLogDao();
    private final NotificationDao notificationDao = new NotificationDao();
    private final VendorDao vendorDao = new VendorDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only administrators can create or edit tenders.");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                int id = Integer.parseInt(idParam.trim());
                Tender tender = tenderDao.findById(id);
                if (tender != null) {
                    req.setAttribute("tender", tender);
                }
            } catch (NumberFormatException | SQLException e) {
                // Ignore; will show blank form if not found
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/tender-form.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only administrators can create or edit tenders.");
            return;
        }

        int adminUserId = (Integer) session.getAttribute("userId");

        String idParam = req.getParameter("id");
        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String category = req.getParameter("category");
        String budgetStr = req.getParameter("estimatedBudget");
        String deadlineStr = req.getParameter("deadline");
        String status = req.getParameter("status");

        boolean isEdit = (idParam != null && !idParam.trim().isEmpty());

        // Basic required field validations
        if (title == null || title.trim().isEmpty() ||
            description == null || description.trim().isEmpty() ||
            deadlineStr == null || deadlineStr.trim().isEmpty()) {

            sendValidationError(req, resp, "Title, description, and deadline are required.",
                    idParam, title, description, category, budgetStr, deadlineStr, status);
            return;
        }

        // Validate and parse deadline
        Timestamp deadlineTimestamp;
        try {
            String cleanDeadline = deadlineStr.trim();
            if (cleanDeadline.length() == 16) {
                cleanDeadline += ":00";
            }
            LocalDateTime ldt = LocalDateTime.parse(cleanDeadline, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            deadlineTimestamp = Timestamp.valueOf(ldt);
        } catch (DateTimeParseException | IllegalArgumentException e) {
            sendValidationError(req, resp, "Invalid deadline date/time format.",
                    idParam, title, description, category, budgetStr, deadlineStr, status);
            return;
        }

        // For new tenders, deadline must be in the future
        if (!isEdit && !deadlineTimestamp.after(new Timestamp(System.currentTimeMillis()))) {
            sendValidationError(req, resp, "Deadline must be in the future for new tenders.",
                    idParam, title, description, category, budgetStr, deadlineStr, status);
            return;
        }

        // Validate estimated budget if given
        BigDecimal budget = null;
        if (budgetStr != null && !budgetStr.trim().isEmpty()) {
            try {
                budget = new BigDecimal(budgetStr.trim());
                if (budget.compareTo(BigDecimal.ZERO) <= 0) {
                    sendValidationError(req, resp, "Estimated budget must be a positive number.",
                            idParam, title, description, category, budgetStr, deadlineStr, status);
                    return;
                }
            } catch (NumberFormatException e) {
                sendValidationError(req, resp, "Estimated budget must be a valid number.",
                        idParam, title, description, category, budgetStr, deadlineStr, status);
                return;
            }
        }

        // Default status to DRAFT if null/blank
        if (status == null || status.trim().isEmpty()) {
            status = "DRAFT";
        } else {
            status = status.trim().toUpperCase();
        }

        // Handle attachment file upload
        String uploadedFilename = null;
        try {
            Part filePart = req.getPart("attachment");
            if (filePart != null && filePart.getSize() > 0) {
                uploadedFilename = FileUploadUtil.saveUploadedFile(filePart, "tenders");
            }
        } catch (IllegalArgumentException | SecurityException e) {
            sendValidationError(req, resp, e.getMessage(),
                    idParam, title, description, category, budgetStr, deadlineStr, status);
            return;
        }

        try {
            if (!isEdit) {
                // Insert new tender
                Tender t = new Tender();
                t.setTitle(title.trim());
                t.setDescription(description.trim());
                t.setCategory(category != null ? category.trim() : null);
                t.setEstimatedBudget(budget);
                t.setDeadline(deadlineTimestamp);
                t.setStatus(status);
                t.setCreatedBy(adminUserId);
                t.setAttachmentFilename(uploadedFilename);
                t.setAttachmentPath(uploadedFilename != null ? "tenders/" + uploadedFilename : null);

                if ("PUBLISHED".equals(status)) {
                    t.setPublishDate(new Timestamp(System.currentTimeMillis()));
                }

                int newId = tenderDao.insert(t);

                if ("PUBLISHED".equals(status)) {
                    auditLogDao.log(adminUserId, "TENDER_PUBLISHED", "TENDER", newId,
                            "Tender published upon creation: " + t.getTitle());
                    broadcastNewTenderNotification(t.getTitle(), newId);
                }

            } else {
                // Update existing tender
                int tenderId = Integer.parseInt(idParam.trim());
                Tender existing = tenderDao.findById(tenderId);
                if (existing == null) {
                    resp.sendRedirect("tenders");
                    return;
                }

                boolean transitioningToPublished = !"PUBLISHED".equals(existing.getStatus()) && "PUBLISHED".equals(status);

                existing.setTitle(title.trim());
                existing.setDescription(description.trim());
                existing.setCategory(category != null ? category.trim() : null);
                existing.setEstimatedBudget(budget);
                existing.setDeadline(deadlineTimestamp);
                existing.setStatus(status);

                if (uploadedFilename != null) {
                    existing.setAttachmentFilename(uploadedFilename);
                    existing.setAttachmentPath("tenders/" + uploadedFilename);
                }

                if (transitioningToPublished && existing.getPublishDate() == null) {
                    existing.setPublishDate(new Timestamp(System.currentTimeMillis()));
                }

                tenderDao.update(existing);

                if (transitioningToPublished) {
                    auditLogDao.log(adminUserId, "TENDER_PUBLISHED", "TENDER", tenderId,
                            "Tender status transitioned to PUBLISHED: " + existing.getTitle());
                    broadcastNewTenderNotification(existing.getTitle(), tenderId);
                }
            }

            resp.sendRedirect("tenders");

        } catch (SQLException e) {
            throw new ServletException("Database error saving tender", e);
        }
    }

    private void broadcastNewTenderNotification(String tenderTitle, int tenderId) {
        try {
            List<Vendor> approvedVendors = vendorDao.findByApprovalStatus("APPROVED");
            for (Vendor v : approvedVendors) {
                Notification n = new Notification();
                n.setUserId(v.getUserId());
                n.setTitle("New Tender Published");
                n.setMessage("Tender '" + tenderTitle + "' is now open for bidding.");
                n.setLink("tender?id=" + tenderId);
                notificationDao.insert(n);
            }
        } catch (SQLException ignored) {}
    }

    private void sendValidationError(HttpServletRequest req, HttpServletResponse resp, String errorMsg,
                                     String id, String title, String description, String category,
                                     String budget, String deadline, String status)
            throws ServletException, IOException {

        Tender t = new Tender();
        if (id != null && !id.trim().isEmpty()) {
            try {
                t.setId(Integer.parseInt(id.trim()));
            } catch (NumberFormatException ignored) {}
        }
        t.setTitle(title);
        t.setDescription(description);
        t.setCategory(category);
        t.setStatus(status);

        req.setAttribute("tender", t);
        req.setAttribute("inputBudget", budget);
        req.setAttribute("inputDeadline", deadline);
        req.setAttribute("error", errorMsg);

        req.getRequestDispatcher("/WEB-INF/views/tender-form.jsp").forward(req, resp);
    }
}
