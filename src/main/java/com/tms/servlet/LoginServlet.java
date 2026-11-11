package com.tms.servlet;

import com.tms.dao.UserDao;
import com.tms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;
import java.util.Set;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final Set<String> DEMO_EMAILS = Set.of(
            "admin@tms.com",
            "vendor1@tms.com",
            "vendor2@tms.com",
            "ananya@sharmaconstructions.com",
            "fraud@example.com"
    );

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UserDao userDao = new UserDao();
            User user = userDao.findByEmailAndPassword(email, password);

            boolean demoAccount = user != null && user.getEmail() != null &&
                    DEMO_EMAILS.contains(user.getEmail().trim().toLowerCase(Locale.ROOT));
            boolean demoAccountsEnabled = Boolean.parseBoolean(
                    System.getenv("TMS_ENABLE_DEMO_ACCOUNTS"));

            // Demo accounts are disabled unless explicitly enabled for an isolated sandbox.
            if (user == null || (demoAccount && !demoAccountsEnabled)) {
                resp.sendRedirect("login.jsp?error=1");
                return;
            }

            HttpSession session = req.getSession();
            req.changeSessionId();
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole());

            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                resp.sendRedirect("dashboard");
            } else {
                resp.sendRedirect("tenders");
            }

        } catch (SQLException e) {
            throw new ServletException("Database error during login", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendRedirect("login.jsp");
    }
}
