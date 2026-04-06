<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Notifications – PropNexium</title>
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    body {
                        font-family: 'Segoe UI', sans-serif;
                        background: #f0f2f5;
                    }

                    .page-wrap {
                        max-width: 800px;
                        margin: 0 auto;
                        padding: 30px 20px;
                    }

                    .page-title {
                        font-size: 22px;
                        font-weight: 700;
                        color: #222;
                        margin-bottom: 6px;
                    }

                    .page-sub {
                        color: #888;
                        font-size: 14px;
                        margin-bottom: 28px;
                    }

                    .notif-list {
                        display: flex;
                        flex-direction: column;
                        gap: 12px;
                    }

                    .notif {
                        background: white;
                        border-radius: 12px;
                        padding: 18px 20px;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
                        display: flex;
                        gap: 16px;
                        align-items: flex-start;
                        border-left: 4px solid transparent;
                        transition: box-shadow .2s;
                    }

                    .notif:hover {
                        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.1);
                    }

                    .notif.unread {
                        border-left-color: #1a73e8;
                        background: #f7fbff;
                    }

                    .notif.read {
                        border-left-color: #ddd;
                    }

                    .icon {
                        font-size: 24px;
                        min-width: 36px;
                        text-align: center;
                        padding-top: 2px;
                    }

                    .body {
                        flex: 1;
                    }

                    .notif-title {
                        font-weight: 600;
                        font-size: 15px;
                        color: #222;
                        margin-bottom: 4px;
                    }

                    .notif.unread .notif-title {
                        color: #1a73e8;
                    }

                    .notif-msg {
                        font-size: 13px;
                        color: #555;
                        line-height: 1.5;
                        margin-bottom: 6px;
                    }

                    .notif-meta {
                        font-size: 12px;
                        color: #aaa;
                    }

                    .unread-dot {
                        width: 9px;
                        height: 9px;
                        border-radius: 50%;
                        background: #1a73e8;
                        margin-top: 7px;
                        flex-shrink: 0;
                    }

                    .notif-link {
                        display: inline-block;
                        margin-top: 6px;
                        font-size: 13px;
                        color: #1a73e8;
                        text-decoration: none;
                    }

                    .type-inquiry {
                        background: #e8f0fe;
                    }

                    .type-reply {
                        background: #e8f5e9;
                    }

                    .type-wishlist {
                        background: #fce4ec;
                    }

                    .type-property_status {
                        background: #fff8e1;
                    }

                    .type-system {
                        background: #f3f3f3;
                    }

                    .empty-state {
                        text-align: center;
                        padding: 80px 20px;
                        color: #aaa;
                    }

                    .empty-state .emoji {
                        font-size: 56px;
                        margin-bottom: 16px;
                    }

                    .empty-state h3 {
                        font-size: 19px;
                        color: #555;
                        margin-bottom: 6px;
                    }
                </style>
            </head>

            <body>

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <div class="page-wrap">
                        <div class="page-title"> Notifications</div>
                        <div class="page-sub">All notifications are marked read when you open this page</div>

                        <c:choose>
                            <c:when test="${empty notifications}">
                                <div class="empty-state">
                                    <div class="emoji">🔕</div>
                                    <h3>No notifications yet</h3>
                                    <p>You'll be notified about your inquiries, wishlists, and more.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="notif-list">
                                    <c:forEach var="n" items="${notifications}">
                                        <div class="notif ${n.isRead ? 'read' : 'unread'}">

                                            <!-- Icon by type -->
                                            <div class="icon">
                                                <c:choose>
                                                    <c:when test="${n.type == 'INQUIRY'}">📬</c:when>
                                                    <c:when test="${n.type == 'REPLY'}">💬</c:when>
                                                    <c:when test="${n.type == 'WISHLIST'}">❤️</c:when>
                                                    <c:when test="${n.type == 'PROPERTY_STATUS'}">🏠</c:when>
                                                    <c:otherwise>🔔</c:otherwise>
                                                </c:choose>
                                            </div>

                                            <!-- Content -->
                                            <div class="body">
                                                <div class="notif-title">${n.title}</div>
                                                <div class="notif-msg">${n.message}</div>
                                                <div class="notif-meta">
                                                    ${n.createdAt.dayOfMonth} ${n.createdAt.month.toString().substring(0,1)}${n.createdAt.month.toString().substring(1).toLowerCase()} ${n.createdAt.year}, ${n.createdAt.hour > 12 ? n.createdAt.hour - 12 : (n.createdAt.hour == 0 ? 12 : n.createdAt.hour)}:${n.createdAt.minute < 10 ? '0' : ''}${n.createdAt.minute} ${n.createdAt.hour >= 12 ? 'PM' : 'AM'}
                                                    &nbsp;·&nbsp;
                                                    <c:choose>
                                                        <c:when test="${n.type == 'INQUIRY'}">Inquiry</c:when>
                                                        <c:when test="${n.type == 'REPLY'}">Agent Reply</c:when>
                                                        <c:when test="${n.type == 'WISHLIST'}">Wishlist</c:when>
                                                        <c:when test="${n.type == 'PROPERTY_STATUS'}">Property Update
                                                        </c:when>
                                                        <c:otherwise>System</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <c:if test="${not empty n.link}">
                                                    <a href="${n.link}" class="notif-link">View details →</a>
                                                </c:if>
                                            </div>

                                            <!-- Unread indicator dot -->
                                            <c:if test="${!n.isRead}">
                                                <div class="unread-dot" title="Unread"></div>
                                            </c:if>

                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
            </body>

            </html>