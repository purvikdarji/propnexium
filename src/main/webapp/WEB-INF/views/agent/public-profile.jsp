<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
    <%@ include file="/WEB-INF/views/common/navbar.jsp" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                <div style="max-width:1000px;margin:30px auto;padding:0 20px;">

                    <!-- Agent header card -->
                    <div style="background:white;border-radius:12px;padding:30px;
              box-shadow:0 2px 12px rgba(0,0,0,0.08);margin-bottom:25px;
              display:flex;gap:25px;align-items:flex-start;">

                        <!-- Avatar -->
                        <div style="flex-shrink:0;">
                            <c:choose>
                                <c:when test="${not empty agent.profilePicture}">
                                    <img src="${agent.profilePicture}" style="width:90px;height:90px;border-radius:50%;
                      object-fit:cover;border:3px solid #e5e7eb;">
                                </c:when>
                                <c:otherwise>
                                    <div style="width:90px;height:90px;border-radius:50%;
                      background:#1a73e8;display:flex;align-items:center;
                      justify-content:center;font-size:36px;color:white;
                      font-weight:700;">
                                        ${agent.name.charAt(0)}
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Info -->
                        <div style="flex:1;">
                            <h2 style="margin:0 0 5px;color:#1e293b;font-size:24px;display:flex;align-items:center;gap:8px;">
                                ${agent.name}
                                <c:if test="${agent.isEmailVerified}">
                                    <span style="font-size:12px;background:#e0f2fe;color:#0284c7;padding:4px 8px;border-radius:12px;display:flex;align-items:center;gap:4px;font-weight:600;white-space:nowrap;line-height:1;">
                                        <svg style="width:14px;height:14px;" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M6.267 3.455a3.066 3.066 0 001.745-.723 3.066 3.066 0 013.976 0 3.066 3.066 0 001.745.723 3.066 3.066 0 012.812 2.812c.051.643.304 1.254.723 1.745a3.066 3.066 0 010 3.976 3.066 3.066 0 00-.723 1.745 3.066 3.066 0 01-2.812 2.812 3.066 3.066 0 00-1.745.723 3.066 3.066 0 01-3.976 0 3.066 3.066 0 00-1.745-.723 3.066 3.066 0 01-2.812-2.812 3.066 3.066 0 00-.723-1.745 3.066 3.066 0 010-3.976 3.066 3.066 0 00.723-1.745 3.066 3.066 0 012.812-2.812zm7.44 5.252a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>
                                        Verified
                                    </span>
                                </c:if>
                            </h2>
                            <c:if test="${not empty profile.agencyName}">
                                <div style="color:#64748b;font-size:14px;margin-bottom:8px;">
                                    🏢 ${profile.agencyName}
                                </div>
                            </c:if>

                            <!-- Star rating display -->
                            <div style="display:flex;align-items:center;gap:10px;margin-bottom:12px;">
                                <div style="display:flex;gap:2px;">
                                    <c:forEach begin="1" end="5" var="star">
                                        <span
                                            style="font-size:20px;color:${star <= avgRating ? '#fbbf24' : '#d1d5db'};">★</span>
                                    </c:forEach>
                                </div>
                                <span style="font-weight:700;color:#1e293b;font-size:16px;">
                                    <fmt:formatNumber value="${avgRating}" maxFractionDigits="1" />
                                </span>
                                <span style="color:#64748b;font-size:14px;">(${reviews.size()} reviews)</span>
                            </div>

                            <div style="display:flex;gap:20px;flex-wrap:wrap;">
                                <c:if test="${profile.experienceYears > 0}">
                                    <span style="color:#64748b;font-size:13px;">
                                        📅 ${profile.experienceYears} years experience
                                    </span>
                                </c:if>
                                <c:if test="${not empty profile.licenseNumber}">
                                    <span style="color:#64748b;font-size:13px;">
                                        🪪 License: ${profile.licenseNumber}
                                    </span>
                                </c:if>
                                <span style="color:#64748b;font-size:13px;">
                                    🏠 ${listings.size()} active listings
                                </span>
                            </div>

                            <c:if test="${not empty profile.bio}">
                                <p style="color:#374151;font-size:14px;margin:12px 0 0;
                  line-height:1.6;">${profile.bio}</p>
                            </c:if>
                        </div>
                    </div>

                    <!-- Rating distribution + Write review -->
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:25px;">

                        <!-- Distribution bars -->
                        <div style="background:white;border-radius:10px;padding:25px;
                box-shadow:0 1px 8px rgba(0,0,0,0.06);">
                            <h3 style="margin:0 0 15px;color:#1e293b;font-size:15px;">Rating Breakdown</h3>
                            <c:set var="totalReviews" value="${reviews.size()}" />
                            <c:forEach begin="1" end="5" var="i">
                                <c:set var="stars" value="${6 - i}" />
                                <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
                                    <span style="width:30px;text-align:right;font-size:13px;color:#374151;">
                                        ${stars}★
                                    </span>
                                    <div
                                        style="flex:1;height:10px;background:#f1f5f9;border-radius:5px;overflow:hidden;">
                                        <c:set var="count"
                                            value="${distribution[stars.intValue()] != null ? distribution[stars.intValue()] : 0}" />
                                        <c:set var="pct" value="${totalReviews > 0 ? count * 100 / totalReviews : 0}" />
                                        <div style="height:100%;background:#fbbf24;border-radius:5px;
                        width:${pct}%;"></div>
                                    </div>
                                    <span style="width:25px;font-size:12px;color:#64748b;">${count}</span>
                                </div>
                            </c:forEach>
                        </div>

                        <!-- Write review form -->
                        <div style="background:white;border-radius:10px;padding:25px;
                box-shadow:0 1px 8px rgba(0,0,0,0.06);">
                            <h3 style="margin:0 0 15px;color:#1e293b;font-size:15px;">
                                ${hasReviewed ? 'Your Review Submitted' : 'Write a Review'}
                            </h3>
                            <c:choose>
                                <c:when test="${hasReviewed}">
                                    <div style="background:#f0fdf4;border-radius:8px;padding:15px;color:#16a34a;">
                                        ✅ You have already reviewed this agent.
                                    </div>
                                </c:when>
                                <c:when test="${canReview}">
                                    <!-- Star rating selector -->
                                    <div style="display:flex;gap:5px;margin-bottom:15px;font-size:30px;"
                                        id="starSelector">
                                        <c:forEach begin="1" end="5" var="s">
                                            <span class="star" data-value="${s}" style="cursor:pointer;color:#d1d5db;"
                                                onclick="setRating(${s})" onmouseover="hoverRating(${s})"
                                                onmouseout="resetHover()">★</span>
                                        </c:forEach>
                                    </div>
                                    <!-- Granular ratings -->
                                    <div style="margin-bottom:15px; font-size:13px; color:#374151;">
                                        <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                                            <label>Communication</label>
                                            <input type="range" id="ratingComm" min="1" max="5" value="5" style="width:120px;">
                                        </div>
                                        <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                                            <label>Accuracy</label>
                                            <input type="range" id="ratingAcc" min="1" max="5" value="5" style="width:120px;">
                                        </div>
                                        <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                                            <label>Negotiation</label>
                                            <input type="range" id="ratingNeg" min="1" max="5" value="5" style="width:120px;">
                                        </div>
                                    </div>

                                    <textarea id="reviewComment" rows="4" placeholder="Share your experience..." style="width:100%;padding:10px;border:1px solid #d1d5db;border-radius:6px;
                   font-size:14px;resize:vertical;box-sizing:border-box;"></textarea>
                                    <button type="button" onclick="submitReview(${agent.id})" style="width:100%;margin-top:12px;padding:11px;background:#1a73e8;
                   color:white;border:none;border-radius:6px;
                   font-size:14px;font-weight:600;cursor:pointer;">
                                        Submit Review
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <div style="background:#f0f4ff;border-radius:8px;padding:15px;color:#1a73e8;">
                                        <a href="/auth/login" style="color:#1a73e8;font-weight:600;">Login</a>
                                        to write a review
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <!-- Reviews list -->
                    <div style="background:white;border-radius:10px;padding:25px;
              box-shadow:0 1px 8px rgba(0,0,0,0.06);margin-bottom:25px;">
                        <h3 style="margin:0 0 20px;color:#1e293b;">
                            Customer Reviews (${reviews.size()})
                        </h3>
                        <c:forEach var="review" items="${reviews}">
                            <div style="padding:18px 0;border-bottom:1px solid #f1f5f9;">
                                <div style="display:flex;justify-content:space-between;margin-bottom:8px;">
                                    <div style="display:flex;align-items:center;gap:10px;">
                                        <div style="width:36px;height:36px;border-radius:50%;
                        background:#1a73e8;display:flex;align-items:center;
                        justify-content:center;color:white;font-weight:700;
                        font-size:14px;">
                                            ${review.reviewer.name.charAt(0)}
                                        </div>
                                        <div>
                                            <div style="font-weight:600;color:#1e293b;font-size:14px;">
                                                ${review.reviewer.name}
                                            </div>
                                            <div style="font-size:12px;color:#94a3b8;display:flex;align-items:center;gap:6px;">
                                                ${review.formattedDate}
                                                <c:if test="${review.verifiedBuyer}">
                                                    <span style="color:#16a34a;font-weight:600;display:flex;align-items:center;">
                                                        <svg style="width:12px;height:12px;margin-right:2px" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>
                                                        Verified Buyer
                                                    </span>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                    <div style="text-align:right;">
                                        <div style="color:#fbbf24;font-size:16px;">
                                            <c:forEach begin="1" end="${review.rating}" var="s">★</c:forEach>
                                        </div>
                                        <div style="font-size:11px;color:#64748b;margin-top:2px;">
                                            <span>Comm: ${review.communicationRating != null ? review.communicationRating : review.rating}/5</span> | 
                                            <span>Acc: ${review.accuracyRating != null ? review.accuracyRating : review.rating}/5</span>
                                        </div>
                                    </div>
                                </div>
                                <c:if test="${not empty review.comment}">
                                    <p style="color:#374151;font-size:14px;margin:0;line-height:1.6;">
                                        ${review.comment}
                                    </p>
                                </c:if>
                            </div>
                        </c:forEach>
                        <c:if test="${empty reviews}">
                            <p style="color:#94a3b8;text-align:center;padding:20px;">No reviews yet.</p>
                        </c:if>
                    </div>

                    <!-- Agent's active listings -->
                    <div style="background:white;border-radius:10px;padding:25px;
              box-shadow:0 1px 8px rgba(0,0,0,0.06);">
                        <h3 style="margin:0 0 20px;color:#1e293b;">Active Listings by ${agent.name}</h3>
                        <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:15px;">
                            <c:forEach var="p" items="${listings}">
                                <a href="/properties/${p.id}" style="text-decoration:none;">
                                    <div style="border:1px solid #e5e7eb;border-radius:8px;overflow:hidden;">
                                        <div style="height:120px;background:#e0e7ff;display:flex;
                        align-items:center;justify-content:center;font-size:24px;">
                                            <c:choose>
                                                <c:when test="${not empty p.images}">
                                                    <img src="${p.images[0].imageUrl}" alt="${p.title}"
                                                        style="width:100%;height:100%;object-fit:cover;">
                                                </c:when>
                                                <c:otherwise>🏠</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div style="padding:10px;">
                                            <div style="font-size:13px;font-weight:600;color:#1e293b;
                          white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                ${p.title}
                                            </div>
                                            <div style="color:#1a73e8;font-size:13px;font-weight:700;margin-top:3px;">
                                                ₹
                                                <fmt:formatNumber value="${p.price}" groupingUsed="true"
                                                    maxFractionDigits="0" />
                                            </div>
                                        </div>
                                    </div>
                                </a>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <!-- Review JavaScript -->
                <script>
                    let selectedRating = 0;

                    function setRating(value) {
                        selectedRating = value;
                        document.getElementById('selectedRating').value = value;
                        document.querySelectorAll('.star').forEach((s, i) => {
                            s.style.color = i < value ? '#fbbf24' : '#d1d5db';
                        });
                    }

                    function hoverRating(value) {
                        document.querySelectorAll('.star').forEach((s, i) => {
                            s.style.color = i < value ? '#fbbf24' : '#d1d5db';
                        });
                    }

                    function resetHover() {
                        document.querySelectorAll('.star').forEach((s, i) => {
                            s.style.color = i < selectedRating ? '#fbbf24' : '#d1d5db';
                        });
                    }

                    function submitReview(agentId) {
                        if (selectedRating === 0) {
                            alert('Please select a star rating');
                            return;
                        }

                        fetch('/api/v1/reviews/agent/' + agentId, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({
                                rating: selectedRating,
                                communicationRating: document.getElementById('ratingComm') ? document.getElementById('ratingComm').value : selectedRating,
                                accuracyRating: document.getElementById('ratingAcc') ? document.getElementById('ratingAcc').value : selectedRating,
                                negotiationRating: document.getElementById('ratingNeg') ? document.getElementById('ratingNeg').value : selectedRating,
                                comment: document.getElementById('reviewComment').value
                            })
                        })
                            .then(r => r.json())
                            .then(data => {
                                if (data.success) {
                                    if (typeof showToast === 'function') {
                                        showToast('Review submitted! Thank you.', 'success');
                                    } else {
                                        alert('Review submitted! Thank you.');
                                    }
                                    setTimeout(() => location.reload(), 1500);
                                } else {
                                    if (typeof showToast === 'function') {
                                        showToast(data.message, 'error');
                                    } else {
                                        alert(data.message);
                                    }
                                }
                            });
                    }
                </script>
                <%@ include file="/WEB-INF/views/common/footer.jsp" %>