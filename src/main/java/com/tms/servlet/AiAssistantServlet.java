package com.tms.servlet;

import com.tms.dao.BidDao;
import com.tms.dao.TenderDao;
import com.tms.dao.VendorDao;
import com.tms.model.Bid;
import com.tms.model.Tender;
import com.tms.model.Vendor;
import com.tms.service.AiProcurementService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/api/ai")
public class AiAssistantServlet extends HttpServlet {

    private final AiProcurementService aiService = new AiProcurementService();
    private final TenderDao tenderDao = new TenderDao();
    private final BidDao bidDao = new BidDao();
    private final VendorDao vendorDao = new VendorDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    @SuppressWarnings("unchecked")
    private void handleRequest(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        boolean isAuthenticated = (session != null && session.getAttribute("userId") != null);
        int userId = isAuthenticated ? (Integer) session.getAttribute("userId") : 0;
        String userRole = isAuthenticated ? (String) session.getAttribute("userRole") : "GUEST";
        String userName = isAuthenticated ? (String) session.getAttribute("userName") : "Guest";

        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "page_guide";
        }

        boolean isPublicAction = "page_guide".equalsIgnoreCase(action) ||
                                 "chat".equalsIgnoreCase(action) ||
                                 "summarize_tender".equalsIgnoreCase(action);

        if (!isAuthenticated && !isPublicAction) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"error\":\"Authentication required\"}");
            return;
        }

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            switch (action.toLowerCase()) {
                case "page_guide": {
                    String page = req.getParameter("page");
                    Map<String, Object> guide = aiService.getPageGuide(page, userRole, userName);
                    out.print(toJson(guide));
                    break;
                }

                case "chat": {
                    String query = req.getParameter("query");
                    String page = req.getParameter("page");
                    Map<String, Object> answer = aiService.answerQuery(query, page, userRole);
                    out.print(toJson(answer));
                    break;
                }

                case "summarize_tender": {
                    String tenderIdStr = req.getParameter("tenderId");
                    if (tenderIdStr == null) {
                        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"error\":\"Missing tenderId parameter\"}");
                        return;
                    }
                    int tenderId = Integer.parseInt(tenderIdStr.trim());
                    Tender tender = tenderDao.findById(tenderId);
                    if (tender == null) {
                        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.write("{\"error\":\"Tender not found\"}");
                        return;
                    }
                    Map<String, Object> summary = aiService.summarizeTender(tender);
                    out.print(toJson(summary));
                    break;
                }

                case "draft_proposal": {
                    if (!"VENDOR".equalsIgnoreCase(userRole)) {
                        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        out.write("{\"error\":\"Proposal drafting is restricted to vendors\"}");
                        return;
                    }
                    String tenderIdStr = req.getParameter("tenderId");
                    if (tenderIdStr == null) {
                        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"error\":\"Missing tenderId parameter\"}");
                        return;
                    }
                    int tenderId = Integer.parseInt(tenderIdStr.trim());
                    Tender tender = tenderDao.findById(tenderId);
                    Vendor vendor = vendorDao.findByUserId(userId);
                    String draft = aiService.draftProposal(tender, vendor);
                    out.print("{\"draft\":\"" + escapeJson(draft) + "\"}");
                    break;
                }

                case "analyze_proposal": {
                    String proposalText = req.getParameter("proposalText");
                    String tenderIdStr = req.getParameter("tenderId");
                    String amountStr = req.getParameter("amount");

                    BigDecimal budget = null;
                    if (tenderIdStr != null) {
                        try {
                            Tender tender = tenderDao.findById(Integer.parseInt(tenderIdStr.trim()));
                            if (tender != null) {
                                budget = tender.getEstimatedBudget();
                            }
                        } catch (NumberFormatException ignored) {}
                    }

                    BigDecimal amount = null;
                    if (amountStr != null && !amountStr.trim().isEmpty()) {
                        try {
                            amount = new BigDecimal(amountStr.trim());
                        } catch (NumberFormatException ignored) {}
                    }

                    Map<String, Object> analysis = aiService.analyzeProposal(proposalText, budget, amount);
                    out.print(toJson(analysis));
                    break;
                }

                case "evaluate_bids": {
                    if (!"ADMIN".equalsIgnoreCase(userRole)) {
                        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        out.write("{\"error\":\"Bid evaluation is restricted to administrators\"}");
                        return;
                    }
                    String tenderIdStr = req.getParameter("tenderId");
                    if (tenderIdStr == null) {
                        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.write("{\"error\":\"Missing tenderId parameter\"}");
                        return;
                    }
                    int tenderId = Integer.parseInt(tenderIdStr.trim());
                    Tender tender = tenderDao.findById(tenderId);
                    if (tender == null) {
                        resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        out.write("{\"error\":\"Tender not found\"}");
                        return;
                    }
                    List<Bid> bids = bidDao.findByTender(tenderId);
                    Map<String, Object> riskEval = aiService.evaluateBidsRisk(tender, bids);
                    out.print(toJson(riskEval));
                    break;
                }

                default:
                    resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.write("{\"error\":\"Unsupported action\"}");
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException("Database error handling AI assistant request", e);
        }
    }

    private String toJson(Object obj) {
        if (obj == null) return "null";
        if (obj instanceof String) {
            return "\"" + escapeJson((String) obj) + "\"";
        }
        if (obj instanceof Number || obj instanceof Boolean) {
            return obj.toString();
        }
        if (obj instanceof Map) {
            StringBuilder sb = new StringBuilder("{");
            Map<?, ?> map = (Map<?, ?>) obj;
            int i = 0;
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (i > 0) sb.append(",");
                sb.append("\"").append(escapeJson(String.valueOf(entry.getKey()))).append("\":");
                sb.append(toJson(entry.getValue()));
                i++;
            }
            sb.append("}");
            return sb.toString();
        }
        if (obj instanceof List) {
            StringBuilder sb = new StringBuilder("[");
            List<?> list = (List<?>) obj;
            for (int i = 0; i < list.size(); i++) {
                if (i > 0) sb.append(",");
                sb.append(toJson(list.get(i)));
            }
            sb.append("]");
            return sb.toString();
        }
        return "\"" + escapeJson(obj.toString()) + "\"";
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }
}
