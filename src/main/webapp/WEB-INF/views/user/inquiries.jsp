<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>My Inquiries – PropNexium</title>
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
                        max-width: 1100px;
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

                    .card {
                        background: white;
                        border-radius: 12px;
                        padding: 26px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.07);
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 14px;
                    }

                    thead tr {
                        background: #f8f9fa;
                    }

                    th {
                        padding: 13px 16px;
                        text-align: left;
                        font-weight: 600;
                        color: #444;
                    }

                    td {
                        padding: 13px 16px;
                        border-bottom: 1px solid #f0f0f0;
                        vertical-align: middle;
                    }

                    tr:last-child td {
                        border-bottom: none;
                    }

                    tr:hover td {
                        background: #fafbff;
                    }

                    .property-name {
                        font-weight: 600;
                        color: #222;
                    }

                    .property-city {
                        color: #888;
                        font-size: 12px;
                        margin-top: 2px;
                    }

                    .msg-preview {
                        color: #666;
                        font-size: 13px;
                        max-width: 260px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                    }

                    .reply-text {
                        padding: 6px 10px;
                        background: #f0f7ff;
                        border-left: 3px solid #1a73e8;
                        border-radius: 4px;
                        font-size: 12px;
                        color: #444;
                        margin-top: 5px;
                    }

                    .badge {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    .badge-pending {
                        background: #fff3cd;
                        color: #856404;
                    }

                    .badge-replied {
                        background: #d4edda;
                        color: #155724;
                    }

                    .badge-closed {
                        background: #f8d7da;
                        color: #721c24;
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
                        margin-bottom: 8px;
                    }

                    .empty-state a {
                        display: inline-block;
                        margin-top: 14px;
                        padding: 10px 26px;
                        background: #1a73e8;
                        color: white;
                        border-radius: 30px;
                        text-decoration: none;
                        font-weight: 600;
                    }
                </style>
            </head>

            <body>

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <div class="page-wrap">
                        <div class="page-title">📬 My Inquiries</div>
                        <div class="page-sub">All inquiries you've submitted to agents</div>

                        <div class="card">
                            <c:choose>
                                <c:when test="${empty inquiries}">
                                    <div class="empty-state">
                                        <div class="emoji">📭</div>
                                        <h3>No inquiries yet</h3>
                                        <p>Find a property and reach out to an agent.</p>
                                        <a href="/properties">Browse Properties</a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Property</th>
                                                <th>Your Message</th>
                                                <th>Agent Reply</th>
                                                <th>Date</th>
                                                <th style="text-align:center;">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="inq" items="${inquiries}">
                                                <tr>
                                                    <td>
                                                        <div class="property-name">
                                                            <a href="/properties/${inq.property.id}"
                                                                style="text-decoration:none; color:inherit;">
                                                                ${inq.property.title}
                                                            </a>
                                                        </div>
                                                        <div class="property-city">📍 ${inq.property.city}</div>
                                                    </td>
                                                    <td>
                                                        <div class="msg-preview" title="${inq.message}">${inq.message}
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty inq.agentReply}">
                                                                <div class="reply-text">${inq.agentReply}</div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#bbb; font-size:13px;">No reply
                                                                    yet</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="white-space:nowrap; color:#888; font-size:13px;">
                                                        ${inq.createdAt.dayOfMonth} ${inq.createdAt.month.toString().substring(0,1)}${inq.createdAt.month.toString().substring(1).toLowerCase()} ${inq.createdAt.year}
                                                    </td>
                                                    <td style="text-align:center;">
                                                        <c:choose>
                                                            <c:when test="${inq.status == 'PENDING'}">
                                                                <span class="badge badge-pending">⏳ Pending</span>
                                                            </c:when>
                                                            <c:when test="${inq.status == 'REPLIED'}">
                                                                <span class="badge badge-replied">✅ Replied</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-closed">🔒 Closed</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
            </body>

            </html>