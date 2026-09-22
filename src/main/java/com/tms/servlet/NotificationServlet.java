package com.tms.servlet;

import com.tms.dao.NotificationDao;
import com.tms.model.Notification;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private final NotificationDao notificationDao = new NotificationDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            if ("json".equalsIgnoreCase(req.getParameter("format"))) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
            }
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String format = req.getParameter("format");

        try {
            int unreadCount = notificationDao.countUnreadByUserId(userId);
            List<Notification> recent = notificationDao.findRecentByUserId(userId, 10);

            if ("json".equalsIgnoreCase(format)) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                PrintWriter out = resp.getWriter();
                StringBuilder json = new StringBuilder();
                json.append("{\"unreadCount\":").append(unreadCount).append(",\"notifications\":[");
                for (int i = 0; i < recent.size(); i++) {
                    Notification n = recent.get(i);
                    json.append("{")
                        .append("\"id\":").append(n.getId()).append(",")
                        .append("\"title\":\"").append(escapeJson(n.getTitle())).append("\",")
                        .append("\"message\":\"").append(escapeJson(n.getMessage())).append("\",")
                        .append("\"link\":\"").append(escapeJson(n.getLink() != null ? n.getLink() : "")).append("\",")
                        .append("\"isRead\":").append(n.isRead()).append(",")
                        .append("\"createdAt\":\"").append(n.getFormattedCreatedAt()).append("\"")
                        .append("}");
                    if (i < recent.size() - 1) json.append(",");
                }
                json.append("]}");
                out.print(json.toString());
                out.flush();
                return;
            }

            req.setAttribute("unreadCount", unreadCount);
            req.setAttribute("notifications", recent);
            req.getRequestDispatcher("/WEB-INF/views/notifications.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Error retrieving notifications", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            String redirect = req.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/login.jsp");
            } else {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            }
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            if ("mark_all_read".equalsIgnoreCase(action)) {
                notificationDao.markAllAsRead(userId);
            } else if ("mark_read".equalsIgnoreCase(action)) {
                String idStr = req.getParameter("id");
                if (idStr != null) {
                    notificationDao.markAsRead(Integer.parseInt(idStr), userId);
                }
            }

            String redirect = req.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()) {
                resp.sendRedirect(redirect);
            } else {
                resp.setContentType("application/json");
                resp.getWriter().write("{\"success\":true}");
            }

        } catch (SQLException e) {
            throw new ServletException("Error updating notifications", e);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
