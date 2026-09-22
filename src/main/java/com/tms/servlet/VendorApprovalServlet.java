package com.tms.servlet;

import com.tms.dao.AuditLogDao;
import com.tms.dao.VendorDao;
import com.tms.model.Vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/vendor-approvals")
public class VendorApprovalServlet extends HttpServlet {

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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrator role required.");
            return;
        }

        try {
            VendorDao vendorDao = new VendorDao();
            List<Vendor> pendingVendors = vendorDao.findByApprovalStatus("PENDING");
            req.setAttribute("pendingVendors", pendingVendors);
            req.getRequestDispatcher("/WEB-INF/views/vendor-approvals.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error retrieving pending vendors", e);
        }
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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Administrator role required.");
            return;
        }

        int adminUserId = (Integer) session.getAttribute("userId");
        String vendorIdStr = req.getParameter("vendorId");
        String action = req.getParameter("action"); // "APPROVE" or "REJECT"

        if (vendorIdStr == null || action == null) {
            resp.sendRedirect("vendor-approvals");
            return;
        }

        int vendorId;
        try {
            vendorId = Integer.parseInt(vendorIdStr);
        } catch (NumberFormatException e) {
            resp.sendRedirect("vendor-approvals");
            return;
        }

        String newStatus;
        String auditAction;
        String details;

        if ("APPROVE".equalsIgnoreCase(action)) {
            newStatus = "APPROVED";
            auditAction = "VENDOR_APPROVED";
            details = "Vendor application approved by admin (User ID: " + adminUserId + ")";
        } else if ("REJECT".equalsIgnoreCase(action)) {
            newStatus = "REJECTED";
            auditAction = "VENDOR_REJECTED";
            details = "Vendor application rejected by admin (User ID: " + adminUserId + ")";
        } else {
            resp.sendRedirect("vendor-approvals");
            return;
        }

        try {
            VendorDao vendorDao = new VendorDao();
            Vendor vendor = vendorDao.findById(vendorId);
            boolean updated = vendorDao.updateApprovalStatus(vendorId, newStatus);

            if (updated) {
                AuditLogDao auditLogDao = new AuditLogDao();
                auditLogDao.log(adminUserId, auditAction, "VENDOR", vendorId, details);

                if (vendor != null) {
                    com.tms.dao.NotificationDao notificationDao = new com.tms.dao.NotificationDao();
                    com.tms.model.Notification notif = new com.tms.model.Notification();
                    notif.setUserId(vendor.getUserId());
                    if ("APPROVED".equals(newStatus)) {
                        notif.setTitle("Vendor Account Approved");
                        notif.setMessage("Congratulations! Your vendor account has been approved. You may now submit commercial bids on active tenders.");
                        notif.setLink("tenders");
                    } else {
                        notif.setTitle("Vendor Application Status");
                        notif.setMessage("Your vendor registration application was reviewed and could not be approved at this time.");
                        notif.setLink("tenders");
                    }
                    notificationDao.insert(notif);
                }
            }

            resp.sendRedirect("vendor-approvals?success=1");

        } catch (SQLException e) {
            throw new ServletException("Database error updating vendor approval status", e);
        }
    }
}
