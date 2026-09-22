package com.tms.servlet;

import com.tms.dao.AuditLogDao;
import com.tms.model.AuditLog;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/audit-logs")
public class AuditLogServlet extends HttpServlet {

    private final AuditLogDao auditLogDao = new AuditLogDao();
    private static final int PAGE_SIZE = 15;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equals(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: The system audit trail is restricted to administrators.");
            return;
        }

        String actionFilter = req.getParameter("action");
        String pageStr = req.getParameter("page");
        int page = 1;
        if (pageStr != null) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }

        int offset = (page - 1) * PAGE_SIZE;

        try {
            int totalRecords = auditLogDao.count(actionFilter);
            int totalPages = (int) Math.ceil((double) totalRecords / PAGE_SIZE);
            if (totalPages < 1) totalPages = 1;

            List<AuditLog> logs = auditLogDao.findAll(PAGE_SIZE, offset, actionFilter);
            List<String> distinctActions = auditLogDao.getDistinctActions();

            req.setAttribute("logs", logs);
            req.setAttribute("distinctActions", distinctActions);
            req.setAttribute("currentAction", actionFilter);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalRecords", totalRecords);

            req.getRequestDispatcher("/WEB-INF/views/audit-logs.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error retrieving audit logs", e);
        }
    }
}
