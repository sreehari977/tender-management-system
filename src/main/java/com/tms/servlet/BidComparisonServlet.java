package com.tms.servlet;

import com.tms.dao.BidDao;
import com.tms.dao.ContractAwardDao;
import com.tms.dao.TenderDao;
import com.tms.model.Bid;
import com.tms.model.ContractAward;
import com.tms.model.Tender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/bids")
public class BidComparisonServlet extends HttpServlet {

    private final TenderDao tenderDao = new TenderDao();
    private final BidDao bidDao = new BidDao();
    private final ContractAwardDao contractAwardDao = new ContractAwardDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("userRole");
        if (!"ADMIN".equalsIgnoreCase(userRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only administrators can compare and award bids.");
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

        try {
            Tender tender = tenderDao.findById(tenderId);
            if (tender == null) {
                resp.sendRedirect("tenders");
                return;
            }
            req.setAttribute("tender", tender);

            // Check if this tender has already been awarded
            ContractAward award = contractAwardDao.findByTenderId(tenderId);
            if (award != null) {
                req.setAttribute("isAwarded", true);
                req.setAttribute("award", award);

                // Fetch bids for historical inspection
                List<Bid> bids = bidDao.findByTender(tenderId, "amount");
                req.setAttribute("bids", bids);
                req.getRequestDispatcher("/WEB-INF/views/bid-comparison.jsp").forward(req, resp);
                return;
            }

            req.setAttribute("isAwarded", false);

            // Sorting logic
            String sort = req.getParameter("sort");
            if (!"date".equalsIgnoreCase(sort)) {
                sort = "amount";
            }
            req.setAttribute("sort", sort);

            List<Bid> bids = bidDao.findByTender(tenderId, sort);

            // Enrich with procurement ranks and budget variance calculations
            BigDecimal budget = tender.getEstimatedBudget();
            for (int i = 0; i < bids.size(); i++) {
                Bid b = bids.get(i);

                // Procurement Ranking (L1 is lowest bidder when sorted by amount)
                if ("amount".equalsIgnoreCase(sort)) {
                    if (i == 0) {
                        b.setRankLabel("L1 (Lowest Bidder)");
                    } else {
                        b.setRankLabel("L" + (i + 1));
                    }
                }

                // Variance against estimated budget
                if (budget != null && budget.compareTo(BigDecimal.ZERO) > 0 && b.getAmount() != null) {
                    BigDecimal diff = b.getAmount().subtract(budget);
                    BigDecimal pct = diff.multiply(BigDecimal.valueOf(100))
                                         .divide(budget, 1, RoundingMode.HALF_UP);

                    b.setVarianceAmount(diff.abs());
                    if (diff.compareTo(BigDecimal.ZERO) < 0) {
                        b.setVariancePercent(String.format("%.1f%% below budget", pct.abs().doubleValue()));
                        b.setVarianceClass("text-success fw-semibold");
                    } else if (diff.compareTo(BigDecimal.ZERO) > 0) {
                        b.setVariancePercent(String.format("%.1f%% above budget", pct.doubleValue()));
                        b.setVarianceClass("text-danger fw-semibold");
                    } else {
                        b.setVariancePercent("Matches budget");
                        b.setVarianceClass("text-primary fw-semibold");
                    }
                }
            }

            req.setAttribute("bids", bids);
            req.getRequestDispatcher("/WEB-INF/views/bid-comparison.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading bids for comparison", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("userRole");
        if (!"ADMIN".equalsIgnoreCase(userRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Only administrators can award contracts.");
            return;
        }

        int adminUserId = (Integer) session.getAttribute("userId");

        String tenderIdParam = req.getParameter("tenderId");
        String bidIdParam = req.getParameter("bidId");
        String notes = req.getParameter("notes");

        if (tenderIdParam == null || bidIdParam == null) {
            resp.sendRedirect("tenders");
            return;
        }

        int tenderId;
        int bidId;
        try {
            tenderId = Integer.parseInt(tenderIdParam.trim());
            bidId = Integer.parseInt(bidIdParam.trim());
            if (tenderId <= 0 || bidId <= 0) {
                resp.sendRedirect("tenders");
                return;
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect("tenders");
            return;
        }

        try {
            // Guard 1: Verify tender exists and is not already closed / awarded
            Tender tender = tenderDao.findById(tenderId);
            if (tender == null) {
                resp.sendRedirect("tenders");
                return;
            }

            ContractAward existingAward = contractAwardDao.findByTenderId(tenderId);
            if (existingAward != null || "CLOSED".equalsIgnoreCase(tender.getStatus())) {
                resp.sendRedirect("bids?tenderId=" + tenderId + "&alreadyAwarded=1");
                return;
            }

            // Guard 2: Verify bid exists and belongs to this tender
            Bid bid = bidDao.findById(bidId);
            if (bid == null || bid.getTenderId() != tenderId) {
                resp.sendRedirect("bids?tenderId=" + tenderId + "&error=invalidBid");
                return;
            }

            // Execute atomic contract award transaction
            contractAwardDao.awardContractTransaction(tenderId, bidId, adminUserId, notes);

            // Redirect using PRG pattern
            resp.sendRedirect("bids?tenderId=" + tenderId + "&awarded=1");

        } catch (SQLException e) {
            throw new ServletException("Failed to award contract for Tender #" + tenderId, e);
        }
    }
}
