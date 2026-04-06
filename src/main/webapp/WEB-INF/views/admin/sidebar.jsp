<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<aside class="sidebar">
    <div class="sidebar-brand">🏠 PropNexium</div>
    <div class="sidebar-label">Main Menu</div>

    <a href="/admin/dashboard" class="${pageContext.request.requestURI.endsWith('dashboard.jsp') or pageContext.request.requestURI eq '/admin/dashboard' ? 'active' : ''}">📊 Dashboard</a>

    <a href="/admin/analytics" class="${pageContext.request.requestURI.contains('analytics') ? 'active' : ''}">📊 Analytics</a>

    <a href="/admin/properties" class="${pageContext.request.requestURI.contains('properties') ? 'active' : ''}">
        🏠 Properties
        <c:if test="${pendingReview > 0}">
            <span class="badge-pill">${pendingReview}</span>
        </c:if>
    </a>

    <a href="/admin/reports" class="${pageContext.request.requestURI.contains('reports') ? 'active' : ''}">
        🚩 Reports
        <c:if test="${not empty pendingReportCount && pendingReportCount > 0}">
            <span class="badge-pill" style="background:#ef4444;">${pendingReportCount}</span>
        </c:if>
    </a>

    <a href="/admin/users" class="${pageContext.request.requestURI.contains('users') ? 'active' : ''}">👥 Users</a>

    <a href="/admin/performance" class="${pageContext.request.requestURI.contains('performance') ? 'active' : ''}">📈 Performance</a>

    <a href="/admin/subscribers" class="${pageContext.request.requestURI.contains('subscribers') ? 'active' : ''}">📧 Subscribers</a>

    <a href="/admin/news" class="${pageContext.request.requestURI.contains('news') ? 'active' : ''}">📰 News & Updates</a>
    <a href="/admin/blog" class="${pageContext.request.requestURI.contains('blog') ? 'active' : ''}">📝 Manage Blog</a>

    <a href="/user/notifications" class="${pageContext.request.requestURI.contains('notifications') ? 'active' : ''}">🔔 Notifications</a>

    <a href="/properties">🔍 Browse Site</a>

    <div class="sidebar-footer">
        <a href="/auth/logout">🚪 Sign Out</a>
    </div>
</aside>