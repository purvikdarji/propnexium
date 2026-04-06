<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inquiry Inbox – PropNexium</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:'Inter',sans-serif;background:#f8fafc;color:#1e293b}
    a{text-decoration:none}
    .wrap{display:flex;min-height:100vh}
    .main{flex:1;display:flex;flex-direction:column}
    .topbar{background:white;padding:14px 28px;border-bottom:1px solid #e2e8f0;
            display:flex;justify-content:space-between;align-items:center}
    .topbar h1{font-size:20px;font-weight:700}
    .content{padding:24px 28px}
    /* Flash */
    .flash-ok{background:#dcfce7;color:#166534;border-radius:8px;padding:12px 18px;margin-bottom:18px;font-size:14px}
    .flash-err{background:#fee2e2;color:#dc2626;border-radius:8px;padding:12px 18px;margin-bottom:18px;font-size:14px}
    /* Filter tabs */
    .filter-tabs{display:flex;border-radius:8px;overflow:hidden;
                 box-shadow:0 1px 8px rgba(0,0,0,0.06);margin-bottom:20px}
    .filter-tab{flex:1;padding:13px;text-align:center;font-size:14px;font-weight:600;
                border-right:1px solid #f1f5f9;cursor:pointer}
    .filter-tab:last-child{border-right:none}
    /* Inquiry cards */
    .inq-list{display:flex;flex-direction:column;gap:12px}
    .inq-card{background:white;border-radius:10px;padding:20px;
              box-shadow:0 1px 8px rgba(0,0,0,0.06);display:block;
              border-left:4px solid #e2e8f0;transition:box-shadow .15s;color:#1e293b}
    .inq-card:hover{box-shadow:0 4px 16px rgba(0,0,0,0.1)}
    .inq-card.pending{border-left-color:#f59e0b}
    .inq-card.replied{border-left-color:#22c55e}
    .inq-card.closed{border-left-color:#94a3b8}
    .inq-row{display:flex;justify-content:space-between;align-items:flex-start}
    .inq-name{font-weight:700;font-size:15px;color:#1e293b}
    .badge{display:inline-block;padding:2px 9px;border-radius:8px;font-size:11px;font-weight:600}
    .badge-PENDING{background:#fef3c7;color:#d97706}
    .badge-REPLIED{background:#dcfce7;color:#16a34a}
    .badge-CLOSED{background:#f3f4f6;color:#6b7280}
    .inq-contact{color:#64748b;font-size:13px;margin:4px 0}
    .inq-prop{color:#374151;font-size:13px;margin-bottom:4px}
    .inq-msg{color:#94a3b8;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:500px}
    .inq-meta{text-align:right;flex-shrink:0;margin-left:20px}
    .inq-date{color:#94a3b8;font-size:12px}
    .view-btn{margin-top:10px;padding:6px 14px;background:#f0f4ff;color:#1a73e8;border-radius:6px;font-size:13px;font-weight:600;display:inline-block}
    /* Empty state */
    .empty{background:white;border-radius:10px;padding:60px 20px;text-align:center;
           box-shadow:0 1px 8px rgba(0,0,0,0.06)}
    /* Pagination */
    .pages{display:flex;justify-content:center;gap:5px;margin-top:25px}
    .pages a{padding:8px 14px;border-radius:6px;font-size:13px;font-weight:500;
             background:white;color:#374151;box-shadow:0 1px 4px rgba(0,0,0,0.08)}
    .pages a.active{background:#1a73e8;color:white}
  </style>
</head>
<body>
<div class="wrap">
  <%@ include file="/WEB-INF/views/agent/sidebar.jsp" %>

  <div class="main">
    <div class="topbar">
      <h1>&#128172; Inquiry Inbox</h1>
      <span style="font-size:13px;color:#64748b">${pendingCount} pending</span>
    </div>

    <div class="content">
      <c:if test="${not empty successMessage}"><div class="flash-ok">&#10003; ${successMessage}</div></c:if>
      <c:if test="${not empty errorMessage}"><div class="flash-err">&#9888; ${errorMessage}</div></c:if>

      <!-- Filter tabs -->
      <div class="filter-tabs">
        <a href="/agent/inquiries"
           class="filter-tab"
           style="background:${empty filterStatus ? '#1a73e8' : 'white'};color:${empty filterStatus ? 'white' : '#374151'}">
          All&nbsp;(${pendingCount + repliedCount + closedCount})
        </a>
        <a href="/agent/inquiries?status=PENDING"
           class="filter-tab"
           style="background:${filterStatus == 'PENDING' ? '#fef3c7' : 'white'};color:${filterStatus == 'PENDING' ? '#d97706' : '#374151'}">
          &#9203; Pending&nbsp;(${pendingCount})
        </a>
        <a href="/agent/inquiries?status=REPLIED"
           class="filter-tab"
           style="background:${filterStatus == 'REPLIED' ? '#dcfce7' : 'white'};color:${filterStatus == 'REPLIED' ? '#16a34a' : '#374151'}">
          &#10003; Replied&nbsp;(${repliedCount})
        </a>
        <a href="/agent/inquiries?status=CLOSED"
           class="filter-tab"
           style="background:${filterStatus == 'CLOSED' ? '#f3f4f6' : 'white'};color:${filterStatus == 'CLOSED' ? '#6b7280' : '#374151'}">
          &#128274; Closed&nbsp;(${closedCount})
        </a>
      </div>

      <!-- Inquiry list -->
      <div class="inq-list">
        <c:choose>
          <c:when test="${empty inquiries.content}">
            <div class="empty">
              <div style="font-size:48px;margin-bottom:14px">&#128237;</div>
              <h3 style="color:#94a3b8;margin:0">No inquiries found</h3>
              <p style="color:#94a3b8;margin-top:6px">Inquiries will appear here when buyers contact you.</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="inq" items="${inquiries.content}">
              <a href="/agent/inquiries/${inq.id}"
                 class="inq-card ${inq.status == 'PENDING' ? 'pending' : inq.status == 'REPLIED' ? 'replied' : 'closed'}">
                <div class="inq-row">
                  <div style="flex:1;min-width:0">
                    <div style="display:flex;align-items:center;gap:10px;margin-bottom:5px">
                      <span class="inq-name">${inq.inquirerName}</span>
                      <span class="badge badge-${inq.status}">${inq.status}</span>
                    </div>
                    <div class="inq-contact">
                      &#128231;&nbsp;${inq.inquirerEmail}
                      <c:if test="${not empty inq.inquirerPhone}">&nbsp;|&nbsp;&#128241;&nbsp;${inq.inquirerPhone}</c:if>
                    </div>
                    <div class="inq-prop"><strong>Property:</strong> ${inq.property.title}</div>
                    <div class="inq-msg">${inq.message}</div>
                  </div>
                  <div class="inq-meta">
                    <div class="inq-date">${inq.createdAt.dayOfMonth}&nbsp;${inq.createdAt.month.name().substring(0,3)}&nbsp;${inq.createdAt.year}</div>
                    <div class="view-btn">View&nbsp;&#8594;</div>
                  </div>
                </div>
              </a>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

      <!-- Pagination -->
      <c:if test="${totalPages > 1}">
        <div class="pages">
          <c:forEach begin="0" end="${totalPages - 1}" var="i">
            <a href="?page=${i}<c:if test="${not empty filterStatus}">&amp;status=${filterStatus}</c:if>"
               class="${currentPage == i ? 'active' : ''}">${i + 1}</a>
          </c:forEach>
        </div>
      </c:if>
    </div>
  </div>
</div>
</body>
</html>
