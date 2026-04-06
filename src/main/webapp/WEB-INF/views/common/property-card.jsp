<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <div class="pcard">
                <!-- Image -->
                <div class="pcard-img">
                    <c:choose>
                        <c:when test="${not empty p.images}">
                            <img src="${pageContext.request.contextPath}${p.images[0].imageUrl}" alt="${p.title}" 
                                 onerror="this.src='https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80';">
                        </c:when>
                        <c:otherwise>
                            <img src="https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80" alt="Property Placeholder" 
                                 style="filter: grayscale(0.5); opacity: 0.8;">
                            <div class="no-img-overlay">🏠</div>
                        </c:otherwise>
                    </c:choose>

                    <!-- Badges -->
                    <div class="badge-row">
                        <c:if test="${p.isFeatured}">
                            <span class="badge badge-featured">FEATURED</span>
                        </c:if>
                        <c:choose>
                            <c:when test="${p.category == 'BUY'}">
                                <span class="badge badge-buy">BUY</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge badge-rent">RENT</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Wishlist Button -->
                    <c:set var="isSaved" value="false" />
                    <c:if test="${not empty savedPropertyIds}">
                        <c:forEach var="savedId" items="${savedPropertyIds}">
                            <c:if test="${savedId == p.id}">
                                <c:set var="isSaved" value="true" />
                            </c:if>
                        </c:forEach>
                    </c:if>
                    <button class="wish-btn" onclick="toggleWishlist(${p.id}, this); event.preventDefault();" 
                            title="${isSaved ? 'Remove from wishlist' : 'Save property'}" data-id="${p.id}">
                        ${isSaved ? '❤️' : '🤍'}
                    </button>
                </div>

                <!-- Card Body -->
                <div class="pcard-body">
                    <div class="pcard-title" title="${p.title}">${p.title}</div>

                    <div class="pcard-price">
                        ₹
                        <fmt:formatNumber value="${p.price}" groupingUsed="true" />
                        <c:if test="${p.priceNegotiable}">
                            <span class="neg">(Negotiable)</span>
                        </c:if>
                    </div>

                    <div class="pcard-loc">
                        📍 <c:if test="${not empty p.location}">${p.location}, </c:if>
                        ${p.city}
                    </div>

                    <div class="pcard-meta">
                        <c:if test="${p.bedrooms > 0}"><span>🛏 ${p.bedrooms} BHK</span>
                        </c:if>
                        <c:if test="${p.bathrooms > 0}"><span>🚿 ${p.bathrooms}</span>
                        </c:if>
                        <c:if test="${p.areaSqft != null}">
                            <span>📐
                                <fmt:formatNumber value="${p.areaSqft}" maxFractionDigits="0" /> sqft
                            </span>
                        </c:if>
                    </div>

                    <div class="pcard-foot">
                        <div style="display:flex; justify-content:space-between; align-items:center; width:100%; margin-bottom:8px;">
                            <span class="type-chip">${p.type}</span>
                            <a href="/properties/${p.id}" class="btn-view">View Details &rarr;</a>
                        </div>
                        <button onclick="addToCompare(${p.id}, '${p.title}', event)" id="compareBtn_${p.id}" class="btn-compare-small">
                            ⚖ Compare Property
                        </button>
                    </div>
                </div>
            </div>