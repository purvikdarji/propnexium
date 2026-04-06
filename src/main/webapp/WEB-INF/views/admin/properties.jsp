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
    <title>Manage Properties – Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/css/admin-shared.css">
    <style>
        /* Page-specific styles for Properties */
        .toolbar {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap
        }

        .status-tabs {
            display: flex;
            gap: 0;
            border: 1.5px solid #e2e8f0;
            border-radius: 8px;
            overflow: hidden
        }

        .status-tab {
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 500;
            color: #64748b;
            background: white;
            transition: background .15s;
            white-space: nowrap;
        }

        .status-tab.active {
            background: #3b82f6;
            color: white
        }

        .status-tab:hover:not(.active) {
            background: #f1f5f9
        }

        .badge-available { background: #dcfce7; color: #16a34a }
        .badge-under_review { background: #fef9c3; color: #854d0e }
        .badge-sold { background: #e0f2fe; color: #0284c7 }
        .badge-rejected { background: #fee2e2; color: #dc2626 }
        .badge-rented { background: #f3e8ff; color: #7e22ce }

        .action-btn {
            padding: 5px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            border: none;
            cursor: pointer
        }

        .btn-approve { background: #22c55e; color: white }
        .btn-reject { background: #ef4444; color: white }
        .btn-view { background: #f1f5f9; color: #334155 }

        .feat-btn {
            padding: 5px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            border: 1.5px solid #e2e8f0;
            cursor: pointer;
            transition: all .2s;
            background: white;
        }

        .feat-btn.on { background: #fef9c3; border-color: #fbbf24; color: #854d0e }

        .pagination {
            display: flex;
            gap: 6px;
            margin-top: 20px;
            justify-content: center
        }

        .pagination a, .pagination span {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 8px;
            font-size: 14px;
            text-decoration: none;
            font-weight: 500
        }

        .pagination a { border: 1.5px solid #e2e8f0; color: #334155 }
        .pagination a:hover { background: #3b82f6; color: white; border-color: #3b82f6 }
        .pagination .current { background: #3b82f6; color: white; border: 1.5px solid #3b82f6 }

        #toast {
            position: fixed;
            bottom: 28px;
            right: 28px;
            padding: 12px 22px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            color: white;
            z-index: 9999;
            display: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, .18);
            animation: slideIn .3s ease
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(16px) }
            to { opacity: 1; transform: translateY(0) }
        }
    </style>
</head>

<body>
    <div class="admin-wrap">
        <%@ include file="/WEB-INF/views/admin/sidebar.jsp" %>
        <div class="main">
            <div class="topbar">
                <h1>🏠 Property Management</h1>
                <div style="font-size:14px;color:#64748b">${properties.totalElements} total properties</div>
            </div>
            <div class="content">
                <c:if test="${not empty successMessage}">
                    <div class="flash flash-success">✅ ${successMessage}</div>
                </c:if>

                <!-- Bulk Action Bar (visible when rows are selected) -->
                <div id="bulkActionBar"
                     style="display:none;background:#1e293b;padding:12px 20px;border-radius:8px;
                            margin-bottom:16px;flex-wrap:wrap;align-items:center;gap:12px;">
                  <span id="selectedCount" style="color:white;font-size:13px;font-weight:600;">0 selected</span>

                  <form id="bulkApproveForm" method="POST" action="/admin/properties/bulk-approve" style="margin:0;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <div id="bulkApproveIds"></div>
                    <button type="submit"
                      style="padding:8px 18px;background:#22c55e;color:white;border:none;
                             border-radius:6px;font-size:13px;font-weight:600;cursor:pointer;">
                      ✓ Approve Selected
                    </button>
                  </form>

                  <form id="bulkRejectForm" method="POST" action="/admin/properties/bulk-reject" style="margin:0;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <div id="bulkRejectIds"></div>
                    <button type="submit"
                      style="padding:8px 18px;background:#dc2626;color:white;border:none;
                             border-radius:6px;font-size:13px;font-weight:600;cursor:pointer;">
                      ✗ Reject Selected
                    </button>
                  </form>

                  <button onclick="clearSelections()"
                    style="padding:8px 14px;background:transparent;color:#94a3b8;
                           border:1px solid #475569;border-radius:6px;font-size:13px;cursor:pointer;">
                    Cancel
                  </button>
                </div>

                <!-- ── Excel Export Bar ─────────────────────────────────────────── -->
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:16px;flex-wrap:wrap;">
                    <a href="/admin/export/properties"
                       style="display:inline-flex;align-items:center;gap:6px;
                              padding:10px 18px;background:#22c55e;color:white;
                              text-decoration:none;border-radius:6px;
                              font-size:13px;font-weight:600;
                              box-shadow:0 2px 8px rgba(34,197,94,.3);
                              transition:background .2s;">
                        📊 Export Excel
                    </a>
                    <span style="font-size:13px;color:#64748b;font-weight:500;">Filter by status:</span>
                    <select id="exportStatusFilter"
                            onchange="if(this.value!=='__none__'){window.location='/admin/export/properties?status='+this.value}"
                            style="padding:9px 12px;border:1px solid #d1d5db;border-radius:6px;
                                   font-size:13px;background:white;cursor:pointer;
                                   color:#374151;outline:none;">
                        <option value="__none__">— choose status to export —</option>
                        <option value="AVAILABLE">Available</option>
                        <option value="SOLD">Sold</option>
                        <option value="RENTED">Rented</option>
                        <option value="UNDER_REVIEW">Under Review</option>
                        <option value="REJECTED">Rejected</option>
                    </select>
                </div>

                <!-- Status Filter Tabs -->
                <div class="toolbar">
                    <div class="status-tabs">
                        <a href="/admin/properties" class="status-tab ${empty filterStatus ? 'active' : ''}">All</a>
                        <c:forEach var="s" items="${allStatuses}">
                            <a href="/admin/properties?status=${s}" class="status-tab ${filterStatus == s.name() ? 'active' : ''}">
                                ${s}
                            </a>
                        </c:forEach>
                    </div>
                </div>

                <!-- Table -->
                <div class="sec-card">
                    <table>
                        <tr>
                            <th style="padding:12px;width:40px;">
                                <input type="checkbox" id="selectAll" onchange="toggleSelectAll(this)" />
                            </th>
                            <th>#</th>
                            <th>Title</th>
                            <th>Agent</th>
                            <th>City / Type</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Featured</th>
                            <th>Actions</th>
                        </tr>
                        <c:choose>
                            <c:when test="${empty properties.content}">
                                <tr>
                                    <td colspan="8" style="text-align:center;padding:40px;color:#94a3b8">
                                        No properties found for this filter.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="p" items="${properties.content}" varStatus="st">
                                    <tr id="row_${p.id}">
                                        <td style="padding:12px;">
                                            <input type="checkbox" class="propertyCheckbox"
                                                   value="${p.id}" onchange="updateBulkBar()"/>
                                        </td>
                                        <td style="color:#94a3b8;font-size:12px">${p.id}</td>
                                        <td style="font-weight:600;max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="${p.title}">
                                            ${p.title}
                                        </td>
                                        <td style="color:#64748b;font-size:13px">
                                            <c:choose>
                                                <c:when test="${p.agent != null}">${p.agent.name}</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="color:#64748b;font-size:13px">${p.city} · ${p.type}</td>
                                        <td style="font-weight:600;color:#1e293b">
                                            ₹ <fmt:formatNumber value="${p.price}" groupingUsed="true" />
                                        </td>
                                        <td>
                                            <span class="badge badge-${p.status.toString().toLowerCase()}">${p.status}</span>
                                        </td>
                                        <td>
                                            <button class="feat-btn ${p.isFeatured ? 'on' : ''}" id="feat-${p.id}" onclick="toggleFeatured(${p.id})">
                                                ${p.isFeatured ? '⭐ Yes' : '☆ No'}
                                            </button>
                                        </td>
                                        <td>
                                            <div style="display:flex;gap:6px;flex-wrap:wrap">
                                                <a href="/properties/${p.id}" target="_blank" class="action-btn btn-view">View</a>
                                                <c:if test="${p.status == 'UNDER_REVIEW'}">
                                                    <form method="POST" action="/admin/properties/${p.id}/approve" style="display:inline">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        <button class="action-btn btn-approve">✓ Approve</button>
                                                    </form>
                                                    <form method="POST" action="/admin/properties/${p.id}/reject" style="display:inline">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        <button class="action-btn btn-reject">✗ Reject</button>
                                                    </form>
                                                </c:if>
                                            </div>
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
                            <a href="?page=${currentPage-1}&status=${filterStatus}">‹</a>
                        </c:if>
                        <c:forEach begin="0" end="${totalPages - 1}" var="i">
                            <c:choose>
                                <c:when test="${i == currentPage}"><span class="current">${i+1}</span></c:when>
                                <c:otherwise><a href="?page=${i}&status=${filterStatus}">${i+1}</a></c:otherwise>
                            </c:choose>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages - 1}">
                            <a href="?page=${currentPage+1}&status=${filterStatus}">›</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <div id="toast"></div>
    <script>
        const CSRF_TOKEN = document.querySelector("meta[name='_csrf']").content;
        const CSRF_HEADER = document.querySelector("meta[name='_csrf_header']").content;

        function showToast(msg, ok) {
            const t = document.getElementById('toast');
            t.textContent = msg;
            t.style.background = ok ? '#22c55e' : '#ef4444';
            t.style.display = 'block';
            clearTimeout(t._t);
            t._t = setTimeout(() => t.style.display = 'none', 3000);
        }

        function toggleFeatured(id) {
            fetch('/admin/properties/' + id + '/toggle-featured', {
                method: 'POST',
                headers: { [CSRF_HEADER]: CSRF_TOKEN }
            })
                .then(r => r.json())
                .then(d => {
                    const btn = document.getElementById('feat-' + id);
                    if (d.featured) {
                        btn.textContent = '⭐ Yes';
                        btn.classList.add('on');
                    } else {
                        btn.textContent = '☆ No';
                        btn.classList.remove('on');
                    }
                    showToast(d.message, true);
                })
                .catch(() => showToast('Error toggling featured status', false));
        }

        // ── Bulk Select JS ──────────────────────────────────────────────────
        function toggleSelectAll(masterCb) {
            document.querySelectorAll('.propertyCheckbox').forEach(cb => {
                cb.checked = masterCb.checked;
            });
            updateBulkBar();
        }

        function updateBulkBar() {
            const checked = document.querySelectorAll('.propertyCheckbox:checked');
            const all = document.querySelectorAll('.propertyCheckbox');
            const bar = document.getElementById('bulkActionBar');
            const counter = document.getElementById('selectedCount');
            const selectAll = document.getElementById('selectAll');

            if (selectAll) {
                selectAll.indeterminate = checked.length > 0 && checked.length < all.length;
                selectAll.checked = all.length > 0 && checked.length === all.length;
            }

            if (checked.length > 0) {
                bar.style.display = 'flex';
                counter.textContent = checked.length + ' selected';
                const ids = Array.from(checked).map(cb => cb.value);
                document.getElementById('bulkApproveIds').innerHTML =
                    ids.map(id => '<input type="hidden" name="ids" value="' + id + '"/>').join('');
                document.getElementById('bulkRejectIds').innerHTML =
                    ids.map(id => '<input type="hidden" name="ids" value="' + id + '"/>').join('');
            } else {
                bar.style.display = 'none';
            }
        }

        function clearSelections() {
            document.querySelectorAll('.propertyCheckbox').forEach(cb => cb.checked = false);
            const sa = document.getElementById('selectAll');
            if (sa) { sa.checked = false; sa.indeterminate = false; }
            updateBulkBar();
        }
    </script>
</body>
</html>