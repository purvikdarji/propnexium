<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>My Properties – PropNexium</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                        rel="stylesheet">
                    <style>
                        * {
                            box-sizing: border-box;
                            margin: 0;
                            padding: 0
                        }

                        body {
                            font-family: 'Inter', sans-serif;
                            background: #f8fafc;
                            color: #1e293b
                        }

                        a {
                            text-decoration: none
                        }

                        .wrap {
                            display: flex;
                            min-height: 100vh
                        }

                        .sidebar {
                            width: 230px;
                            background: #0f172a;
                            flex-shrink: 0;
                            display: flex;
                            flex-direction: column
                        }

                        .sidebar-profile {
                            text-align: center;
                            padding: 20px 12px 18px;
                            border-bottom: 1px solid #1e293b
                        }

                        .avatar-circle {
                            width: 62px;
                            height: 62px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #1a73e8, #6366f1);
                            margin: 0 auto;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 24px;
                            font-weight: 800;
                            color: white
                        }

                        .agent-name {
                            color: white;
                            font-weight: 700;
                            font-size: 14px;
                            margin-top: 10px
                        }

                        .sidebar-label {
                            padding: 14px 20px 5px;
                            color: #475569;
                            font-size: 10px;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: 1.2px
                        }

                        .sidebar a {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            padding: 11px 20px;
                            color: #94a3b8;
                            font-size: 14px;
                            font-weight: 500;
                            transition: background .15s, color .15s
                        }

                        .sidebar a:hover {
                            background: #1e293b;
                            color: #f1f5f9
                        }

                        .sidebar a.active {
                            background: #1e3a5f;
                            color: #60a5fa;
                            border-left: 3px solid #3b82f6
                        }

                        .sidebar-foot {
                            margin-top: auto;
                            border-top: 1px solid #1e293b;
                            padding: 12px 20px
                        }

                        .sidebar-foot a {
                            color: #475569;
                            font-size: 13px
                        }

                        .main {
                            flex: 1;
                            display: flex;
                            flex-direction: column
                        }

                        .topbar {
                            background: white;
                            padding: 14px 28px;
                            border-bottom: 1px solid #e2e8f0;
                            display: flex;
                            justify-content: space-between;
                            align-items: center
                        }

                        .topbar h1 {
                            font-size: 20px;
                            font-weight: 700
                        }

                        .btn-add {
                            padding: 9px 20px;
                            background: #1a73e8;
                            color: white;
                            border-radius: 7px;
                            font-size: 14px;
                            font-weight: 600;
                            display: flex;
                            align-items: center;
                            gap: 6px
                        }

                        .content {
                            padding: 24px 28px
                        }

                        .flash-ok {
                            background: #dcfce7;
                            color: #166534;
                            border-radius: 8px;
                            padding: 12px 18px;
                            margin-bottom: 18px;
                            font-size: 14px
                        }

                        .flash-err {
                            background: #fee2e2;
                            color: #dc2626;
                            border-radius: 8px;
                            padding: 12px 18px;
                            margin-bottom: 18px;
                            font-size: 14px
                        }

                        .filter-bar {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            margin-bottom: 20px;
                            flex-wrap: wrap
                        }

                        .filter-bar a {
                            padding: 7px 16px;
                            border-radius: 20px;
                            font-size: 13px;
                            font-weight: 500;
                            border: 1.5px solid #e2e8f0;
                            color: #64748b;
                            transition: all .15s
                        }

                        .filter-bar a.active,
                        .filter-bar a:hover {
                            background: #1a73e8;
                            color: white;
                            border-color: #1a73e8
                        }

                        .table-card {
                            background: white;
                            border-radius: 12px;
                            box-shadow: 0 1px 8px rgba(0, 0, 0, .07);
                            overflow: hidden
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse
                        }

                        thead {
                            background: #f8fafc
                        }

                        th {
                            padding: 12px 16px;
                            text-align: left;
                            font-size: 12px;
                            font-weight: 700;
                            color: #64748b;
                            text-transform: uppercase;
                            letter-spacing: .6px;
                            border-bottom: 1px solid #f1f5f9
                        }

                        td {
                            padding: 14px 16px;
                            font-size: 13px;
                            border-bottom: 1px solid #f8fafc;
                            color: #374151
                        }

                        tr:last-child td {
                            border-bottom: none
                        }

                        tr:hover td {
                            background: #fafbfc
                        }

                        .badge {
                            display: inline-block;
                            padding: 3px 10px;
                            border-radius: 12px;
                            font-size: 11px;
                            font-weight: 700
                        }

                        .badge-available {
                            background: #dcfce7;
                            color: #166534
                        }

                        .badge-review {
                            background: #fef9c3;
                            color: #854d0e
                        }

                        .badge-sold {
                            background: #ede9fe;
                            color: #5b21b6
                        }

                        .badge-rented {
                            background: #dbeafe;
                            color: #1e40af
                        }

                        .badge-rejected {
                            background: #fee2e2;
                            color: #dc2626
                        }

                        .actions {
                            display: flex;
                            gap: 6px
                        }

                        .btn-edit {
                            padding: 5px 12px;
                            background: #f1f5f9;
                            border-radius: 5px;
                            color: #334155;
                            font-size: 12px;
                            font-weight: 600
                        }

                        .btn-del {
                            padding: 5px 10px;
                            background: #fee2e2;
                            border-radius: 5px;
                            color: #dc2626;
                            font-size: 12px;
                            font-weight: 600;
                            border: none;
                            cursor: pointer;
                            font-family: inherit
                        }

                        .empty-state {
                            text-align: center;
                            padding: 60px 20px;
                            color: #94a3b8
                        }

                        .pagination {
                            display: flex;
                            justify-content: center;
                            gap: 6px;
                            padding: 20px
                        }

                        .pagination a {
                            padding: 7px 13px;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 6px;
                            font-size: 13px;
                            color: #64748b
                        }

                        .pagination a.active {
                            background: #1a73e8;
                            color: white;
                            border-color: #1a73e8
                        }
                    </style>
                </head>

                <body>
                    <div class="wrap">
                        <!-- SIDEBAR -->
                        <aside class="sidebar">
                            <div class="sidebar-profile">
                                <div class="avatar-circle">${fn:substring(agent.name,0,1)}</div>
                                <div class="agent-name">${agent.name}</div>
                            </div>
                            <div class="sidebar-label">Agent Panel</div>
                            <a href="/agent/dashboard">&#128202; Dashboard</a>
                            <a href="/agent/properties" class="active">&#127968; My Properties</a>
                            <a href="/agent/properties/add">&#10133; Add Property</a>
                            <a href="/agent/inquiries">&#128172; Inquiries</a>
                            <a href="/agent/bookings">&#128197; Manage Visits</a>
                            <a href="/user/notifications">&#128276; Notifications</a>
                            <a href="/agent/profile">&#128100; Profile</a>
                            <div class="sidebar-foot"><a href="/">&#8592; View Site</a></div>
                        </aside>

                        <!-- MAIN -->
                        <div class="main">
                            <div class="topbar">
                                <h1>&#127968; My Properties</h1>
                                <a href="/agent/properties/add" class="btn-add">&#43; Add Property</a>
                            </div>

                            <div class="content">
                                <a href="/pdf/agent/${agent.id}/listings"
                                    style="display:inline-flex;align-items:center;gap:6px;
                                            padding:10px 18px;background:#dc2626;color:white;
                                            text-decoration:none;border-radius:6px;font-size:13px;
                                            font-weight:600;margin-bottom:20px;">
                                    📄 Download My Listings Report
                                </a>

                                <c:if test="${not empty successMessage}">
                                    <div class="flash-ok">&#10003; ${successMessage}</div>
                                </c:if>
                                <c:if test="${not empty errorMessage}">
                                    <div class="flash-err">&#9888; ${errorMessage}</div>
                                </c:if>

                                <!-- Filter tabs -->
                                <div class="filter-bar">
                                    <a href="/agent/properties" class="${empty filterStatus ? 'active' : ''}">All</a>
                                    <c:forEach var="s" items="${allStatuses}">
                                        <a href="/agent/properties?status=${s}"
                                            class="${filterStatus == s.name() ? 'active' : ''}">${s}</a>
                                    </c:forEach>
                                </div>

                                <!-- Properties table -->
                                <div class="table-card">
                                    <c:choose>
                                        <c:when test="${properties.totalElements > 0}">
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>Title</th>
                                                        <th>City</th>
                                                        <th>Category</th>
                                                        <th>Price (&#8377;)</th>
                                                        <th>Status</th>
                                                        <th>Listed</th>
                                                        <th>PDF</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="p" items="${properties.content}">
                                                        <tr>
                                                            <td style="max-width:220px">
                                                                <a href="/properties/${p.id}"
                                                                    style="color:#1e293b;font-weight:600">
                                                                    <c:choose>
                                                                        <c:when test="${fn:length(p.title) > 45}">
                                                                            ${fn:substring(p.title,0,45)}…</c:when>
                                                                        <c:otherwise>${p.title}</c:otherwise>
                                                                    </c:choose>
                                                                </a>
                                                                <div
                                                                    style="font-size:11px;color:#94a3b8;margin-top:2px">
                                                                    ${p.type}</div>
                                                            </td>
                                                            <td>${p.city}</td>
                                                            <td>${p.category}</td>
                                                            <td>
                                                                <fmt:formatNumber value="${p.price}" type="number"
                                                                    maxFractionDigits="0" />
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${p.status == 'AVAILABLE'}"><span
                                                                            class="badge badge-available">AVAILABLE</span>
                                                                    </c:when>
                                                                    <c:when test="${p.status == 'UNDER_REVIEW'}"><span
                                                                            class="badge badge-review">UNDER
                                                                            REVIEW</span></c:when>
                                                                    <c:when test="${p.status == 'SOLD'}"><span
                                                                            class="badge badge-sold">SOLD</span>
                                                                    </c:when>
                                                                    <c:when test="${p.status == 'RENTED'}"><span
                                                                            class="badge badge-rented">RENTED</span>
                                                                    </c:when>
                                                                    <c:otherwise><span
                                                                            class="badge badge-rejected">${p.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>${p.createdAt.dayOfMonth}/${p.createdAt.monthValue}/${p.createdAt.year}
                                                            </td>
                                                            <td>
                                                              <a href="/pdf/property/${p.id}"
                                                                 style="color:#dc2626;text-decoration:none;font-size:13px;
                                                                        font-weight:600;"
                                                                 target="_blank">📄 PDF</a>
                                                            </td>
                                                            <td>
                                                                <div class="actions">
                                                                    <a href="/agent/properties/${p.id}/edit"
                                                                        class="btn-edit">Edit</a>
                                                                    <a href="/agent/properties/${p.id}/images"
                                                                        style="padding:5px 10px;background:#f0f4ff;color:#1a73e8;text-decoration:none;border-radius:4px;font-size:12px;font-weight:600;border:1px solid #c7d7fc;line-height:1.4;">&#128247; Images</a>
                                                                    <c:if test="${p.status != 'SOLD'}">
                                                                    <form action="/agent/properties/${p.id}/mark-sold"
                                                                        method="POST" style="display:inline"
                                                                        onsubmit="return confirm('Mark this property as SOLD?')">
                                                                        <input type="hidden"
                                                                            name="${_csrf.parameterName}"
                                                                            value="${_csrf.token}" />
                                                                        <button type="submit"
                                                                            style="padding:5px 12px;background:#16a34a;color:white;
                                                                                   border:none;border-radius:4px;font-size:12px;
                                                                                   cursor:pointer;font-weight:600;">
                                                                            Mark SOLD
                                                                        </button>
                                                                    </form>
                                                                    </c:if>
                                                                    <form action="/agent/properties/${p.id}/delete"
                                                                        method="POST" style="display:inline"
                                                                        onsubmit="return confirm('Remove this property from listings?')">
                                                                        <input type="hidden"
                                                                            name="${_csrf.parameterName}"
                                                                            value="${_csrf.token}" />
                                                                        <button type="submit"
                                                                            class="btn-del">Remove</button>
                                                                    </form>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                            <c:if test="${totalPages > 1}">
                                                <div class="pagination">
                                                    <c:forEach begin="0" end="${totalPages - 1}" var="pg">
                                                        <a href="/agent/properties?page=${pg}<c:if test=" ${not empty
                                                            filterStatus}">&amp;status=${filterStatus}
                                            </c:if>"
                                            class="${pg == currentPage ? 'active' : ''}">${pg + 1}</a>
                                            </c:forEach>
                                </div>
                                </c:if>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <div style="font-size:48px;margin-bottom:14px">&#127968;</div>
                                        <div style="font-size:16px;font-weight:600;color:#475569;margin-bottom:8px">No
                                            properties yet</div>
                                        <div style="font-size:14px;margin-bottom:18px">Start by listing your first
                                            property</div>
                                        <a href="/agent/properties/add"
                                            style="padding:10px 24px;background:#1a73e8;color:white;border-radius:7px;font-size:14px;font-weight:600">
                                            + Add Property
                                        </a>
                                    </div>
                                </c:otherwise>
                                </c:choose>
                            </div>

                        </div>
                    </div>
                    </div>
                </body>

                </html>