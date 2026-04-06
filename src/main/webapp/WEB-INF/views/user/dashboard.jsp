<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <meta name="_csrf" content="${_csrf.token}" />
                <meta name="_csrf_header" content="${_csrf.headerName}" />
                <title>My Dashboard – PropNexium</title>
                <style>
                    * {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    body {
                        font-family: 'Segoe UI', sans-serif;
                        background: #f0f2f5;
                        color: #222;
                    }

                    .page-wrap {
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 30px 20px;
                    }

                    /* Welcome banner */
                    .banner {
                        background: linear-gradient(135deg, #1a73e8, #0d47a1);
                        color: white;
                        border-radius: 14px;
                        padding: 30px 35px;
                        margin-bottom: 28px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                    }

                    .banner h2 {
                        font-size: 24px;
                        margin-bottom: 6px;
                    }

                    .banner p {
                        opacity: 0.85;
                        font-size: 13px;
                    }

                    .avatar-circle {
                        width: 72px;
                        height: 72px;
                        border-radius: 50%;
                        border: 3px solid white;
                        object-fit: cover;
                    }

                    .avatar-placeholder {
                        width: 72px;
                        height: 72px;
                        border-radius: 50%;
                        background: rgba(255, 255, 255, 0.25);
                        border: 3px solid white;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 30px;
                        font-weight: 700;
                        color: white;
                    }

                    /* Stats */
                    .stats-row {
                        display: grid;
                        grid-template-columns: repeat(3, 1fr);
                        gap: 20px;
                        margin-bottom: 28px;
                    }

                    .stat-card {
                        background: white;
                        border-radius: 12px;
                        padding: 24px 20px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                        text-align: center;
                    }

                    .stat-card .count {
                        font-size: 38px;
                        font-weight: 700;
                    }

                    .stat-card .label {
                        color: #666;
                        margin: 6px 0 8px;
                        font-size: 14px;
                    }

                    .stat-card a {
                        color: #1a73e8;
                        font-size: 13px;
                        text-decoration: none;
                    }

                    /* Section cards */
                    .card {
                        background: white;
                        border-radius: 12px;
                        padding: 26px;
                        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
                        margin-bottom: 24px;
                    }

                    .card-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 20px;
                    }

                    .card-header h3 {
                        font-size: 17px;
                    }

                    .card-header a {
                        color: #1a73e8;
                        text-decoration: none;
                        font-size: 13px;
                    }

                    /* Wishlist grid */
                    .plist {
                        display: grid;
                        grid-template-columns: repeat(4, 1fr);
                        gap: 15px;
                    }

                    .pcard {
                        border: 1px solid #eee;
                        border-radius: 10px;
                        overflow: hidden;
                        transition: box-shadow .2s;
                        text-decoration: none;
                        color: inherit;
                    }

                    .pcard:hover {
                        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
                    }

                    .pcard .thumb {
                        height: 120px;
                        background: #f1f5f9;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 32px;
                        overflow: hidden;
                        position: relative;
                    }

                    .pcard .thumb img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                        transition: transform 0.3s;
                    }

                    .pcard:hover .thumb img {
                        transform: scale(1.1);
                    }

                    .pcard .info {
                        padding: 10px 12px;
                    }

                    .pcard .title {
                        font-weight: 600;
                        font-size: 13px;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        margin-bottom: 3px;
                    }

                    .pcard .price {
                        color: #1a73e8;
                        font-size: 12px;
                        margin-bottom: 2px;
                    }

                    .pcard .city {
                        color: #888;
                        font-size: 11px;
                    }

                    /* Table */
                    .inq-table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 14px;
                    }

                    .inq-table th {
                        background: #f8f9fa;
                        padding: 11px 14px;
                        text-align: left;
                        font-weight: 600;
                        color: #444;
                    }

                    .inq-table td {
                        padding: 11px 14px;
                        border-bottom: 1px solid #f0f0f0;
                    }

                    .badge {
                        display: inline-block;
                        padding: 3px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 500;
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

                    .empty-msg {
                        color: #aaa;
                        text-align: center;
                        padding: 30px 0;
                    }
                </style>
            </head>

            <body>

                <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

                    <div class="page-wrap">

                        <!-- Welcome Banner -->
                        <div class="banner">
                            <div>
                                <h2>Welcome back, ${user.name}! 👋</h2>
                                <p>Member since ${memberSince}</p>
                            </div>
                            
                            <c:if test="${user.profilePicture != null}">
                                <img src="${user.profilePicture}" alt="Avatar" class="avatar-circle">
                            </c:if>
                            <c:if test="${user.profilePicture == null}">
                                <div class="avatar-placeholder">
                                    ${user.name.substring(0,1)}
                                </div>
                            </c:if>
                        </div>

                        <!-- Unverified Email Banner -->
                        <c:if test="${not user.isEmailVerified}">
                        <div style="background:#fffbeb;border:1px solid #fde68a;border-radius:12px;padding:16px 24px;margin-bottom:28px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 8px rgba(245,158,11,0.1);">
                            <div style="display:flex;align-items:center;gap:12px;">
                                <div style="font-size:24px;">⚠️</div>
                                <div>
                                    <h4 style="color:#92400e;margin:0 0 4px;font-size:15px;font-weight:600;">Please verify your email address</h4>
                                    <p style="color:#b45309;margin:0;font-size:13px;">Check your inbox (or spam folder) for the verification link to secure your account.</p>
                                </div>
                            </div>
                            <form action="/user/resend-verification" method="post" style="margin:0;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                <button type="submit" style="background:#f59e0b;color:white;border:none;padding:8px 16px;border-radius:6px;font-size:13px;font-weight:600;cursor:pointer;transition:background 0.2s;">
                                    Resend Email
                                </button>
                            </form>
                        </div>
                        </c:if>


                        <!-- Stats Row -->
                        <div class="stats-row">
                            <div class="stat-card">
                                <div class="count" style="color:#1a73e8;">${wishlistCount}</div>
                                <div class="label">Saved Properties</div>
                                <a href="/user/wishlist">View all →</a>
                            </div>
                            <div class="stat-card">
                                <div class="count" style="color:#ff6b35;">${inquiryCount}</div>
                                <div class="label">Inquiries Sent</div>
                                <a href="/user/inquiries">View all →</a>
                            </div>
                            <div class="stat-card">
                                <div class="count" style="color:#28a745;">${unreadNotifications}</div>
                                <div class="label">Unread Notifications</div>
                                <a href="/user/notifications">View all →</a>
                            </div>
                        </div>

                        <!-- Saved Searches -->
                        <div class="card" style="margin-bottom:24px;">
                            <div class="card-header">
                                <h3>🔖 Saved Searches</h3>
                            </div>
                            
                            <c:if test="${empty savedSearches}">
                              <p class="empty-msg" style="padding:20px 0;">
                                No saved searches yet. Search for properties and click
                                "Save This Search" to save your filters.
                              </p>
                            </c:if>
                            
                            <c:forEach var="ss" items="${savedSearches}">
                            <div style="display:flex;align-items:center;gap:12px;
                                        padding:12px 0;border-bottom:1px solid #f1f5f9;">
                              <div style="flex:1;">
                                <div style="font-size:14px;font-weight:600;color:#1e293b;
                                            margin-bottom:4px;">
                                  ${ss.name}
                                </div>
                                <!-- Filter summary chips -->
                                <div style="display:flex;gap:6px;flex-wrap:wrap;">
                                  <c:forEach var="label"
                                             items="${savedSearchLabels[ss.id]}">
                                    <span style="background:#f1f5f9;color:#64748b;
                                                 padding:2px 8px;border-radius:10px;
                                                 font-size:11px;">${label}</span>
                                  </c:forEach>
                                </div>
                                <div style="font-size:11px;color:#94a3b8;margin-top:4px;">
                                  Saved ${ss.createdAt.dayOfMonth} ${ss.createdAt.month.toString().substring(0,1)}${ss.createdAt.month.toString().substring(1).toLowerCase()} ${ss.createdAt.year}
                                </div>
                              </div>
                              
                              <!-- Re-run button -->
                              <a href="${savedSearchUrls[ss.id]}"
                                 style="padding:7px 14px;background:#1a73e8;color:white;
                                        text-decoration:none;border-radius:6px;
                                        font-size:12px;font-weight:600;white-space:nowrap;">
                                ▶ Re-run
                              </a>
                              
                              <!-- Delete button -->
                              <button type="button" onclick="deleteSavedSearch(${ss.id})"
                                style="padding:7px 12px;background:#fee2e2;color:#dc2626;
                                       border:none;border-radius:6px;font-size:12px;
                                       font-weight:600;cursor:pointer;" title="Delete">
                                🗑
                              </button>
                            </div>
                            </c:forEach>
                        </div>

                        <!-- Saved Properties Preview -->
                        <div class="card">
                            <div class="card-header">
                                <h3>Recently Saved Properties</h3>
                                <a href="/user/wishlist">View all ${wishlistCount} →</a>
                            </div>
                            <c:choose>
                                <c:when test="${empty recentWishlist}">
                                    <p class="empty-msg">
                                        No saved properties yet. <a href="/properties">Browse Properties →</a>
                                    </p>
                                </c:when>
                                <c:otherwise>
                                    <div class="plist">
                                        <c:forEach var="item" items="${recentWishlist}">
                                            <a href="/properties/${item.property.id}" class="pcard">
                                                <div class="thumb">
                                                    <c:choose>
                                                        <c:when test="${not empty item.property.images}">
                                                            <img src="${pageContext.request.contextPath}${item.property.images[0].imageUrl}" 
                                                                 alt="${item.property.title}"
                                                                 onerror="this.src='https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80';">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80" 
                                                                 alt="Property Placeholder" 
                                                                 style="filter: grayscale(0.2); opacity: 0.9;">
                                                            <div style="position:absolute; inset:0; display:flex; align-items:center; justify-content:center; font-size:32px; background:rgba(0,0,0,0.05);">🏠</div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="info">
                                                    <div class="title">${item.property.title}</div>
                                                    <div class="price">
                                                        ₹
                                                        <fmt:formatNumber value="${item.property.price}"
                                                            groupingUsed="true" />
                                                    </div>
                                                    <div class="city">📍 ${item.property.city}</div>
                                                </div>
                                            </a>
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Recent Inquiries -->
                        <div class="card">
                            <div class="card-header">
                                <h3>Recent Inquiries</h3>
                                <a href="/user/inquiries">View all →</a>
                            </div>
                            <c:choose>
                                <c:when test="${empty recentInquiries}">
                                    <p class="empty-msg">No inquiries submitted yet.</p>
                                </c:when>
                                <c:otherwise>
                                    <table class="inq-table">
                                        <thead>
                                            <tr>
                                                <th>Property</th>
                                                <th>Message</th>
                                                <th>Date</th>
                                                <th style="text-align:center;">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="inq" items="${recentInquiries}">
                                                <tr>
                                                    <td><strong>${inq.property.title}</strong></td>
                                                    <td style="color:#666; max-width:220px; overflow:hidden;
                            text-overflow:ellipsis; white-space:nowrap;">
                                                        ${inq.message}
                                                    </td>
                                                    <td style="white-space:nowrap; color:#888; font-size:13px;">
                                                        ${inq.createdAt.dayOfMonth}/${inq.createdAt.monthValue}/${inq.createdAt.year}
                                                    </td>
                                                    <td style="text-align:center;">
                                                        <c:choose>
                                                            <c:when test="${inq.status == 'PENDING'}">
                                                                <span class="badge badge-pending">Pending</span>
                                                            </c:when>
                                                            <c:when test="${inq.status == 'REPLIED'}">
                                                                <span class="badge badge-replied">Replied</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge badge-closed">Closed</span>
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
            
            <script>
            function deleteSavedSearch(id) {
                if(!confirm('Delete this saved search?')) return;
                fetch('/user/saved-searches/' + id, {
                    method: 'DELETE',
                    headers: { 
                        'X-CSRF-TOKEN': document.querySelector('meta[name="_csrf"]').getAttribute('content') 
                    }
                }).then(function() {
                    location.reload();
                });
            }
            </script>
            </body>

            </html>