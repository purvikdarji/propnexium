<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="_csrf" content="${_csrf.token}" />
    <meta name="_csrf_header" content="${_csrf.headerName}" />
    <title>Book Site Visit - PropNexium</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0 }
        body { font-family: 'Inter', sans-serif; background: #f4f6fb; color: #222 }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>

<main class="page-content" style="max-width:1200px;margin:30px auto;padding:0 20px;">

    <c:if test="${not empty errorMessage}">
        <div style="background:#fef2f2;color:#ef4444;padding:12px;border-radius:6px;margin-bottom:20px;border:1px solid #fca5a5;">
            ${errorMessage}
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div style="background:#f0fdf4;color:#22c55e;padding:12px;border-radius:6px;margin-bottom:20px;border:1px solid #86efac;">
            ${successMessage}
        </div>
    </c:if>

    <div style="display:flex;flex-wrap:wrap;gap:30px;">
        
        <!-- Left Column: Property Summary -->
        <div style="flex:1;min-width:300px;background:white;padding:24px;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);height:fit-content;">
            <h2 style="margin-top:0;font-size:20px;color:#1e293b;">Property Details</h2>
            
            <c:choose>
                <c:when test="${not empty property.images}">
                    <img src="${property.images[0].imageUrl}" alt="${property.title}" style="width:100%;height:220px;object-fit:cover;border-radius:8px;margin-bottom:16px;">
                </c:when>
                <c:otherwise>
                    <div style="width:100%;height:220px;background:#e2e8f0;border-radius:8px;display:flex;align-items:center;justify-content:center;margin-bottom:16px;color:#64748b;">
                        No Image Available
                    </div>
                </c:otherwise>
            </c:choose>
            
            <h3 style="font-size:18px;margin:0 0 8px 0;color:#0f172a;">${property.title}</h3>
            <p style="margin:0 0 4px 0;color:#64748b;font-size:14px;">📍 ${property.city}</p>
            <p style="margin:0 0 16px 0;font-size:20px;font-weight:700;color:#1A73E8;">₹${property.price}</p>
            
            <div style="display:flex;gap:12px;padding-top:16px;border-top:1px solid #e2e8f0;">
                <span style="background:#f8fafc;padding:6px 12px;border-radius:6px;font-size:13px;font-weight:600;color:#475569;">
                    🛏️ ${property.bedrooms} Beds
                </span>
                <span style="background:#f8fafc;padding:6px 12px;border-radius:6px;font-size:13px;font-weight:600;color:#475569;">
                    🚿 ${property.bathrooms} Baths
                </span>
                <span style="background:#f8fafc;padding:6px 12px;border-radius:6px;font-size:13px;font-weight:600;color:#475569;">
                    📏 ${property.areaSqft} sqft
                </span>
            </div>
            
            <a href="/properties/${property.id}" style="display:inline-block;margin-top:20px;color:#1A73E8;text-decoration:none;font-weight:600;font-size:14px;">
                &larr; Back to full details
            </a>
        </div>
        
        <!-- Right Column: Form -->
        <div style="flex:2;min-width:350px;background:white;padding:32px;border-radius:12px;box-shadow:0 4px 6px -1px rgba(0,0,0,0.1);">
            <h1 style="margin-top:0;font-size:24px;color:#1e293b;margin-bottom:24px;">Schedule a Site Visit</h1>
            
            <form:form action="/properties/${property.id}/book" method="post" modelAttribute="booking">
                
                <div style="margin-bottom:16px;">
                    <label style="display:block;font-size:14px;font-weight:600;margin-bottom:6px;color:#475569;">Name *</label>
                    <form:input path="visitorName" style="width:100%;padding:12px;border:1px solid #cbd5e1;border-radius:6px;box-sizing:border-box;font-size:15px;" placeholder="John Doe" required="true" />
                    <form:errors path="visitorName" style="color:#ef4444;font-size:12px;display:block;margin-top:4px;"/>
                </div>

                <div style="display:flex;gap:16px;margin-bottom:16px;">
                    <div style="flex:1;">
                        <label style="display:block;font-size:14px;font-weight:600;margin-bottom:6px;color:#475569;">Email *</label>
                        <form:input path="visitorEmail" type="email" style="width:100%;padding:12px;border:1px solid #cbd5e1;border-radius:6px;box-sizing:border-box;font-size:15px;" placeholder="john@example.com" required="true" />
                        <form:errors path="visitorEmail" style="color:#ef4444;font-size:12px;display:block;margin-top:4px;"/>
                    </div>
                    <div style="flex:1;">
                        <label style="display:block;font-size:14px;font-weight:600;margin-bottom:6px;color:#475569;">Phone (10 digits) *</label>
                        <form:input path="visitorPhone" style="width:100%;padding:12px;border:1px solid #cbd5e1;border-radius:6px;box-sizing:border-box;font-size:15px;" placeholder="9876543210" pattern="^[0-9]{10}$" required="true" />
                        <form:errors path="visitorPhone" style="color:#ef4444;font-size:12px;display:block;margin-top:4px;"/>
                    </div>
                </div>

                <div style="margin-bottom:16px;">
                    <label style="display:block;font-size:14px;font-weight:600;margin-bottom:6px;color:#475569;">Visit Date *</label>
                    <form:input path="visitDate" type="date" min="${minDate}" id="visitDate" style="width:100%;padding:12px;border:1px solid #cbd5e1;border-radius:6px;box-sizing:border-box;font-size:15px;" required="true" />
                    <form:errors path="visitDate" style="color:#ef4444;font-size:12px;display:block;margin-top:4px;"/>
                    <p style="margin:4px 0 0 0;font-size:12px;color:#94a3b8;">Please book at least one day in advance.</p>
                </div>

                <div style="margin-bottom:20px;">
                    <label style="display:block;font-size:14px;font-weight:600;margin-bottom:6px;color:#475569;">Time Slot *</label>
                    <div id="slotsContainer" style="display:flex;flex-wrap:wrap;gap:8px;padding:12px;background:#f8fafc;border-radius:6px;border:1px solid #e2e8f0;min-height:48px;">
                        <span style="color:#64748b;font-size:14px;display:flex;align-items:center;width:100%;">Select a valid date first to view slots.</span>
                    </div>
                    <form:errors path="timeSlot" style="color:#ef4444;font-size:12px;display:block;margin-top:4px;"/>
                </div>

                <div style="margin-bottom:24px;">
                    <label style="display:block;font-size:14px;font-weight:600;margin-bottom:6px;color:#475569;">Additional Notes (Optional)</label>
                    <form:textarea path="notes" style="width:100%;padding:12px;border:1px solid #cbd5e1;border-radius:6px;box-sizing:border-box;font-size:15px;min-height:100px;font-family:inherit;" placeholder="Any specific questions or requirements..."></form:textarea>
                </div>

                <button type="submit" style="width:100%;padding:14px;background:#1A73E8;color:white;border:none;border-radius:8px;font-size:16px;font-weight:700;cursor:pointer;transition:background 0.2s;">
                    Confirm Booking
                </button>
                
            </form:form>
        </div>
    </div>
</main>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const visitDateInput = document.getElementById('visitDate');
        const slotsContainer = document.getElementById('slotsContainer');
        const propertyId = '${property.id}';

        // Fetch slots when date changes
        visitDateInput.addEventListener('input', function() {
            fetchSlots(this.value);
        });
        
        // Fetch on load if date is present (validation failed case)
        if(visitDateInput.value) {
            fetchSlots(visitDateInput.value);
        }

        function fetchSlots(dateStr) {
            if(!dateStr) return;
            
            slotsContainer.innerHTML = '<span style="color:#64748b;font-size:14px;">Loading slots...</span>';
            
            fetch('/api/v1/bookings/slots?propertyId=' + propertyId + '&date=' + dateStr)
                .then(r => r.json())
                .then(result => {
                    const data = result.data;
                    if(!data || !data.length) {
                        slotsContainer.innerHTML = '<p style="color:#ef4444;font-size:14px;margin:0;width:100%;">No slots available for this date. Try another day.</p>';
                        return;
                    }
                    
                    var previouslySelectedSlot = '${booking.timeSlot}'; // retain after error
                    
                    slotsContainer.innerHTML = data.map(slot => {
                        let isChecked = previouslySelectedSlot === slot ? 'checked' : '';
                        return `
                            <label style="display:inline-block;margin:4px;">
                                <input type="radio" name="timeSlot" value="\${slot}" required \${isChecked} style="display:none;" />
                                <span class="slot-badge" style="padding:8px 16px;background:#e2e8f0;color:#334155;border-radius:6px;cursor:pointer;font-size:13px;font-weight:600;display:inline-block;border:2px solid transparent;transition:all 0.2s;">
                                    \${slot}
                                </span>
                            </label>
                        `;
                    }).join('');
                    
                    // Add interactive styles
                    const inputs = slotsContainer.querySelectorAll('input[type="radio"]');
                    inputs.forEach(input => {
                        input.addEventListener('change', function() {
                            slotsContainer.querySelectorAll('.slot-badge').forEach(badge => {
                                badge.style.background = '#e2e8f0';
                                badge.style.color = '#334155';
                                badge.style.borderColor = 'transparent';
                            });
                            if(this.checked) {
                                let badge = this.nextElementSibling;
                                badge.style.background = '#e8f0fe';
                                badge.style.color = '#1A73E8';
                                badge.style.borderColor = '#1A73E8';
                            }
                        });
                        
                        // force repaint if already checked from backend
                        if (input.checked) {
                            input.dispatchEvent(new Event('change'));
                        }
                    });
                })
                .catch(err => {
                    slotsContainer.innerHTML = '<p style="color:#ef4444;font-size:14px;margin:0;">Error loading slots. Please refresh.</p>';
                });
        }
    });
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
</body>
</html>
