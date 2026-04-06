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
    <title>Manage Bookings - Agent Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0 }
        body { font-family: 'Inter', sans-serif; background: #f4f6fb; color: #222 }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

<main class="page-content" style="max-width:1200px;margin:30px auto;padding:0 20px;">
    
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:24px;">
        <h1 style="color:#1e293b;margin:0;font-size:24px;">Manage Site Visits</h1>
    </div>

    <c:if test="${not empty successMessage}">
        <div style="background:#f0fdf4;color:#22c55e;padding:12px;border-radius:6px;margin-bottom:20px;border:1px solid #86efac;">
            ${successMessage}
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div style="background:#fef2f2;color:#ef4444;padding:12px;border-radius:6px;margin-bottom:20px;border:1px solid #fca5a5;">
            ${errorMessage}
        </div>
    </c:if>

    <!-- Tabs Header -->
    <div style="display:flex;border-bottom:2px solid #e2e8f0;margin-bottom:24px;">
        <button id="tab-pending" style="background:none;border:none;border-bottom:2px solid #1A73E8;color:#1A73E8;padding:12px 24px;font-size:16px;font-weight:600;cursor:pointer;margin-bottom:-2px;">
            Pending Requests (${pendingBookings.size()})
        </button>
        <button id="tab-confirmed" style="background:none;border:none;border-bottom:2px solid transparent;color:#64748b;padding:12px 24px;font-size:16px;font-weight:600;cursor:pointer;margin-bottom:-2px;">
            Confirmed Visits (${confirmedBookings.size()})
        </button>
    </div>

    <!-- Pending Content -->
    <div id="content-pending" style="display:block;">
        <c:choose>
            <c:when test="${empty pendingBookings}">
                <div style="text-align:center;padding:48px;background:white;border-radius:12px;border:1px dashed #cbd5e1;color:#64748b;">
                    <p style="margin:0;font-size:16px;">You have no pending visit requests.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="background:white;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);overflow:hidden;">
                    <table style="width:100%;border-collapse:collapse;">
                        <thead>
                            <tr style="background:#f8fafc;border-bottom:1px solid #e2e8f0;">
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Property</th>
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Visitor</th>
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Contact</th>
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Date & Time</th>
                                <th style="padding:16px;text-align:center;color:#475569;font-weight:600;font-size:14px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="booking" items="${pendingBookings}">
                                <tr style="border-bottom:1px solid #e2e8f0;">
                                    <td style="padding:16px;color:#1e293b;font-weight:500;">
                                        <a href="/properties/${booking.property.id}" style="color:#1A73E8;text-decoration:none;">${booking.property.title}</a><br>
                                        <span style="font-size:12px;color:#64748b;">📍 ${booking.property.city}</span>
                                    </td>
                                    <td style="padding:16px;color:#334155;">${booking.visitorName}</td>
                                    <td style="padding:16px;color:#334155;font-size:14px;">
                                        📞 ${booking.visitorPhone}<br>
                                        ✉️ ${booking.visitorEmail}
                                    </td>
                                    <td style="padding:16px;color:#334155;">
                                        📅 ${booking.visitDate}<br>
                                        ⏰ <span style="background:#e0e7ff;color:#4f46e5;padding:2px 8px;border-radius:4px;font-size:12px;font-weight:600;">${booking.timeSlot}</span>
                                    </td>
                                    <td style="padding:16px;display:flex;gap:8px;justify-content:center;">
                                        <form action="/agent/bookings/${booking.id}/confirm" method="post" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" style="background:#22c55e;color:white;border:none;padding:8px 16px;border-radius:6px;font-weight:600;cursor:pointer;font-size:13px;">Confirm</button>
                                        </form>
                                        <form action="/agent/bookings/${booking.id}/cancel" method="post" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" style="background:#ef4444;color:white;border:none;padding:8px 16px;border-radius:6px;font-weight:600;cursor:pointer;font-size:13px;" onclick="return confirm('Are you sure you want to decline this request?');">Decline</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Confirmed Content -->
    <div id="content-confirmed" style="display:none;">
        <c:choose>
            <c:when test="${empty confirmedBookings}">
                <div style="text-align:center;padding:48px;background:white;border-radius:12px;border:1px dashed #cbd5e1;color:#64748b;">
                    <p style="margin:0;font-size:16px;">You have no confirmed visits scheduled.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="background:white;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);overflow:hidden;">
                    <table style="width:100%;border-collapse:collapse;">
                        <thead>
                            <tr style="background:#f8fafc;border-bottom:1px solid #e2e8f0;">
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Property</th>
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Visitor</th>
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Contact</th>
                                <th style="padding:16px;text-align:left;color:#475569;font-weight:600;font-size:14px;">Date & Time</th>
                                <th style="padding:16px;text-align:center;color:#475569;font-weight:600;font-size:14px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="booking" items="${confirmedBookings}">
                                <tr style="border-bottom:1px solid #e2e8f0;">
                                    <td style="padding:16px;color:#1e293b;font-weight:500;">
                                        <a href="/properties/${booking.property.id}" style="color:#1A73E8;text-decoration:none;">${booking.property.title}</a><br>
                                        <span style="font-size:12px;color:#64748b;">📍 ${booking.property.city}</span>
                                    </td>
                                    <td style="padding:16px;color:#334155;">${booking.visitorName}</td>
                                    <td style="padding:16px;color:#334155;font-size:14px;">
                                        📞 ${booking.visitorPhone}<br>
                                        ✉️ ${booking.visitorEmail}
                                    </td>
                                    <td style="padding:16px;color:#334155;">
                                        📅 ${booking.visitDate}<br>
                                        ⏰ <span style="background:#e0e7ff;color:#4f46e5;padding:2px 8px;border-radius:4px;font-size:12px;font-weight:600;">${booking.timeSlot}</span>
                                    </td>
                                    <td style="padding:16px;display:flex;gap:8px;justify-content:center;">
                                        <form action="/agent/bookings/${booking.id}/complete" method="post" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" style="background:#64748b;color:white;border:none;padding:8px 16px;border-radius:6px;font-weight:600;cursor:pointer;font-size:13px;">Complete</button>
                                        </form>
                                        <form action="/agent/bookings/${booking.id}/cancel" method="post" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" style="background:#ef4444;color:white;border:none;padding:8px 16px;border-radius:6px;font-weight:600;cursor:pointer;font-size:13px;" onclick="return confirm('Cancel this confirmed visit?');">Cancel</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</main>

<script>
    document.getElementById('tab-pending').addEventListener('click', function() {
        this.style.borderColor = '#1A73E8';
        this.style.color = '#1A73E8';
        document.getElementById('tab-confirmed').style.borderColor = 'transparent';
        document.getElementById('tab-confirmed').style.color = '#64748b';
        document.getElementById('content-pending').style.display = 'block';
        document.getElementById('content-confirmed').style.display = 'none';
    });

    document.getElementById('tab-confirmed').addEventListener('click', function() {
        this.style.borderColor = '#1A73E8';
        this.style.color = '#1A73E8';
        document.getElementById('tab-pending').style.borderColor = 'transparent';
        document.getElementById('tab-pending').style.color = '#64748b';
        document.getElementById('content-confirmed').style.display = 'block';
        document.getElementById('content-pending').style.display = 'none';
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
</body>
</html>
