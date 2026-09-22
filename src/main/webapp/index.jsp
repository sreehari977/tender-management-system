<%
    Object role = session.getAttribute("userRole");
    if (role == null) {
        role = session.getAttribute("role");
    }
    if ("ADMIN".equalsIgnoreCase(String.valueOf(role))) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
    } else if ("VENDOR".equalsIgnoreCase(String.valueOf(role))) {
        response.sendRedirect(request.getContextPath() + "/tenders");
    } else {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
%>
