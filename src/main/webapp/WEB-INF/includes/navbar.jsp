<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%--
  Standard Status Badges Reference:
  - Tender Status:
      PUBLISHED  -> badge-status-published (Green)
      DRAFT      -> badge-status-draft (Gray)
      CLOSED     -> badge-status-closed (Dark)
      ARCHIVED   -> badge-status-archived (Muted)
  - Bid Status:
      SUBMITTED    -> badge-status-submitted (Blue)
      UNDER_REVIEW -> badge-status-under-review (Amber)
      AWARDED      -> badge-status-awarded (Green)
      REJECTED     -> badge-status-rejected (Red)
  - Vendor Approval Status:
      PENDING  -> badge-status-pending (Amber)
      APPROVED -> badge-status-approved (Green)
      REJECTED -> badge-status-rejected (Red)
--%>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4 shadow-sm">
    <div class="container">
        <c:choose>
            <c:when test="${sessionScope.userRole == 'ADMIN'}">
                <a class="navbar-brand h1 mb-0 fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/dashboard">
                    <span class="text-primary fs-4">&#128737;</span>
                    <span>Tender Management System</span>
                </a>
            </c:when>
            <c:otherwise>
                <a class="navbar-brand h1 mb-0 fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/tenders">
                    <span class="text-primary fs-4">&#128737;</span>
                    <span>Tender Management System</span>
                </a>
            </c:otherwise>
        </c:choose>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain"
                aria-controls="navbarMain" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarMain">
            <div class="navbar-nav me-auto">
                <c:if test="${sessionScope.userRole == 'ADMIN'}">
                    <a class="nav-link ${param.activeNav == 'dashboard' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
                    <a class="nav-link ${param.activeNav == 'tenders' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/tenders">Active Tenders</a>
                    <a class="nav-link ${param.activeNav == 'approvals' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/vendor-approvals">Vendor Approvals</a>
                    <a class="nav-link ${param.activeNav == 'audit' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/audit-logs">Audit Trail</a>
                </c:if>

                <c:if test="${sessionScope.userRole == 'VENDOR'}">
                    <a class="nav-link ${param.activeNav == 'tenders' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/tenders">Active Tenders</a>
                    <a class="nav-link ${param.activeNav == 'my-bids' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/my-bids">My Bids</a>
                </c:if>

                <c:if test="${empty sessionScope.userId}">
                    <a class="nav-link ${param.activeNav == 'tenders' ? 'active fw-semibold' : ''}" 
                       href="${pageContext.request.contextPath}/tenders">Active Tenders</a>
                </c:if>
            </div>

            <div class="d-flex align-items-center gap-3">
                <c:choose>
                    <c:when test="${not empty sessionScope.userId}">
                        <!-- Notifications Dropdown -->
                        <div class="dropdown">
                            <a href="${pageContext.request.contextPath}/notifications" 
                               class="text-white text-decoration-none position-relative p-1"
                               id="notificationDropdownToggle" 
                               data-bs-toggle="dropdown" 
                               aria-expanded="false" 
                               title="Notifications">
                                <span style="font-size: 1.15rem;">&#128276;</span>
                                <span id="navbarNotifBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none" style="font-size: 0.65rem;">
                                    0
                                </span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0 mt-2" 
                                style="width: 320px; max-height: 400px; overflow-y: auto;" 
                                aria-labelledby="notificationDropdownToggle" 
                                id="navbarNotifList">
                                <li class="dropdown-header d-flex justify-content-between align-items-center py-2 px-3 border-bottom">
                                    <span class="fw-bold text-dark">Notifications</span>
                                    <form action="${pageContext.request.contextPath}/notifications" method="post" class="m-0 d-inline">
                                        <input type="hidden" name="action" value="mark_all_read">
                                        <button type="submit" class="btn btn-link btn-sm p-0 text-decoration-none text-primary" style="font-size: 0.75rem;">
                                            Mark all read
                                        </button>
                                    </form>
                                </li>
                                <li id="notifLoadingItem" class="p-3 text-center text-muted small">
                                    Loading alerts...
                                </li>
                                <li class="border-top text-center p-2 bg-light">
                                    <a href="${pageContext.request.contextPath}/notifications" class="text-decoration-none small fw-semibold text-primary">
                                        View Notification Center &rarr;
                                    </a>
                                </li>
                            </ul>
                        </div>

                        <!-- User Profile Info -->
                        <span class="text-white small">
                            Logged in as <strong><c:out value="${sessionScope.userName}"/></strong> 
                            <span class="badge ${sessionScope.userRole == 'ADMIN' ? 'bg-primary' : 'bg-info text-dark'} ms-1">
                                <c:out value="${sessionScope.userRole}"/>
                            </span>
                            &nbsp;|&nbsp; 
                            <a href="${pageContext.request.contextPath}/logout" class="text-white-50 text-decoration-none hover-white">
                                Logout
                            </a>
                        </span>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-light btn-sm me-2">Sign In</a>
                        <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-primary btn-sm">Register as Vendor</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>

<c:if test="${not empty sessionScope.userId}">
<script>
document.addEventListener('DOMContentLoaded', function() {
    fetch('${pageContext.request.contextPath}/notifications?format=json')
        .then(function(res) { return res.ok ? res.json() : null; })
        .then(function(data) {
            if (!data) return;
            var badge = document.getElementById('navbarNotifBadge');
            var list = document.getElementById('navbarNotifList');
            var loadingItem = document.getElementById('notifLoadingItem');

            if (data.unreadCount > 0) {
                badge.textContent = data.unreadCount;
                badge.classList.remove('d-none');
            } else {
                badge.classList.add('d-none');
            }

            if (loadingItem) loadingItem.remove();

            if (!data.notifications || data.notifications.length === 0) {
                var emptyLi = document.createElement('li');
                emptyLi.className = 'p-3 text-center text-muted small';
                emptyLi.textContent = 'No new notifications';
                list.insertBefore(emptyLi, list.lastElementChild);
            } else {
                data.notifications.slice(0, 5).forEach(function(n) {
                    var itemLi = document.createElement('li');
                    itemLi.className = 'border-bottom';
                    var linkTag = document.createElement('a');
                    linkTag.className = 'dropdown-item p-3 text-wrap ' + (!n.isRead ? 'bg-light' : '');
                    linkTag.href = n.link ? ('${pageContext.request.contextPath}/' + n.link) : '${pageContext.request.contextPath}/notifications';
                    
                    linkTag.innerHTML = '<div class="d-flex justify-content-between align-items-center mb-1">' +
                        '<strong class="small text-dark">' + escapeHtml(n.title) + '</strong>' +
                        (!n.isRead ? '<span class="badge bg-primary" style="font-size:0.6rem;">NEW</span>' : '') +
                        '</div>' +
                        '<p class="mb-1 text-secondary small" style="line-height:1.2;">' + escapeHtml(n.message) + '</p>' +
                        '<span class="text-muted" style="font-size:0.7rem;">' + escapeHtml(n.createdAt) + '</span>';
                    
                    itemLi.appendChild(linkTag);
                    list.insertBefore(itemLi, list.lastElementChild);
                });
            }
        })
        .catch(function() {});
});

function escapeHtml(text) {
    if (!text) return '';
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
</script>
</c:if>

<script src="${pageContext.request.contextPath}/js/tms-live.js"></script>
<jsp:include page="/WEB-INF/includes/ai-copilot.jsp" />
