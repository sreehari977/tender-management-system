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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UserDao userDao = new UserDao();
            User user = userDao.findByEmailAndPassword(email, password);

            if (user == null) {
                resp.sendRedirect("login.jsp?error=1");
                return;
            }

            HttpSession session = req.getSession();
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
