package com.tms.servlet;

import com.tms.dao.TenderDao;
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

@WebServlet("/tenders")
public class TenderListServlet extends HttpServlet {

    private final TenderDao tenderDao = new TenderDao();
    private static final int PAGE_SIZE = 6;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String query = req.getParameter("q");
        String category = req.getParameter("category");
        String minBudgetStr = req.getParameter("minBudget");
        String maxBudgetStr = req.getParameter("maxBudget");
        String sort = req.getParameter("sort");
        String pageStr = req.getParameter("page");

        BigDecimal minBudget = null;
        if (minBudgetStr != null && !minBudgetStr.trim().isEmpty()) {
            try {
                minBudget = new BigDecimal(minBudgetStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        BigDecimal maxBudget = null;
        if (maxBudgetStr != null && !maxBudgetStr.trim().isEmpty()) {
            try {
                maxBudget = new BigDecimal(maxBudgetStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        int page = 1;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }

        int offset = (page - 1) * PAGE_SIZE;

        try {
            int totalRecords = tenderDao.countFiltered(query, category, minBudget, maxBudget);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;
            if (page > totalPages) page = totalPages;

            List<Tender> tenders = tenderDao.searchAndFilter(query, category, minBudget, maxBudget, sort, offset, PAGE_SIZE);
            List<String> categories = tenderDao.getCategories();

            req.setAttribute("tenders", tenders);
            req.setAttribute("categories", categories);
            req.setAttribute("currentQuery", query != null ? query.trim() : "");
            req.setAttribute("currentCategory", category != null ? category.trim() : "");
            req.setAttribute("currentMinBudget", minBudgetStr != null ? minBudgetStr.trim() : "");
            req.setAttribute("currentMaxBudget", maxBudgetStr != null ? maxBudgetStr.trim() : "");
            req.setAttribute("currentSort", sort != null ? sort.trim() : "deadline_asc");
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalRecords", totalRecords);

            req.getRequestDispatcher("/WEB-INF/views/tenders.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error loading tenders", e);
        }
    }
}
