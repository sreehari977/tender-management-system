package com.tms.servlet;

import com.tms.dao.BidDao;
import com.tms.dao.ContractAwardDao;
import com.tms.dao.TenderDao;
import com.tms.dao.VendorDao;
import com.tms.model.Bid;
import com.tms.model.ContractAward;
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

@WebServlet("/award-certificate")
public class AwardCertificateServlet extends HttpServlet {

    private final ContractAwardDao awardDao = new ContractAwardDao();
    private final TenderDao tenderDao = new TenderDao();
    private final BidDao bidDao = new BidDao();
    private final VendorDao vendorDao = new VendorDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

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

        String role = (String) session.getAttribute("userRole");
        int currentUserId = (Integer) session.getAttribute("userId");

        try {
            ContractAward award = awardDao.findByTenderId(tenderId);
            if (award == null) {
                req.setAttribute("errorMessage", "No contract award certificate has been issued for this tender.");
                req.getRequestDispatcher("/WEB-INF/views/error-404.jsp").forward(req, resp);
                return;
            }

            Tender tender = tenderDao.findById(tenderId);
            Bid winningBid = bidDao.findById(award.getBidId());

            // Security authorization check: Admins or the Awarded Vendor
            boolean isAuthorized = "ADMIN".equalsIgnoreCase(role);
            if (!isAuthorized && "VENDOR".equalsIgnoreCase(role) && winningBid != null) {
                Vendor v = vendorDao.findByUserId(currentUserId);
                if (v != null && v.getId() == winningBid.getVendorId()) {
                    isAuthorized = true;
                }
            }

            if (!isAuthorized) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You are not authorized to view this official contract award certificate.");
                return;
            }

            req.setAttribute("award", award);
            req.setAttribute("tender", tender);
            req.setAttribute("winningBid", winningBid);

            req.getRequestDispatcher("/WEB-INF/views/award-certificate.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading contract award certificate", e);
        }
    }
}
