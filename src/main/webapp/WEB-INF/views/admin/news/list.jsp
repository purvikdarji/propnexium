<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>
    <title>Manage News – Admin | PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
</head>
<body>
<div class="admin-wrap">
    <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <h1>📰 News & Updates</h1>
            <a href="/admin/news/new"
               style="display:inline-flex;align-items:center;padding:12px 20px;
                      background:#1a73e8;color:white;text-decoration:none;
                      border-radius:8px;font-size:14px;font-weight:600;
                      box-shadow:0 2px 8px rgba(26,115,232,.3);">
                + Add News Article
            </a>
        </div>
        <div class="content">

            <c:if test="${not empty successMessage}">
                <div style="background:#f0fdf4;border-left:4px solid #22c55e;
                            color:#16a34a;padding:16px;margin-bottom:24px;
                            border-radius:0 8px 8px 0;font-size:14px;font-weight:500;">
                    ${successMessage}
                </div>
            </c:if>

            <div style="background:white;border-radius:12px;overflow:hidden;
                        box-shadow:0 2px 12px rgba(0,0,0,.06);">
                <table style="width:100%;border-collapse:collapse;">
                    <thead>
                        <tr style="background:#f8fafc;">
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">Date</th>
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">Title</th>
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">Author</th>
                            <th style="padding:14px 16px;text-align:right;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty newsList}">
                                <tr>
                                    <td colspan="4" style="text-align:center;padding:48px;color:#94a3b8;font-size:14px;">
                                        No news articles published yet.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="n" items="${newsList}" varStatus="vs">
                                    <tr style="border-bottom:1px solid #f1f5f9;
                                               background:${vs.index % 2 == 0 ? 'white' : '#fafafa'};">
                                        <td style="padding:12px 16px;font-size:13px;color:#64748b;">
                                            ${n.createdAt.toLocalDate()}
                                        </td>
                                        <td style="padding:12px 16px;font-size:14px;color:#1e293b;font-weight:600;">
                                            ${n.title}
                                        </td>
                                        <td style="padding:12px 16px;font-size:13px;color:#64748b;">
                                            ${n.author}
                                        </td>
                                        <td style="padding:12px 16px;text-align:right;">
                                            <a href="/admin/news/edit/${n.id}"
                                               style="color:#1a73e8;text-decoration:none;font-size:13px;font-weight:600;margin-right:12px;">Edit</a>
                                            
                                            <form action="/admin/news/delete/${n.id}" method="post" style="display:inline;"
                                                  onsubmit="return confirm('Are you sure you want to delete this news article?');">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <button type="submit" style="background:none;border:none;color:#dc2626;
                                                                             font-size:13px;font-weight:600;cursor:pointer;padding:0;">
                                                    Delete
                                                </button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /admin-wrap -->
</body>
</html>
