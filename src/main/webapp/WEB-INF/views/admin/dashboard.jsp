<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <meta name="_csrf" content="${_csrf.token}" />
                    <meta name="_csrf_header" content="${_csrf.headerName}" />
                    <title>Admin Dashboard – PropNexium</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="/css/admin-shared.css">
                    <style>
                        /* Page-specific styles for Dashboard */
                        .stats-grid {
                            display: grid;
                            grid-template-columns: repeat(4, 1fr);
                            gap: 18px;
                            margin-bottom: 24px;
                        }

                        .stat-card {
                            background: white;
                            border-radius: 12px;
                            padding: 20px 22px;
                            box-shadow: 0 1px 6px rgba(0, 0, 0, .06);
                            border-left: 4px solid var(--accent);
                            transition: transform .15s, box-shadow .15s;
                        }

                        .stat-card:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 6px 20px rgba(0, 0, 0, .1)
                        }

                        .stat-label {
                            color: #94a3b8;
                            font-size: 11px;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: .7px;
                            margin-bottom: 8px
                        }

                        .stat-value {
                            font-size: 34px;
                            font-weight: 800;
                            color: #1e293b;
                            line-height: 1;
                            margin-bottom: 6px
                        }

                        .stat-sub {
                            color: #64748b;
                            font-size: 13px
                        }

                        .stat-link {
                            color: var(--accent);
                            font-size: 12px;
                            font-weight: 600;
                            margin-top: 4px;
                            display: block
                        }

                        /* ── Grid 2-col ── */
                        .two-col {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 18px;
                            margin-bottom: 24px
                        }

                        /* ── Pending row ── */
                        .pending-row {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 11px 0;
                            border-bottom: 1px solid #f1f5f9;
                        }

                        .pending-row:last-of-type {
                            border-bottom: none
                        }

                        .prop-title {
                            font-weight: 600;
                            font-size: 14px;
                            margin-bottom: 3px
                        }

                        .prop-meta {
                            color: #94a3b8;
                            font-size: 12px
                        }

                        .btn-approve {
                            padding: 5px 12px;
                            background: #22c55e;
                            color: white;
                            border: none;
                            border-radius: 6px;
                            cursor: pointer;
                            font-size: 12px;
                            font-weight: 600;
                        }

                        .btn-reject {
                            padding: 5px 12px;
                            background: #ef4444;
                            color: white;
                            border: none;
                            border-radius: 6px;
                            cursor: pointer;
                            font-size: 12px;
                            font-weight: 600;
                        }

                        /* ── City Bar Chart ── */
                        .city-bar {
                            margin-bottom: 14px
                        }

                        .city-bar-label {
                            display: flex;
                            justify-content: space-between;
                            font-size: 13px;
                            margin-bottom: 5px;
                        }

                        .city-bar-track {
                            background: #f1f5f9;
                            border-radius: 4px;
                            height: 8px;
                            overflow: hidden
                        }

                        .city-bar-fill {
                            background: linear-gradient(90deg, #3b82f6, #6366f1);
                            height: 8px;
                            border-radius: 4px
                        }

                        .badge-admin {
                            background: #fee2e2;
                            color: #dc2626
                        }

                        .badge-agent {
                            background: #e0f2fe;
                            color: #0284c7
                        }

                        .badge-user {
                            background: #f0fdf4;
                            color: #16a34a
                        }

                        .badge-active {
                            background: #dcfce7;
                            color: #16a34a
                        }

                        .badge-inactive {
                            background: #fef2f2;
                            color: #dc2626
                        }
                    </style>
                </head>

                <body>
                    <div class="admin-wrap">

                        <!-- ══ SIDEBAR ══ -->
                        <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>


                        <!-- ══ MAIN ══ -->
                        <div class="main">
                            <div class="topbar">
                                <h1>Platform Overview</h1>
                                <div class="topbar-user">
                                    👤
                                    <sec:authentication property="principal.fullName" />
                                    <span
                                        style="background:#3b82f6;color:white;padding:3px 10px;border-radius:10px;font-size:12px">ADMIN</span>
                                </div>
                            </div>

                            <div class="content">

                                <!-- Flash -->
                                <c:if test="${not empty successMessage}">
                                    <div class="flash flash-success">✅ ${successMessage}</div>
                                </c:if>

                                <!-- ── Stats ── -->
                                <div class="stats-grid">
                                    <div class="stat-card" style="--accent:#3b82f6">
                                        <div class="stat-label">Total Users</div>
                                        <div class="stat-value">${totalUsers}</div>
                                        <div class="stat-sub">${totalAgents} agents registered</div>
                                        <a class="stat-link" href="/admin/users">Manage →</a>
                                    </div>
                                    <div class="stat-card" style="--accent:#22c55e">
                                        <div class="stat-label">Properties</div>
                                        <div class="stat-value">${totalProperties}</div>
                                        <div class="stat-sub">${availableProperties} currently available</div>
                                        <a class="stat-link" href="/admin/properties">Manage →</a>
                                    </div>
                                    <div class="stat-card" style="--accent:#f59e0b">
                                        <div class="stat-label">Pending Review</div>
                                        <div class="stat-value">${pendingReview}</div>
                                        <div class="stat-sub"
                                            style="color:${pendingReview > 0 ? '#f59e0b' : '#64748b'}">
                                            ${pendingReview > 0 ? 'Requires your attention' : 'All clear!'}
                                        </div>
                                        <a class="stat-link" style="color:#f59e0b"
                                            href="/admin/properties?status=UNDER_REVIEW">Review now →</a>
                                    </div>
                                    <div class="stat-card" style="--accent:#8b5cf6">
                                        <div class="stat-label">Inquiries</div>
                                        <div class="stat-value">${totalInquiries}</div>
                                        <div class="stat-sub">${pendingInquiries} awaiting reply</div>
                                    </div>
                                </div>

                                <!-- ── 2 Column ── -->
                                <div class="two-col">

                                    <!-- Pending Properties -->
                                    <div class="sec-card">
                                        <div class="sec-head">
                                            <h3>⏳ Pending Approval</h3>
                                            <a href="/admin/properties?status=UNDER_REVIEW">View all →</a>
                                        </div>
                                        <c:choose>
                                            <c:when test="${empty pendingProperties.content}">
                                                <p
                                                    style="color:#94a3b8;text-align:center;padding:24px 0;font-size:14px">
                                                    ✅ No pending properties!
                                                </p>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="p" items="${pendingProperties.content}">
                                                    <div class="pending-row">
                                                        <div>
                                                            <div class="prop-title">${p.title}</div>
                                                            <div class="prop-meta">
                                                                ${p.city} · ${p.type} ·
                                                                ₹
                                                                <fmt:formatNumber value="${p.price}"
                                                                    groupingUsed="true" />
                                                            </div>
                                                        </div>
                                                        <div style="display:flex;gap:6px">
                                                            <form method="POST"
                                                                action="/admin/properties/${p.id}/approve"
                                                                style="display:inline">
                                                                <input type="hidden" name="${_csrf.parameterName}"
                                                                    value="${_csrf.token}" />
                                                                <button class="btn-approve">✓</button>
                                                            </form>
                                                            <form method="POST"
                                                                action="/admin/properties/${p.id}/reject"
                                                                style="display:inline">
                                                                <input type="hidden" name="${_csrf.parameterName}"
                                                                    value="${_csrf.token}" />
                                                                <button class="btn-reject">✗</button>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <!-- City Stats Bar Chart -->
                                    <div class="sec-card">
                                        <div class="sec-head">
                                            <h3>📍 Properties by City</h3>
                                        </div>
                                        <c:if test="${totalProperties > 0}">
                                            <c:forEach var="entry" items="${cityStats}">
                                                <div class="city-bar">
                                                    <div class="city-bar-label">
                                                        <span>${entry.key}</span>
                                                        <span style="font-weight:700">${entry.value}</span>
                                                    </div>
                                                    <div class="city-bar-track">
                                                        <div class="city-bar-fill"
                                                            style="width:${entry.value * 100 / totalProperties}%"></div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- ── Recent Users ── -->
                                <div class="sec-card">
                                    <div class="sec-head">
                                        <h3>👤 Recent Registrations</h3>
                                        <a href="/admin/users">View all →</a>
                                    </div>
                                    <table>
                                        <tr>
                                            <th>Name</th>
                                            <th>Email</th>
                                            <th>Role</th>
                                            <th>Status</th>
                                            <th>Joined</th>
                                        </tr>
                                        <c:forEach var="u" items="${recentUsers}">
                                            <tr>
                                                <td style="font-weight:600">${u.name}</td>
                                                <td style="color:#64748b">${u.email}</td>
                                                <td>
                                                    <span
                                                        class="badge badge-${u.role == 'ADMIN' ? 'admin' : (u.role == 'AGENT' ? 'agent' : 'user')}">
                                                        ${u.role}
                                                    </span>
                                                </td>
                                                <td>
                                                    <span
                                                        class="badge ${u.isActive ? 'badge-active' : 'badge-inactive'}">
                                                        ${u.isActive ? 'Active' : 'Inactive'}
                                                    </span>
                                                </td>
                                                <td style="color:#94a3b8">
                                                    ${u.createdAt.dayOfMonth}/${u.createdAt.monthValue}/${u.createdAt.year}
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </table>
                                </div>
                            </div><!-- /content -->
                        </div><!-- /main -->
                    </div><!-- /admin-wrap -->
                </body>

                </html>