<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subscribers – Admin | PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
</head>
<body>
<div class="admin-wrap">
    <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>
    <div class="main">
        <div class="topbar">
            <h1>📧 Newsletter Subscribers</h1>
            <div style="font-size:14px;color:#64748b;">${totalCount} active subscribers</div>
        </div>
        <div class="content">

            <!-- ── Stats bar ────────────────────────────────────────────────── -->
            <div style="display:flex;gap:16px;margin-bottom:24px;flex-wrap:wrap;align-items:flex-start;">
                <div style="background:white;border-radius:10px;padding:20px 28px;
                            box-shadow:0 2px 10px rgba(0,0,0,.06);
                            border-left:4px solid #1a73e8;">
                    <div style="font-size:12px;color:#64748b;margin-bottom:4px;
                                text-transform:uppercase;letter-spacing:.04em;">
                        Active Subscribers
                    </div>
                    <div style="font-size:32px;font-weight:800;color:#1e293b;">${totalCount}</div>
                </div>

                <a href="/admin/export/subscribers"
                   style="display:inline-flex;align-items:center;gap:8px;
                          padding:20px 24px;background:#22c55e;color:white;
                          text-decoration:none;border-radius:10px;font-size:14px;
                          font-weight:600;box-shadow:0 2px 8px rgba(34,197,94,.3);">
                    📊 Export Excel
                </a>
            </div>

            <!-- ── Subscribers table ─────────────────────────────────────────── -->
            <div style="background:white;border-radius:12px;overflow:hidden;
                        box-shadow:0 2px 12px rgba(0,0,0,.06);">
                <table style="width:100%;border-collapse:collapse;">
                    <thead>
                        <tr style="background:#f8fafc;">
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">
                                #
                            </th>
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">
                                Email
                            </th>
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">
                                Subscribed At
                            </th>
                            <th style="padding:14px 16px;text-align:left;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">
                                Status
                            </th>
                            <th style="padding:14px 16px;text-align:right;font-size:12px;
                                       color:#64748b;font-weight:700;text-transform:uppercase;
                                       letter-spacing:.04em;border-bottom:1px solid #e5e7eb;">
                                Actions
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty subscribers}">
                                <tr>
                                    <td colspan="4"
                                        style="text-align:center;padding:48px;color:#94a3b8;font-size:14px;">
                                        No active subscribers yet.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="s" items="${subscribers}" varStatus="vs">
                                <tr style="border-bottom:1px solid #f1f5f9;
                                           background:${vs.index % 2 == 0 ? 'white' : '#fafafa'};">
                                    <td style="padding:12px 16px;font-size:13px;color:#94a3b8;
                                               font-weight:500;">${vs.count}</td>
                                    <td style="padding:12px 16px;font-size:14px;color:#1e293b;
                                               font-weight:500;">${s.email}</td>
                                    <td style="padding:12px 16px;font-size:13px;color:#64748b;">
                                        <c:choose>
                                            <c:when test="${s.subscribedAt != null}">
                                                ${s.subscribedAt.toLocalDate()}
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="padding:12px 16px;">
                                        <span style="padding:3px 10px;border-radius:12px;
                                                     font-size:11px;font-weight:600;
                                                     background:#dcfce7;color:#16a34a;">
                                            Active
                                        </span>
                                    </td>
                                    <td style="padding:12px 16px;text-align:right;">
                                        <form action="/admin/subscribers/remove/${s.id}" method="post" style="display:inline;"
                                              onsubmit="return confirm('Remove this subscriber permanently?');">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" style="background:none;border:none;color:#dc2626;
                                                                         font-size:13px;font-weight:600;cursor:pointer;padding:0;">
                                                Remove
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
