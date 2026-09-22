package com.tms.servlet;

import com.tms.dao.DashboardDao;
import com.tms.model.Tender;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    private final DashboardDao dashboardDao = new DashboardDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String userRole = (String) session.getAttribute("userRole");
        if (!"ADMIN".equalsIgnoreCase(userRole)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: The executive dashboard is restricted to administrator accounts.");
            return;
        }

        try {
            int totalVendors = dashboardDao.getTotalVendors();
            int pendingApprovals = dashboardDao.getPendingVendorApprovals();
            int totalTenders = dashboardDao.getTotalTenders();
            int publishedTenders = dashboardDao.getPublishedTenders();
            int closedTenders = dashboardDao.getClosedTenders();
            int totalBids = dashboardDao.getTotalBids();
            int totalAwards = dashboardDao.getTotalContractAwards();
            BigDecimal totalAwardedValue = dashboardDao.getTotalAwardedValue();
            List<Tender> recentTenders = dashboardDao.getRecentPublishedTenders(5);

            req.setAttribute("totalVendors", totalVendors);
            req.setAttribute("pendingApprovals", pendingApprovals);
            req.setAttribute("totalTenders", totalTenders);
            req.setAttribute("publishedTenders", publishedTenders);
            req.setAttribute("closedTenders", closedTenders);
            req.setAttribute("totalBids", totalBids);
            req.setAttribute("totalAwards", totalAwards);
            req.setAttribute("totalAwardedValue", String.format("%,.2f", totalAwardedValue));
            req.setAttribute("recentTenders", recentTenders);

            req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading admin dashboard metrics", e);
        }
    }
}
