package com.tms.servlet;

import com.tms.dao.BidDao;
import com.tms.dao.VendorDao;
import com.tms.model.Bid;
import com.tms.model.Vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/my-bids")
public class MyBidsServlet extends HttpServlet {

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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only vendors can view bid history.");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        try {
            VendorDao vendorDao = new VendorDao();
            Vendor vendor = vendorDao.findByUserId(userId);

            List<Bid> bids = new ArrayList<>();
            int totalBids = 0;
            long submittedCount = 0;
            long underReviewCount = 0;
            long awardedCount = 0;
            long rejectedCount = 0;

            if (vendor != null) {
                BidDao bidDao = new BidDao();
                bids = bidDao.findByVendor(vendor.getId());

                totalBids = bids.size();
                submittedCount = bids.stream().filter(b -> "SUBMITTED".equals(b.getStatus())).count();
                underReviewCount = bids.stream().filter(b -> "UNDER_REVIEW".equals(b.getStatus())).count();
                awardedCount = bids.stream().filter(b -> "AWARDED".equals(b.getStatus())).count();
                rejectedCount = bids.stream().filter(b -> "REJECTED".equals(b.getStatus())).count();
            }

            req.setAttribute("vendor", vendor);
            req.setAttribute("bids", bids);
            req.setAttribute("totalBids", totalBids);
            req.setAttribute("submittedCount", submittedCount);
            req.setAttribute("underReviewCount", underReviewCount);
            req.setAttribute("awardedCount", awardedCount);
            req.setAttribute("rejectedCount", rejectedCount);

            req.getRequestDispatcher("/WEB-INF/views/my-bids.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error retrieving vendor bid history", e);
        }
    }
}
