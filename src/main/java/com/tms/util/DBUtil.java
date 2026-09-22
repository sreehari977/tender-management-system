package com.tms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL driver not found on classpath", e);
        }
    }

    private static final String DEFAULT_URL =
        "jdbc:mysql://localhost:3306/tender_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "password";

    public static Connection getConnection() throws SQLException {
        String url = System.getProperty("db.url", System.getenv("DB_URL") != null ? System.getenv("DB_URL") : DEFAULT_URL);
        String user = System.getProperty("db.user", System.getenv("DB_USER") != null ? System.getenv("DB_USER") : DEFAULT_USER);
        String password = System.getProperty("db.password", System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : DEFAULT_PASSWORD);
        return DriverManager.getConnection(url, user, password);
    }
}