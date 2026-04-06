<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Agent Dashboard – PropNexium</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:'Inter',sans-serif;background:#f8fafc;color:#1e293b}
    a{text-decoration:none}

    /* ── Layout ── */
    .wrap{display:flex;min-height:100vh}

    /* ── Sidebar ── */
    .sidebar{
      width:230px;background:#0f172a;flex-shrink:0;
      display:flex;flex-direction:column;
    }
    .sidebar-profile{
      text-align:center;padding:20px 12px 18px;
      border-bottom:1px solid #1e293b;
    }
    .avatar-circle{
      width:62px;height:62px;border-radius:50%;
      background:linear-gradient(135deg,#1a73e8,#6366f1);
      margin:0 auto;display:flex;align-items:center;justify-content:center;
      font-size:24px;font-weight:800;color:white;
    }
    .avatar-circle img{width:62px;height:62px;border-radius:50%;object-fit:cover}
    .agent-name{color:white;font-weight:700;font-size:14px;margin-top:10px;line-height:1.3}
    .agency-name{color:#64748b;font-size:12px;margin-top:3px}
    .rating-stars{color:#fbbf24;font-size:13px;margin-top:5px}

    .sidebar-label{
      padding:14px 20px 5px;color:#475569;font-size:10px;
      font-weight:700;text-transform:uppercase;letter-spacing:1.2px;
    }
    .sidebar a{
      display:flex;align-items:center;gap:10px;
      padding:11px 20px;color:#94a3b8;font-size:14px;font-weight:500;
      transition:background .15s,color .15s;position:relative;
    }
    .sidebar a:hover{background:#1e293b;color:#f1f5f9}
    .sidebar a.active{background:#1e3a5f;color:#60a5fa;border-left:3px solid #3b82f6}
    .notif-pill{
      margin-left:auto;padding:2px 7px;border-radius:10px;
      font-size:11px;font-weight:700;color:white;
    }
    .pill-amber{background:#f59e0b}
    .pill-red{background:#ef4444}
    .sidebar-foot{
      margin-top:auto;border-top:1px solid #1e293b;padding:12px 20px;
    }
    .sidebar-foot a{color:#475569;font-size:13px}
    .sidebar-foot a:hover{color:#94a3b8;background:none}

    /* ── Main ── */
    .main{flex:1;display:flex;flex-direction:column;overflow:hidden}
    .topbar{
      background:white;padding:14px 28px;border-bottom:1px solid #e2e8f0;
      display:flex;justify-content:space-between;align-items:center;
    }
    .topbar h1{font-size:20px;font-weight:700}
    .content{padding:26px 28px;overflow-y:auto}

    /* ── Warning banner ── */
    .warning-banner{
      display:flex;justify-content:space-between;align-items:center;
      background:#fff7ed;border:1px solid #fed7aa;border-radius:10px;
      padding:14px 20px;margin-bottom:22px;
    }
    .warning-text{color:#c2410c;font-size:14px;font-weight:500}
    .btn-orange{
      padding:8px 16px;background:#f97316;color:white;border-radius:7px;
      font-size:13px;font-weight:600;white-space:nowrap;margin-left:16px;
    }

    /* ── Stats Grid ── */
    .stats-grid{
      display:grid;grid-template-columns:repeat(4,1fr);
      gap:18px;margin-bottom:24px;
    }
    .stat-card{
      background:white;border-radius:12px;padding:20px 22px;
      box-shadow:0 1px 6px rgba(0,0,0,.06);
      border-top:3px solid var(--accent);
      transition:transform .15s,box-shadow .15s;
    }
    .stat-card:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,.1)}
    .stat-label{color:#94a3b8;font-size:11px;font-weight:700;
      text-transform:uppercase;letter-spacing:.7px;margin-bottom:8px}
    .stat-value{font-size:32px;font-weight:800;color:#1e293b;line-height:1;margin-bottom:6px}
    .stat-sub{font-size:12px;color:#64748b}
    .stat-sub a{color:var(--accent);font-weight:600}

    /* ── Two-col ── */
    .two-col{display:grid;grid-template-columns:1fr 1fr;gap:18px}

    /* ── Data Cards ── */
    .data-card{background:white;border-radius:12px;padding:22px;box-shadow:0 1px 6px rgba(0,0,0,.06)}
    .data-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px}
    .data-head h3{font-size:15px;font-weight:700;color:#1e293b}
    .data-head a{font-size:13px;color:#3b82f6}

    /* ── Listing row ── */
    .listing-row{
      display:flex;justify-content:space-between;align-items:center;
      padding:11px 0;border-bottom:1px solid #f1f5f9;
    }
    .listing-row:last-child{border-bottom:none}
    .listing-title{font-weight:600;font-size:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:190px}
    .listing-meta{color:#94a3b8;font-size:12px;margin-top:3px}
    .status-pill{
      padding:3px 10px;border-radius:8px;font-size:11px;font-weight:600;white-space:nowrap;
    }
    .s-available{background:#dcfce7;color:#16a34a}
    .s-under_review{background:#fef9c3;color:#854d0e}
    .s-sold{background:#f1f5f9;color:#64748b}
    .s-rejected{background:#fee2e2;color:#dc2626}
    .s-rented{background:#f3e8ff;color:#7e22ce}

    /* ── Inquiry row ── */
    .inq-row{padding:11px 0;border-bottom:1px solid #f1f5f9}
    .inq-row:last-child{border-bottom:none}
    .inq-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}
    .inq-name{font-weight:600;font-size:14px}
    .inq-prop{color:#64748b;font-size:12px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .inq-date{color:#94a3b8;font-size:11px;margin-top:3px}
    .i-pending{background:#fef9c3;color:#d97706}
    .i-replied{background:#dcfce7;color:#16a34a}
    .i-closed{background:#f1f5f9;color:#64748b}

    /* ── Empty state ── */
    .empty-state{text-align:center;padding:32px;color:#94a3b8}
    .empty-state .icon{font-size:36px;margin-bottom:10px}
    .empty-state p{font-size:14px;margin-bottom:10px}
    .empty-state a{color:#3b82f6;font-weight:600;font-size:14px}

    /* ── Flash ── */
    .flash-success{
      padding:12px 18px;border-radius:8px;margin-bottom:18px;
      font-size:14px;font-weight:500;background:#dcfce7;color:#166534;
    }
  </style>
</head>
<body>
<div class="wrap">

  <!-- ══ SIDEBAR ══ -->
  <aside class="sidebar">
    <div class="sidebar-profile">
      <c:choose>
        <c:when test="${not empty agent.profilePicture}">
          <div class="avatar-circle">
            <img src="${agent.profilePicture}" alt="${agent.name}">
          </div>
        </c:when>
        <c:otherwise>
          <div class="avatar-circle">${agent.name.charAt(0)}</div>
        </c:otherwise>
      </c:choose>
      <div class="agent-name">${agent.name}</div>
      <c:if test="${not empty agentProfile.agencyName}">
        <div class="agency-name">${agentProfile.agencyName}</div>
      </c:if>
      <c:if test="${agentProfile != null && agentProfile.rating != null && agentProfile.rating > 0}">
        <div class="rating-stars">★ ${agentProfile.rating}</div>
      </c:if>
    </div>

    <div class="sidebar-label">Agent Panel</div>

    <a href="/agent/dashboard" class="active">📊 Dashboard</a>
    <a href="/agent/properties">
      🏠 My Properties
      <c:if test="${pendingListings > 0}">
        <span class="notif-pill pill-amber">${pendingListings}</span>
      </c:if>
    </a>
    <a href="/agent/properties/add">➕ Add Property</a>
    <a href="/agent/inquiries">
      💬 Inquiries
      <c:if test="${pendingInquiries > 0}">
        <span class="notif-pill pill-red">${pendingInquiries}</span>
      </c:if>
    </a>
    <a href="/agent/bookings">📅 Manage Visits</a>
    <a href="/user/notifications">🔔 Notifications</a>
    <a href="/agent/profile">👤 Agent Profile</a>

    <div class="sidebar-foot">
      <a href="/">← View Site</a>
    </div>
  </aside>

  <!-- ══ MAIN ══ -->
  <div class="main">
    <div class="topbar">
      <h1>Agent Dashboard</h1>
      <div style="font-size:13px;color:#64748b">
        Welcome back, <strong>${agent.name}</strong>
        <c:if test="${unreadNotifications > 0}">
          <span style="margin-left:10px;background:#ef4444;color:white;padding:2px 8px;border-radius:10px;font-size:12px">
            🔔 ${unreadNotifications}
          </span>
        </c:if>
      </div>
    </div>

    <div class="content">

      <!-- Flash -->
      <c:if test="${not empty successMessage}">
        <div class="flash-success">✅ ${successMessage}</div>
      </c:if>

      <!-- Profile incomplete banner -->
      <c:if test="${!profileComplete}">
        <div class="warning-banner">
          <span class="warning-text">⚠ Complete your agent profile to build trust with buyers</span>
          <a href="/agent/profile" class="btn-orange">Complete Profile →</a>
        </div>
      </c:if>

      <!-- ── Stats ── -->
      <div class="stats-grid">
        <div class="stat-card" style="--accent:#3b82f6">
          <div class="stat-label">Total Listings</div>
          <div class="stat-value">${totalListings}</div>
          <div class="stat-sub">${availableListings} available · ${soldListings} sold</div>
        </div>
        <div class="stat-card" style="--accent:#f59e0b">
          <div class="stat-label">Pending Review</div>
          <div class="stat-value" style="color:#f59e0b">${pendingListings}</div>
          <div class="stat-sub">
            <a href="/agent/properties?status=UNDER_REVIEW" style="color:#f59e0b">View pending →</a>
          </div>
        </div>
        <div class="stat-card" style="--accent:#8b5cf6">
          <div class="stat-label">Inquiries</div>
          <div class="stat-value">${totalInquiries}</div>
          <div class="stat-sub">${pendingInquiries} awaiting reply</div>
        </div>
        <div class="stat-card" style="--accent:#06b6d4">
          <div class="stat-label">Total Views</div>
          <div class="stat-value">${totalViews}</div>
          <div class="stat-sub">Across all listings</div>
        </div>
      </div>

      <!-- ── 2-col: recent listings + recent inquiries ── -->
      <div class="two-col">

        <!-- Recent Listings -->
        <div class="data-card">
          <div class="data-head">
            <h3>🏠 Recent Listings</h3>
            <a href="/agent/properties">View all →</a>
          </div>
          <c:choose>
            <c:when test="${empty recentListings}">
              <div class="empty-state">
                <div class="icon">🏠</div>
                <p>No listings yet.</p>
                <a href="/agent/properties/add">Add your first property →</a>
              </div>
            </c:when>
            <c:otherwise>
              <c:forEach var="p" items="${recentListings}">
                <div class="listing-row">
                  <div style="flex:1;min-width:0">
                    <div class="listing-title">${p.title}</div>
                    <div class="listing-meta">
                      ${p.city} · ₹<fmt:formatNumber value="${p.price}" groupingUsed="true"/>
                    </div>
                  </div>
                  <div style="margin-left:10px;flex-shrink:0">
                    <span class="status-pill s-${p.status.toString().toLowerCase()}">${p.status}</span>
                  </div>
                </div>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Recent Inquiries -->
        <div class="data-card">
          <div class="data-head">
            <h3>💬 Recent Inquiries</h3>
            <a href="/agent/inquiries">View all →</a>
          </div>
          <c:choose>
            <c:when test="${empty recentInquiries}">
              <div class="empty-state">
                <div class="icon">💬</div>
                <p>No inquiries yet.</p>
              </div>
            </c:when>
            <c:otherwise>
              <c:forEach var="inq" items="${recentInquiries}">
                <div class="inq-row">
                  <div class="inq-top">
                    <span class="inq-name">${inq.inquirerName}</span>
                    <span class="status-pill i-${inq.status.toString().toLowerCase()}">${inq.status}</span>
                  </div>
                  <div class="inq-prop">Re: ${inq.property.title}</div>
                  <div class="inq-date">
                    ${inq.createdAt.dayOfMonth}/${inq.createdAt.monthValue}/${inq.createdAt.year}
                  </div>
                </div>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>

      </div><!-- /two-col -->
    </div><!-- /content -->
  </div><!-- /main -->
</div><!-- /wrap -->
</body>
</html>