package com.tms.servlet;

import com.tms.dao.UserDao;
import com.tms.dao.VendorDao;
import com.tms.model.User;
import com.tms.model.Vendor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet({"/register", "/signup"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("signup.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String companyName = req.getParameter("companyName");
        String registrationNumber = req.getParameter("registrationNumber");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");

        // Trim values if not null
        if (name != null) name = name.trim();
        if (email != null) email = email.trim();
        if (companyName != null) companyName = companyName.trim();
        if (registrationNumber != null) registrationNumber = registrationNumber.trim();
        if (phone != null) phone = phone.trim();
        if (address != null) address = address.trim();

        // Preserve input values for redisplay on validation error
        req.setAttribute("name", name);
        req.setAttribute("email", email);
        req.setAttribute("companyName", companyName);
        req.setAttribute("registrationNumber", registrationNumber);
        req.setAttribute("phone", phone);
        req.setAttribute("address", address);

        // Server-side validation: all fields required
        if (name == null || name.isEmpty() ||
            email == null || email.isEmpty() ||
            password == null || password.isEmpty() ||
            companyName == null || companyName.isEmpty() ||
            registrationNumber == null || registrationNumber.isEmpty() ||
            phone == null || phone.isEmpty() ||
            address == null || address.isEmpty()) {

            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("signup.jsp").forward(req, resp);
            return;
        }

        // Validate password confirmation if provided
        if (confirmPassword != null && !confirmPassword.trim().isEmpty() && !confirmPassword.equals(password)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("signup.jsp").forward(req, resp);
            return;
        }

        try {
            UserDao userDao = new UserDao();
            if (userDao.existsByEmail(email)) {
                req.setAttribute("error", "Email is already registered.");
                req.getRequestDispatcher("signup.jsp").forward(req, resp);
                return;
            }

            VendorDao vendorDao = new VendorDao();
            if (vendorDao.existsByRegistrationNumber(registrationNumber)) {
                req.setAttribute("error", "Registration number is already registered.");
                req.getRequestDispatcher("signup.jsp").forward(req, resp);
                return;
            }

            User user = new User();
            user.setName(name);
            user.setEmail(email);
            user.setPassword(password);
            user.setRole("VENDOR");
            user.setStatus("ACTIVE");

            Vendor vendor = new Vendor();
            vendor.setCompanyName(companyName);
            vendor.setRegistrationNumber(registrationNumber);
            vendor.setPhone(phone);
            vendor.setAddress(address);
            vendor.setApprovalStatus("PENDING");

            vendorDao.registerVendor(user, vendor);

            resp.sendRedirect("login.jsp?registered=pending");

        } catch (SQLException e) {
            throw new ServletException("Database error during vendor registration", e);
        }
    }
}
