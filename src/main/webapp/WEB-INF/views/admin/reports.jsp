<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Property Reports | PropNexium Admin</title>
    <!-- CSRF Tokens for AJAX/Forms -->
    <meta name="_csrf" content="${_csrf.token}"/>
    <meta name="_csrf_header" content="${_csrf.headerName}"/>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
    
    <style>

        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            padding: 0;
            overflow: hidden;
            margin-bottom: 30px;
        }
        
        .card-header {
            padding: 20px 24px;
            border-bottom: 1px solid #e2e8f0;
            background: #f8fafc;
            font-weight: 600;
            color: #334155;
            font-size: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .badge {
            background: #ef4444;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }

        .report-grid {
            border-collapse: collapse;
            width: 100%;
            text-align: left;
        }

        .report-grid th {
            font-weight: 600;
            color: #64748b;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 24px;
            border-bottom: 1px solid #e2e8f0;
            background: #f1f5f9;
        }

        .report-grid td {
            padding: 16px 24px;
            border-bottom: 1px solid #e2e8f0;
            vertical-align: top;
            font-size: 14px;
            color: #334155;
        }

        .report-grid tr:last-child td {
            border-bottom: none;
        }

        .report-grid tr:hover {
            background: #f8fafc;
        }

        .empty-state {
            padding: 60px 20px;
            text-align: center;
            color: #64748b;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid transparent;
            text-decoration: none;
            transition: all 0.2s;
        }

        .btn-warning {
            background: #fef3c7;
            color: #d97706;
            border-color: #fde68a;
        }
        .btn-warning:hover { background: #fde68a; }

        .btn-danger {
            background: #fee2e2;
            color: #ef4444;
            border-color: #fca5a5;
        }
        .btn-danger:hover { background: #fecaca; }

        .btn-secondary {
            background: #f1f5f9;
            color: #475569;
            border-color: #cbd5e1;
        }
        .btn-secondary:hover { background: #e2e8f0; }

        .btn-group {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .reason-tag {
            display: inline-block;
            background: #e0e7ff;
            color: #4338ca;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        /* Alert Messages */
        .alert {
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-weight: 500;
        }
        .alert-success {
            background-color: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        .alert-error {
            background-color: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

    </style>
</head>
<body>

<div class="admin-wrap">
    
    <!-- Sidebar -->
    <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>

    <!-- Main Content -->
    <div class="main">
        
        <div class="topbar">
            <h1>🚩 Manage Property Reports</h1>
            <div class="topbar-user">
                👤
                <sec:authentication property="principal.fullName" />
                <span style="background:#3b82f6;color:white;padding:3px 10px;border-radius:10px;font-size:12px">ADMIN</span>
            </div>
        </div>
        
        <div class="content">

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                ✅ ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-error">
                ❌ ${errorMessage}
            </div>
        </c:if>

        <!-- PENDING REPORTS -->
        <div class="card">
            <div class="card-header">
                <div>Needs Attention</div>
                <c:if test="${pendingCount > 0}">
                    <span class="badge">${pendingCount} Pending</span>
                </c:if>
            </div>
            
            <c:choose>
                <c:when test="${empty pendingReports}">
                    <div class="empty-state">
                        <div style="font-size: 40px; margin-bottom: 16px;">✨</div>
                        <h3 style="margin: 0 0 8px; color: #1e293b;">All caught up!</h3>
                        <p style="margin: 0;">There are no new property reports to review.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="report-grid">
                        <thead>
                            <tr>
                                <th style="width: 25%;">Property & Reporter</th>
                                <th style="width: 40%;">Report Details</th>
                                <th style="width: 15%;">Date & Time</th>
                                <th style="width: 20%;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${pendingReports}">
                                <tr>
                                    <td>
                                        <div style="font-weight: 600; color: #1e293b; margin-bottom: 4px;">
                                            <a href="/properties/${r.property.id}" target="_blank" style="color: #1a73e8; text-decoration: none;">
                                                ${r.property.title} ↗
                                            </a>
                                        </div>
                                        <div style="color: #64748b; font-size: 13px; margin-bottom: 10px;">ID: #${r.property.id} &bull; Agent: ${r.property.agent.name}</div>
                                        
                                        <div style="font-size: 12px; color: #94a3b8; text-transform: uppercase; font-weight: 600; margin-bottom: 2px;">Reported By:</div>
                                        <div style="color: #475569; font-size: 13px;">${r.reporter.name} (${r.reporter.email})</div>
                                    </td>
                                    <td>
                                        <span class="reason-tag">${r.reason}</span>
                                        <p style="margin: 0; color: #334155; line-height: 1.5; font-size: 13px;">
                                            <c:choose>
                                                <c:when test="${empty r.description}">
                                                    <em style="color:#94a3b8;">No additional details provided.</em>
                                                </c:when>
                                                <c:otherwise>
                                                    "${r.description}"
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                    </td>
                                    <td>
                                        <div style="color: #1e293b; font-weight: 500;">
                                            ${r.createdAt.dayOfMonth} ${r.createdAt.month.toString().substring(0,3)} ${r.createdAt.year}
                                        </div>
                                        <div style="color: #64748b; font-size: 13px;">
                                            <fmt:formatDate value="${java.sql.Timestamp.valueOf(r.createdAt)}" pattern="hh:mm a"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="btn-group">
                                            <form action="/admin/reports/${r.id}/under-review" method="post">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <button type="submit" class="btn btn-warning" title="Hide listing and email agent">
                                                    👁️ Put Under Review
                                                </button>
                                            </form>
                                            <form action="/admin/reports/${r.id}/dismiss" method="post" onsubmit="return confirm('Dismiss this report as invalid?');">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <button type="submit" class="btn btn-secondary">
                                                    ❌ Dismiss
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- UNDER REVIEW REPORTS -->
        <c:if test="${not empty underReviewReports}">
        <div class="card">
            <div class="card-header">
                <div>Currently Under Review (Hidden from Public)</div>
            </div>
            <table class="report-grid">
                <thead>
                    <tr>
                        <th style="width: 25%;">Property details</th>
                        <th style="width: 40%;">Reason</th>
                        <th style="width: 35%;">Resolution Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${underReviewReports}">
                        <tr>
                            <td>
                                <div style="font-weight: 600; color: #1e293b; margin-bottom: 4px;">
                                    ${r.property.title}
                                </div>
                                <div style="color: #64748b; font-size: 13px;">ID: #${r.property.id}</div>
                            </td>
                            <td>
                                <span class="reason-tag">${r.reason}</span>
                            </td>
                            <td>
                                <div class="btn-group">
                                    <form action="/admin/reports/${r.id}/dismiss" method="post" onsubmit="return confirm('Restore this listing?');">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="btn btn-secondary">
                                            ✅ Clear & Restore Listing
                                        </button>
                                    </form>
                                    <form action="/admin/reports/${r.id}/remove" method="post" onsubmit="return confirm('Permanently remove this listing from the platform? This cannot be undone.');">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="btn btn-danger">
                                            🗑️ Remove Listing
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        </c:if>

        </div><!-- /content -->
    </div><!-- /main -->
</div><!-- /admin-wrap -->

</body>
</html>
