package com.tms.servlet;

import com.tms.dao.BidDao;
import com.tms.dao.TenderDao;
import com.tms.dao.VendorDao;
import com.tms.model.Bid;
import com.tms.model.Tender;
import com.tms.model.Vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;

@WebServlet("/tender")
public class TenderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect("tenders");
            return;
        }

        int tenderId;
        try {
            tenderId = Integer.parseInt(idParam.trim());
            if (tenderId <= 0) {
                resp.sendRedirect("tenders");
                return;
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect("tenders");
            return;
        }

        try {
            TenderDao tenderDao = new TenderDao();
            Tender tender = tenderDao.findById(tenderId);

            if (tender == null) {
                resp.sendRedirect("tenders");
                return;
            }

            String userRole = (String) session.getAttribute("userRole");

            // Edge case guard: DRAFT tenders are private to administrators and cannot be viewed by vendors
            if (!"ADMIN".equals(userRole) && "DRAFT".equals(tender.getStatus())) {
                resp.sendRedirect("tenders");
                return;
            }

            Integer userId = (Integer) session.getAttribute("userId");

            boolean isApprovedVendor = false;
            boolean hasSubmittedBid = false;
            Bid existingBid = null;

            if ("VENDOR".equals(userRole) && userId != null) {
                VendorDao vendorDao = new VendorDao();
                Vendor vendor = vendorDao.findByUserId(userId);
                if (vendor != null) {
                    if ("APPROVED".equals(vendor.getApprovalStatus())) {
                        isApprovedVendor = true;
                    }
                    BidDao bidDao = new BidDao();
                    existingBid = bidDao.findByTenderAndVendor(tenderId, vendor.getId());
                    hasSubmittedBid = (existingBid != null);
                }
            }

            boolean isDeadlinePassed = tender.getDeadline() != null &&
                    !tender.getDeadline().after(new Timestamp(System.currentTimeMillis()));

            boolean canSubmitBid = isApprovedVendor &&
                    "PUBLISHED".equals(tender.getStatus()) &&
                    !isDeadlinePassed &&
                    !hasSubmittedBid;

            req.setAttribute("tender", tender);
            req.setAttribute("isApprovedVendor", isApprovedVendor);
            req.setAttribute("hasSubmittedBid", hasSubmittedBid);
            req.setAttribute("existingBid", existingBid);
            req.setAttribute("isDeadlinePassed", isDeadlinePassed);
            req.setAttribute("canSubmitBid", canSubmitBid);

            req.getRequestDispatcher("/WEB-INF/views/tender-detail.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading tender details", e);
        }
    }
}
