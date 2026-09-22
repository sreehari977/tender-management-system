package com.tms.servlet;

import com.tms.dao.AuditLogDao;
import com.tms.dao.BidDao;
import com.tms.dao.NotificationDao;
import com.tms.dao.TenderDao;
import com.tms.dao.VendorDao;
import com.tms.model.Bid;
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

@WebServlet("/bid")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 10 * 1024 * 1024,       // 10 MB
    maxRequestSize = 25 * 1024 * 1024     // 25 MB
)
public class BidServlet extends HttpServlet {

    private final VendorDao vendorDao = new VendorDao();
    private final TenderDao tenderDao = new TenderDao();
    private final BidDao bidDao = new BidDao();
    private final AuditLogDao auditLogDao = new AuditLogDao();
    private final NotificationDao notificationDao = new NotificationDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("userRole");
        if (!"VENDOR".equals(userRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only registered vendors can access the bid submission form.");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String tenderIdParam = req.getParameter("tenderId");

        if (tenderIdParam == null || tenderIdParam.trim().isEmpty()) {
            resp.sendRedirect("tenders");
            return;
        }

        int tenderId;
        try {
            tenderId = Integer.parseInt(tenderIdParam.trim());
            if (tenderId <= 0) {
                resp.sendRedirect("tenders");
                return;
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect("tenders");
            return;
        }

        try {
            Vendor vendor = vendorDao.findByUserId(userId);
            if (vendor == null || !"APPROVED".equals(vendor.getApprovalStatus())) {
                resp.sendRedirect("tender?id=" + tenderId);
                return;
            }

            Tender tender = tenderDao.findById(tenderId);

            if (tender == null || !"PUBLISHED".equals(tender.getStatus())) {
                resp.sendRedirect("tenders");
                return;
            }

            if (tender.isDeadlinePassed()) {
                resp.sendRedirect("tender?id=" + tenderId);
                return;
            }

            if (bidDao.hasVendorBid(tenderId, vendor.getId())) {
                resp.sendRedirect("tender?id=" + tenderId);
                return;
            }

            req.setAttribute("tender", tender);
            req.setAttribute("vendor", vendor);
            req.getRequestDispatcher("/WEB-INF/views/bid-form.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading bid form", e);
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

        String userRole = (String) session.getAttribute("userRole");
        if (!"VENDOR".equals(userRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only registered vendors may submit bids.");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String tenderIdParam = req.getParameter("tenderId");
        String amountStr = req.getParameter("amount");
        String proposalText = req.getParameter("proposalText");

        if (tenderIdParam == null || tenderIdParam.trim().isEmpty()) {
            resp.sendRedirect("tenders");
            return;
        }

        int tenderId;
        try {
            tenderId = Integer.parseInt(tenderIdParam.trim());
            if (tenderId <= 0) {
                resp.sendRedirect("tenders");
                return;
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect("tenders");
            return;
        }

        try {
            Vendor vendor = vendorDao.findByUserId(userId);
            if (vendor == null || !"APPROVED".equals(vendor.getApprovalStatus())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Your vendor account is not approved to submit bids.");
                return;
            }

            Tender tender = tenderDao.findById(tenderId);

            if (tender == null || !"PUBLISHED".equals(tender.getStatus())) {
                resp.sendRedirect("tenders");
                return;
            }

            // Enforce submission deadline strictly at POST processing time
            if (tender.isDeadlinePassed()) {
                sendValidationError(req, resp, "The submission deadline for this tender has passed.",
                        tender, amountStr, proposalText);
                return;
            }

            // Pre-check for duplicate bid
            if (bidDao.hasVendorBid(tenderId, vendor.getId())) {
                sendValidationError(req, resp, "You have already submitted a bid for this tender.",
                        tender, amountStr, proposalText);
                return;
            }

            // Validate amount
            if (amountStr == null || amountStr.trim().isEmpty()) {
                sendValidationError(req, resp, "Bid amount is required.",
                        tender, amountStr, proposalText);
                return;
            }

            BigDecimal amount;
            try {
                amount = new BigDecimal(amountStr.trim());
                if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                    sendValidationError(req, resp, "Bid amount must be a positive number.",
                        tender, amountStr, proposalText);
                    return;
                }
            } catch (NumberFormatException e) {
                sendValidationError(req, resp, "Bid amount must be a valid number.",
                        tender, amountStr, proposalText);
                return;
            }

            // Validate proposal text
            if (proposalText == null || proposalText.trim().isEmpty()) {
                sendValidationError(req, resp, "Proposal text is required.",
                        tender, amountStr, proposalText);
                return;
            }

            // Handle optional proposal attachment
            String uploadedFilename = null;
            try {
                Part filePart = req.getPart("attachment");
                if (filePart != null && filePart.getSize() > 0) {
                    uploadedFilename = FileUploadUtil.saveUploadedFile(filePart, "bids");
                }
            } catch (IllegalArgumentException | SecurityException e) {
                sendValidationError(req, resp, e.getMessage(),
                        tender, amountStr, proposalText);
                return;
            }

            // Insert bid
            Bid bid = new Bid();
            bid.setTenderId(tenderId);
            bid.setVendorId(vendor.getId());
            bid.setAmount(amount);
            bid.setProposalText(proposalText.trim());
            bid.setStatus("SUBMITTED");
            bid.setAttachmentFilename(uploadedFilename);
            bid.setAttachmentPath(uploadedFilename != null ? "bids/" + uploadedFilename : null);

            int bidId;
            try {
                bidId = bidDao.insert(bid);
            } catch (SQLException e) {
                // Catch MySQL unique constraint violation (error code 1062 or SQLState 23000)
                if (e.getErrorCode() == 1062 || "23000".equals(e.getSQLState())) {
                    sendValidationError(req, resp, "You have already submitted a bid for this tender.",
                            tender, amountStr, proposalText);
                    return;
                }
                throw e;
            }

            // Insert audit log
            auditLogDao.log(userId, "BID_SUBMITTED", "BID", bidId,
                    "Bid of ₹ " + bid.getFormattedAmount() + " submitted by " + vendor.getCompanyName() +
                    " for tender #" + tenderId + " (" + tender.getTitle() + ")");

            // Notify Administrator
            Notification adminNotification = new Notification();
            adminNotification.setUserId(1); // Default admin ID
            adminNotification.setTitle("New Bid Received");
            adminNotification.setMessage(vendor.getCompanyName() + " submitted a bid of ₹ " +
                    bid.getFormattedAmount() + " for Tender #" + tenderId);
            adminNotification.setLink("bids?tenderId=" + tenderId);
            notificationDao.insert(adminNotification);

            resp.sendRedirect("tender?id=" + tenderId + "&bidSuccess=1");

        } catch (SQLException e) {
            throw new ServletException("Database error submitting bid", e);
        }
    }

    private void sendValidationError(HttpServletRequest req, HttpServletResponse resp, String errorMsg,
                                     Tender tender, String inputAmount, String inputProposal)
            throws ServletException, IOException {

        req.setAttribute("tender", tender);
        req.setAttribute("inputAmount", inputAmount);
        req.setAttribute("inputProposal", inputProposal);
        req.setAttribute("error", errorMsg);

        req.getRequestDispatcher("/WEB-INF/views/bid-form.jsp").forward(req, resp);
    }
}
