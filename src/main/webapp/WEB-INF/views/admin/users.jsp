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
                    <title>Manage Users – Admin</title>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="/css/admin-shared.css">
                    <style>
                        /* Page-specific styles for User Management */
                        .toolbar {
                            display: flex;
                            gap: 10px;
                            align-items: center;
                            margin-bottom: 20px;
                            flex-wrap: wrap;
                        }

                        .search-input {
                            padding: 9px 14px;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 8px;
                            font-size: 14px;
                            font-family: inherit;
                            outline: none;
                            width: 240px;
                            transition: border-color .2s;
                        }

                        .search-input:focus {
                            border-color: #3b82f6
                        }

                        .role-select {
                            padding: 9px 14px;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 8px;
                            font-size: 14px;
                            font-family: inherit;
                            background: white;
                            outline: none;
                        }

                        .btn-filter {
                            padding: 9px 18px;
                            background: #3b82f6;
                            color: white;
                            border: none;
                            border-radius: 8px;
                            cursor: pointer;
                            font-size: 14px;
                            font-weight: 600;
                            font-family: inherit;
                        }

                        .btn-reset {
                            padding: 9px 16px;
                            border: 1.5px solid #e2e8f0;
                            border-radius: 8px;
                            color: #64748b;
                            font-size: 14px;
                            font-weight: 500;
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

                        .avatar {
                            width: 36px;
                            height: 36px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #3b82f6, #6366f1);
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            font-weight: 700;
                            color: white;
                            font-size: 14px;
                            flex-shrink: 0;
                        }

                        .user-cell {
                            display: flex;
                            align-items: center;
                            gap: 10px
                        }

                        .btn-toggle-activate {
                            padding: 5px 12px;
                            border-radius: 6px;
                            font-size: 12px;
                            font-weight: 600;
                            border: none;
                            cursor: pointer;
                            background: #dcfce7;
                            color: #16a34a;
                        }

                        .btn-toggle-deactivate {
                            padding: 5px 12px;
                            border-radius: 6px;
                            font-size: 12px;
                            font-weight: 600;
                            border: none;
                            cursor: pointer;
                            background: #fee2e2;
                            color: #dc2626;
                        }

                        .pagination {
                            display: flex;
                            gap: 6px;
                            margin-top: 20px;
                            justify-content: center
                        }

                        .pagination a,
                        .pagination span {
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            width: 36px;
                            height: 36px;
                            border-radius: 8px;
                            font-size: 14px;
                            font-weight: 500
                        }

                        .pagination a {
                            border: 1.5px solid #e2e8f0;
                            color: #334155;
                            transition: all .2s
                        }

                        .pagination a:hover {
                            background: #3b82f6;
                            color: white;
                            border-color: #3b82f6
                        }

                        .pagination .current {
                            background: #3b82f6;
                            color: white;
                            border: 1.5px solid #3b82f6
                        }

                        .results-label {
                            font-size: 13px;
                            color: #64748b;
                            margin-left: auto
                        }
                    </style>
                </head>

                <body>
                    <div class="admin-wrap">

                        <!-- Sidebar -->
                        <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>

                        <!-- Main -->
                        <div class="main">
                            <div class="topbar">
                                <h1>👥 User Management</h1>
                                <div style="font-size:14px;color:#64748b">${users.totalElements} total users</div>
                            </div>
                            <div class="content">

                                <c:if test="${not empty successMessage}">
                                    <div class="flash flash-success">✅ ${successMessage}</div>
                                </c:if>

                                <!-- Search & Filter Toolbar -->
                                <form action="/admin/users" method="GET" class="toolbar">
                                    <input type="text" name="search" class="search-input"
                                        placeholder="🔍 Search by name or email…" value="${search}">
                                    <select name="role" class="role-select">
                                        <option value="">All Roles</option>
                                        <c:forEach var="r" items="${allRoles}">
                                            <option value="${r}" ${filterRole==r.name() ? 'selected' : '' }>${r}
                                            </option>
                                        </c:forEach>
                                    </select>
                                    <button type="submit" class="btn-filter">Search</button>
                                    <a href="/admin/users" class="btn-reset">Reset</a>
                                    <span class="results-label">
                                        Showing page ${currentPage + 1} of ${totalPages > 0 ? totalPages : 1}
                                    </span>
                                </form>

                                <!-- Users Table -->
                                <div class="sec-card">
                                    <table>
                                        <tr>
                                            <th>#</th>
                                            <th>User</th>
                                            <th>Email</th>
                                            <th>Role</th>
                                            <th>Status</th>
                                            <th>Joined</th>
                                            <th>Last Active</th>
                                            <th>Searches</th>
                                            <th>Wishlist</th>
                                            <th>Actions</th>
                                        </tr>
                                        <c:choose>
                                            <c:when test="${empty users.content}">
                                                <tr>
                                                    <td colspan="7"
                                                        style="text-align:center;padding:40px;color:#94a3b8">
                                                        No users found.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="u" items="${users.content}">
                                                    <tr>
                                                        <td style="color:#94a3b8;font-size:12px">${u.id}</td>
                                                        <td>
                                                            <div class="user-cell">
                                                                <div class="avatar">
                                                                    <c:choose>
                                                                        <c:when test="${not empty u.profilePicture}">
                                                                            <img src="${u.profilePicture}"
                                                                                style="width:36px;height:36px;object-fit:cover;border-radius:50%">
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            ${u.name.charAt(0).toString().toUpperCase()}
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <span style="font-weight:600">${u.name}</span>
                                                            </div>
                                                        </td>
                                                        <td style="color:#64748b">${u.email}</td>
                                                        <td>
                                                            <span
                                                                class="badge badge-${u.role.toString().toLowerCase()}">${u.role}</span>
                                                        </td>
                                                        <td>
                                                            <span
                                                                class="badge ${u.isActive ? 'badge-active' : 'badge-inactive'}">
                                                                ${u.isActive ? '● Active' : '● Inactive'}
                                                            </span>
                                                        </td>
                                                        <td style="color:#94a3b8;font-size:13px">
                                                            ${u.createdAt.dayOfMonth}/${u.createdAt.monthValue}/${u.createdAt.year}
                                                        </td>
                                                        <td style="padding:12px 14px;font-size:13px;color:#64748b;">
                                                            <c:choose>
                                                                <c:when test="${u.lastLogin != null}">
                                                                    ${u.lastLogin.dayOfMonth} ${u.lastLogin.month.toString().substring(0,1)}${u.lastLogin.month.toString().substring(1).toLowerCase()} ${u.lastLogin.year}
                                                                </c:when>
                                                                <c:otherwise>Never</c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td style="padding:12px 14px;text-align:center;font-weight:600;color:#1a73e8;">
                                                            ${u.totalSearchesCount}
                                                        </td>
                                                        <td style="padding:12px 14px;text-align:center;font-weight:600;color:#f59e0b;">
                                                            ${wishlistCounts[u.id]}
                                                        </td>
                                                        <td>
                                                            <form method="POST"
                                                                action="/admin/users/${u.id}/toggle-status"
                                                                style="display:inline">
                                                                <input type="hidden" name="${_csrf.parameterName}"
                                                                    value="${_csrf.token}" />
                                                                <button
                                                                    class="${u.isActive ? 'btn-toggle-deactivate' : 'btn-toggle-activate'}">
                                                                    ${u.isActive ? '🚫 Deactivate' : '✅ Activate'}
                                                                </button>
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </table>
                                </div>

                                <!-- Pagination -->
                                <c:if test="${totalPages > 1}">
                                    <div class="pagination">
                                        <c:if test="${currentPage > 0}">
                                            <a href="?page=${currentPage-1}&role=${filterRole}&search=${search}">‹</a>
                                        </c:if>
                                        <c:forEach begin="0" end="${totalPages - 1}" var="i">
                                            <c:choose>
                                                <c:when test="${i == currentPage}">
                                                    <span class="current">${i + 1}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="?page=${i}&role=${filterRole}&search=${search}">${i +
                                                        1}</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                        <c:if test="${currentPage < totalPages - 1}">
                                            <a href="?page=${currentPage+1}&role=${filterRole}&search=${search}">›</a>
                                        </c:if>
                                    </div>
                                </c:if>

                            </div>
                        </div>
                    </div>
                </body>

                </html>