<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification Center — Tender Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/custom.css" rel="stylesheet">
</head>
<body class="bg-light d-flex flex-column min-vh-100">

    <jsp:include page="/WEB-INF/includes/navbar.jsp"/>

    <div class="container py-3" style="max-width: 800px;">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h4 class="fw-bold mb-1 text-dark">Notification Center</h4>
                <p class="text-muted small mb-0">System alerts, procurement updates, and status announcements</p>
            </div>
            <c:if test="${unreadCount > 0}">
                <form action="${pageContext.request.contextPath}/notifications" method="post" class="m-0">
                    <input type="hidden" name="action" value="mark_all_read">
                    <input type="hidden" name="redirect" value="notifications">
                    <button type="submit" class="btn btn-outline-primary btn-sm">
                        Mark All as Read (${unreadCount})
                    </button>
                </form>
            </c:if>
        </div>

        <!-- Notification List Card -->
        <div class="card shadow-sm border-0 mb-4">
            <div class="list-group list-group-flush">
                <c:forEach var="n" items="${notifications}">
                    <div class="list-group-item p-4 ${!n.read ? 'bg-light border-start border-primary border-4' : ''}">
                        <div class="d-flex w-100 justify-content-between align-items-center mb-1">
                            <h6 class="mb-0 fw-bold text-dark">
                                <c:out value="${n.title}"/>
                                <c:if test="${!n.read}">
                                    <span class="badge bg-primary ms-2" style="font-size: 0.65rem;">NEW</span>
                                </c:if>
                            </h6>
                            <small class="text-muted"><c:out value="${n.formattedCreatedAt}"/></small>
                        </div>
                        <p class="mb-2 text-secondary small" style="line-height: 1.5;">
                            <c:out value="${n.message}"/>
                        </p>
                        <c:if test="${not empty n.link}">
                            <a href="${pageContext.request.contextPath}/${n.link}" class="btn btn-sm btn-outline-primary py-0 px-2" style="font-size: 0.8rem;">
                                View Details &rarr;
                            </a>
                        </c:if>
                    </div>
                </c:forEach>
                <c:if test="${empty notifications}">
                    <div class="text-center py-5">
                        <div style="font-size: 2.5rem;" class="mb-2">&#128276;</div>
                        <h6 class="fw-bold text-secondary">No notifications yet</h6>
                        <p class="small text-muted mb-0">You're all caught up! Updates regarding tenders and bids will appear here.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="mt-auto py-3 bg-white border-top text-center text-muted small">
        &copy; 2026 Tender Management System &bull; In-App Alert Dispatcher
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
