<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}" />
    <meta name="_csrf_header" content="${_csrf.headerName}" />
    <title>My Site Visits - PropNexium</title>
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
        <h1 style="color:#1e293b;margin:0;font-size:24px;">My Scheduled Site Visits</h1>
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

    <c:choose>
        <c:when test="${empty bookings}">
            <div style="text-align:center;padding:64px 20px;background:white;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);">
                <div style="font-size:48px;margin-bottom:16px;">🗓️</div>
                <h2 style="margin:0 0 8px 0;color:#1e293b;font-size:20px;">No site visits scheduled yet</h2>
                <p style="color:#64748b;margin:0 0 24px 0;">Browse our properties and book a site visit to find your dream home!</p>
                <a href="/properties" style="display:inline-block;padding:12px 24px;background:#1A73E8;color:white;text-decoration:none;border-radius:8px;font-weight:600;transition:background 0.2s;">
                    Browse Properties
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div style="display:grid;grid-template-columns:repeat(auto-fill, minmax(340px, 1fr));gap:24px;">
                <c:forEach var="booking" items="${bookings}">
                    <div style="background:white;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);overflow:hidden;display:flex;flex-direction:column;position:relative;">
                        
                        <c:choose>
                            <c:when test="${booking.status == 'PENDING'}"><c:set var="bgCol" value="#f59e0b"/></c:when>
                            <c:when test="${booking.status == 'CONFIRMED'}"><c:set var="bgCol" value="#10b981"/></c:when>
                            <c:when test="${booking.status == 'CANCELLED'}"><c:set var="bgCol" value="#ef4444"/></c:when>
                            <c:when test="${booking.status == 'COMPLETED'}"><c:set var="bgCol" value="#64748b"/></c:when>
                            <c:otherwise><c:set var="bgCol" value="#1A73E8"/></c:otherwise>
                        </c:choose>
                        
                        <!-- Status Badge -->
                        <div style="position:absolute;top:12px;right:12px;padding:4px 12px;border-radius:99px;font-size:12px;font-weight:700;color:white;background:${bgCol};">
                            ${booking.status}
                        </div>

                        <!-- Property Image -->
                        <c:choose>
                            <c:when test="${not empty booking.property.images}">
                                <img src="${booking.property.images[0].imageUrl}" alt="${booking.property.title}" style="width:100%;height:200px;object-fit:cover;">
                            </c:when>
                            <c:otherwise>
                                <div style="width:100%;height:200px;background:#e2e8f0;display:flex;align-items:center;justify-content:center;color:#64748b;">
                                    No Image
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <div style="padding:20px;flex:1;display:flex;flex-direction:column;">
                            <h3 style="margin:0 0 4px 0;font-size:18px;color:#0f172a;line-height:1.4;">
                                <a href="/properties/${booking.property.id}" style="color:inherit;text-decoration:none;">${booking.property.title}</a>
                            </h3>
                            <p style="margin:0 0 16px 0;color:#64748b;font-size:14px;">📍 ${booking.property.city}</p>

                            <div style="background:#f8fafc;border:1px solid #e2e8f0;padding:12px;border-radius:8px;margin-bottom:16px;">
                                <p style="margin:0 0 6px 0;font-size:15px;font-weight:600;color:#1e293b;">📅 ${booking.visitDate}</p>
                                <p style="margin:0;font-size:15px;color:#1e293b;">⏰ <span style="color:#1A73E8;font-weight:600;">${booking.timeSlot}</span></p>
                            </div>

                            <div style="margin-bottom:20px;">
                                <p style="margin:0 0 4px 0;font-size:13px;font-weight:600;color:#475569;">AGENT CONTACT</p>
                                <p style="margin:0;font-size:14px;color:#334155;">${booking.property.agent.name}</p>
                                <c:if test="${booking.status == 'CONFIRMED'}">
                                    <p style="margin:4px 0 0 0;font-size:14px;color:#334155;">📞 ${booking.property.agent.phone}</p>
                                </c:if>
                                <c:if test="${booking.status == 'PENDING'}">
                                    <p style="margin:4px 0 0 0;font-size:12px;color:#94a3b8;font-style:italic;">Phone revealed upon confirmation</p>
                                </c:if>
                            </div>

                            <!-- Actions -->
                            <div style="margin-top:auto;border-top:1px solid #e2e8f0;padding-top:16px;">
                                <c:if test="${booking.status == 'PENDING'}">
                                    <form action="/user/bookings/${booking.id}/cancel" method="post" style="margin:0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" style="width:100%;padding:10px;background:white;color:#ef4444;border:1px solid #fca5a5;border-radius:6px;font-weight:600;cursor:pointer;transition:all 0.2s;" onclick="return confirm('Are you sure you want to cancel this booking?');">
                                            Cancel Booking
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${booking.status == 'CONFIRMED'}">
                                    <span style="display:block;text-align:center;font-size:13px;color:#10b981;font-weight:600;padding:10px;">
                                        Looking forward to your visit! ✓
                                    </span>
                                </c:if>
                                <c:if test="${booking.status == 'CANCELLED'}">
                                    <form action="/user/bookings/${booking.id}/delete" method="post" style="margin:0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" style="width:100%;padding:10px;background:#fef2f2;color:#ef4444;border:1px dashed #fca5a5;border-radius:6px;font-weight:600;cursor:pointer;transition:all 0.2s;" onclick="return confirm('Delete this record permanently?');">
                                            Delete Record
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
</body>
</html>
